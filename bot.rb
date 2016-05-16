require "net/http"
require "uri"
require 'telegram/bot'

path = File.expand_path(File.dirname(__FILE__))
load "#{path}/token.rb"

Start_Text = "I convert $, €, ₽ currencies based on Open Exchange Rates. Ask me '$1' for example. Or '100 ₽'."
Keys = [
  ["100 rubles", "1000 рублей", "3000 ₽", "50000 ₽", "70000 ₽"],
  ["1 dollar", "$100", "$500", "$1000"],
  ["1 euro", "100 €", "500 €", "1000 €"],
]

# check currencies on OXR
def usd_base_json
  if @last_checked.nil? || Time.now.to_i - @last_checked.to_i > 30 * 60
    uri = URI.parse("https://openexchangerates.org/api/latest.json?app_id=#{OXR_APP_ID}")
    base_usd = Net::HTTP.get_response(uri)
    @usd_base_json_store = JSON.parse base_usd.body
    @last_checked = Time.now
    puts('@last_checked', @last_checked)
  end
  @usd_base_json_store
end

# currency string to symbol
def detect_currency value
  case value.to_s.strip
  when /\$|USD|dollar[s]?|бакс[а-я]{0,2}|доллар[а-я]{0,2}|грин[а-я]?/i
    :USD
  when /€|EUR[a-z]{0,2}|евро/i
    :EUR
  when /₽|RUB{0,4}|руб[a-zа-я]{0,4}|деревян[a-zа-я]{0,3}/i
    :RUB
  else
    :not_expected
  end
end

# format number to string with thousands separator
def space_in number
  number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
end

# convert values in hash
def convert hash
  currency = detect_currency hash[:currency]
  return nil if currency == :not_expected

  change_currency = currency == :USD || currency == :EUR ? :RUB : :USD

  amount = (hash[:amount]).delete(' _').sub(',', '.').to_f
  usdrub_rate = (usd_base_json['rates']['RUB']).to_f
  usdeur_rate = (usd_base_json['rates']['EUR']).to_f

  rate = usdrub_rate
  rate = usdrub_rate / usdeur_rate if currency == :EUR

  result = change_currency == :RUB ? (amount * rate) : (amount / rate)

  "#{space_in result.round(2)} #{change_currency}"
end

def custom_keyboard
  Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: Keys, resize_keyboard: true, one_time_keyboard: false)
end

# https://regex101.com/r/cJ3bG1/3
def parse message
  result = { chat_id: message.chat.id }

  case message.text
  when '/start'
    result[:reply_markup] = custom_keyboard
    result[:text] = "Hello, #{message.from.first_name}. #{Start_Text}"

  when /([$€₽]{1,15}) ?([\d,.]{1,15})/i
    result[:text] = convert({ amount: $2, currency: $1 })

  when /([-+]?[0-9]+[.,]?[0-9]*) ?([$€₽]{1,2}|[a-zа-я]{3,15})/i
    result[:text] = convert({ amount: $1, currency: $2 })

  end

  result[:reply_to_message_id] = message.message_id if Time.now.to_i - message.date >= 30 # respond with reply if timeout

  result if !result[:text].nil?
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    parameters = parse(message)
    if !parameters.nil? && !parameters.empty?
      bot.api.send_message(parameters)
    end
  end
end
