require "net/http"
require "uri"
require 'telegram/bot'

load "token.rb"

# trap "SIGINT" do
#   puts "Exiting"
#   exit 130
# end

Start_Text = "I convert $, €, ₽ currencies based on Open Exchange Rates. Ask me '$1' for example. Or '100 ₽'."


def base_usd_json
  if @last_checked.nil? || Time.now.to_i - @last_checked.to_i > 60 * 30
    uri = URI.parse("https://openexchangerates.org/api/latest.json?app_id=#{OXR_APP_ID}")
    base_usd = Net::HTTP.get_response(uri)
    @base_usd_json_store = JSON.parse base_usd.body
    @last_checked = Time.now
  end
  @base_usd_json_store
end

def detect_currency value
  case value
  when /\$|USD|dollar[s]?|бакс[а-я]{0,2}|доллар[а-я]{0,2}|грин[а-я]?/i
    :USD
  when /€|EUR[a-z]{0,2}|евро/i
    :EUR
  when /₽|RUB{0,4}|руб[a-zа-я]{0,4}|деревян[a-zа-я]{0,3}/i
    :RUB
  else
    :USD
  end
end

def convert hash
  puts hash
  currency = detect_currency hash[:currency]
  change_currency = currency == :USD || currency == :EUR ? :RUB : :USD

  amount = (hash[:amount]).to_f
  usdrub_rate = (base_usd_json['rates']['RUB']).to_f
  usdeur_rate = (base_usd_json['rates']['EUR']).to_f

  rate = usdrub_rate
  rate = usdrub_rate / usdeur_rate if currency == :EUR

  result = change_currency == :RUB ? (amount * rate) : (amount / rate)

  "#{result.round(2)} #{change_currency}"
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      keys = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: [
        ["100 rubles", "1000 ₽", "5000 ₽"],
        ["1 dollar", "$100", "$500", "$1000"],
        ["1 euro", "100 €", "500 €", "1000 €"],
      ], resize_keyboard: true, one_time_keyboard: false)
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}. #{Start_Text}", reply_markup: keys)
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    when /([$€₽a-zа-я]*)\s*([\d.,]{1,15})\s*([$€₽a-zа-я]*)/i # https://regex101.com/r/cJ3bG1/1
      hash = { amount: $2, currency: [$1, $3].compact.reject(&:empty?).first }
      bot.api.send_message(chat_id: message.chat.id, text: convert(hash))
    else
      bot.api.send_message(chat_id: message.chat.id, text: "Not sure. #{Start_Text}")
    end
  end
end
