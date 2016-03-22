require "net/http"
require "uri"
require 'telegram/bot'

load "token.rb"

Start_Text = "I convert $, €, ₽ currencies based on Open Exchange Rates. Ask me '$1' for example. Or '100 ₽'."

# check currencies on OXR
def base_usd_json
  if @last_checked.nil? || Time.now.to_i - @last_checked.to_i > 60 * 30
    uri = URI.parse("https://openexchangerates.org/api/latest.json?app_id=#{OXR_APP_ID}")
    base_usd = Net::HTTP.get_response(uri)
    @base_usd_json_store = JSON.parse base_usd.body
    @last_checked = Time.now
  end
  @base_usd_json_store
end

# currency string to symbol
def detect_currency value
  case value.to_s.strip
  when ""
    :USD
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

# convert values in hash
def convert hash
  currency = detect_currency hash[:currency]
  return "" if currency == :not_expected

  change_currency = currency == :USD || currency == :EUR ? :RUB : :USD

  amount = (hash[:amount]).delete(' _').sub(',', '.').to_f
  usdrub_rate = (base_usd_json['rates']['RUB']).to_f
  usdeur_rate = (base_usd_json['rates']['EUR']).to_f

  rate = usdrub_rate
  rate = usdrub_rate / usdeur_rate if currency == :EUR

  result = change_currency == :RUB ? (amount * rate) : (amount / rate)

  "#{space_in result.round(2)} #{change_currency}"
end

# format number to string with thousands separator
def space_in number
  number.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1 ').reverse
end

def nothing

end

# bot custom keyboard
@keys = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [
  ["100 rubles", "1000 ₽", "5000 ₽"],
  ["1 dollar", "$100", "$500", "$1000"],
  ["1 euro", "100 €", "500 €", "1000 €"],
], resize_keyboard: true, one_time_keyboard: false)

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      text = "Hello, #{message.from.first_name}. #{Start_Text}"
      bot.api.send_message(chat_id: message.chat.id, text: text, reply_markup: @keys)

    when '/stop'
      text = "Bye, #{message.from.first_name}"
      bot.api.send_message(chat_id: message.chat.id, text: text)

    when /хуй|хуе|хуё|хуи/i
      text = "🙀"
      bot.api.send_message(chat_id: message.chat.id, text: text)

    when /блят|бляд/i
      text = "💃🏼"
      bot.api.send_message(chat_id: message.chat.id, text: text)

    when /^([ $€₽a-zа-я]{0,15})([\d ,.]{1,15})([ $€₽a-zа-я]{0,15})/i # https://regex101.com/r/cJ3bG1/2
      if $2.to_f > 0
        text = convert({amount: $2, currency: [$1, $3].compact.reject(&:empty?).first})
        bot.api.send_message(chat_id: message.chat.id, text: text) if text != ""
      end

    else
      nothing
    end
  end
end
