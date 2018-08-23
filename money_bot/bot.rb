require "net/http"
require "uri"
require 'telegram/bot'

path = File.expand_path(File.dirname(__FILE__))
load "#{path}/token.rb"

Greet = """
Бот отвечает на сообщения с ценой и валютой. Конвертирует <b>$ и € в ₽</b>, и обратно. Напишите „<b>$10k</b>“ или „<b>100 000 рублей</b>“.

Не собирает и не хранит переписки. Свободно добавляйте в ваш международный групповой чат. Весь <a href='https://github.com/m4rr/money_bot'>код открыт</a>.

Автор — Марат Сайтаков. Подписывайтесь на мой канал <a href='https://t.me/CitoyenMarat'>@CitoyenMarat</a> и твиттер <a href='https://twitter.com/m4rr'>@m4rr</a>.

* * *

Bot replies to messages containing amount & currency info. Converts <b>$ and € to ₽</b>, and back. Ask “<b>$10k</b>” or “<b>100 000 RUB</b>.”

Doesn’t collect and/or store converstaions. Safely add her to a group chat. Uses Open Exchange Rates. <a href='https://github.com/m4rr/money_bot'>Open source</a>.

© Marat Saytakov. Join my channel <a href='https://t.me/CitoyenMarat'>@CitoyenMarat</a> and twitter <a href='https://twitter.com/m4rr'>@m4rr</a>.
"""

Keys = [ ['100 рублей', '1000 rubles', '5000 ₽'],
         ['1 dollar', '$100', '$500', '$1000'  ],
         ['1 euro', '100 €', '500 €',  '1000 €'], ]

# check currencies on OXR
def usd_base_json
  if @last_check.nil? || Time.now.to_i - @last_check.to_i > 30 * 60
    oxr_latest_uri = URI.parse("https://openexchangerates.org/api/latest.json?app_id=#{OXR_APP_ID}")
    oxr_response = Net::HTTP.get_response(oxr_latest_uri)
    @json_storage = JSON.parse(oxr_response.body)
    @last_check = Time.now
  end
  @json_storage
end

# currency text to symbol
def detect_currency value
  case value.to_s.strip
  when /CAD|канадск/i
    :CAD
  when /\$|USD|dollar|доллар|бакс/i
    :USD
  when /€|EUR|евро/i
    :EUR
  when /₽|RUB|руб/i
    :RUB
  else
    :not_expected
  end
end

def detect_amount(value, unit)
  amount = value.delete(' _').sub(',', '.').to_f

  case unit
  when /mm|млрд|миллиард/i
    amount *= 1_000_000_000
  when /m|млн|лям|миллион/i
    amount *= 1_000_000
  when /k|к|тыщ|тыс/i
    amount *= 1_000
  end

  amount
end

# format number to string with thousands separator
def space_in number
  number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
end

# convert values from given hash of `{ amount, unit, currency }`
def convert_text hash
  from_currency = detect_currency(hash[:currency])
  return nil if from_currency == :not_expected

  amount = detect_amount(hash[:amount], hash[:unit])

  rate = (usd_base_json['rates']['RUB']).to_f
  return nil if rate == 0

  if from_currency == :EUR
    usd_eur_rate = (usd_base_json['rates']['EUR']).to_f
    
    rate /= usd_eur_rate
  elsif from_currency == :CAD
    usd_cad_rate = (usd_base_json['rates']['CAD']).to_f

    rate /= usd_cad_rate
  end

  result = from_currency == :RUB ? (amount / rate) : (amount * rate)
  
  to_currency = from_currency == :RUB ? :USD : :RUB

  if to_currency == :RUB && result < 100 || result < 10
    result = result.round(2)
  else
    result = result.round
  end

  "#{space_in result} #{to_currency}"
end

def parse_message message
  result = { chat_id: message.chat.id }

  case message.text
  when '/start'
    result[:reply_markup] = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: Keys, resize_keyboard: true, one_time_keyboard: false)
    result[:disable_web_page_preview] = true
    result[:parse_mode] = 'HTML'
    result[:text] = Greet

  when '/stop'
    result[:reply_markup] = Telegram::Bot::Types::ReplyKeyboardHide.new(hide_keyboard: true)
    result[:text] = "Ok, thanks."

  # https://regexr.com/3uar8
  when /([$€₽])?(\d+[ \d.,]*)(mm|m|k|к|тыщ|тыс[а-я]{0,4}|млн|лям[а-я]{0,2}|миллион[а-я]{0,2}|млрд|миллиард[а-я]{0,2})? ?([$€₽]|usd|dollar|eur|rub|cad|руб|доллар|бакс|евро|канадск[а-я]{0,2} доллар)?/i
    result[:text] = convert_text({ amount: $2, unit: $3, currency: $1 || $4 })

  end

  if Time.now.to_i - message.date >= 30 # respond with reply if timeout
    result[:reply_to_message_id] = message.message_id 
  end

  result if !result[:text].nil?
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    parameters = parse_message(message)
    if !parameters.nil? && !parameters.empty?
      bot.api.send_message(parameters)
    end
  end
end
