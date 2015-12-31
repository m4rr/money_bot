require "net/http"
require "uri"
require 'telegram/bot'

load "token.rb"

# trap "SIGINT" do
#   puts "Exiting"
#   exit 130
# end

uri = URI.parse("https://openexchangerates.org/api/latest.json?app_id=#{OXR_APP_ID}")
base_usd = Net::HTTP.get_response(uri)
@base_usd_json = JSON.parse base_usd.body

Start_Text = "I can exchange $, €, ₽ currencies. Ask me '$4' for example. Or '100 ₽'."

def detect_currency value
  case value
  when '$'
    :USD
  when '€'
    :EUR
  when '₽'
    :RUB
  else
    :USD
  end
end

def convert hash
  # puts hash
  amount = (hash[:amount]).to_f
  usdrub_rate = (@base_usd_json['rates']['RUB']).to_f

  currency = detect_currency hash[:currency]
  change_currency = currency == :RUB ? :USD : :RUB

  result = change_currency == :RUB ? (amount * usdrub_rate) : (amount / usdrub_rate)

  "#{result.round(2)} #{change_currency}"
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}. #{Start_Text}")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    when /([$€₽])?\s*([\d.]+)\s*([$€₽])?/
      hash = {amount: $2, currency: [$1, $3].compact.first}
      bot.api.send_message(chat_id: message.chat.id, text: "#{convert hash}")
    else
      bot.api.send_message(chat_id: message.chat.id, text: "Not sure. #{Start_Text}")
    end
  end
end
