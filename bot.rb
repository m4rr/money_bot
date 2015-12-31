require 'telegram/bot'

load "token.rb"

# trap "SIGINT" do
#   puts "Exiting"
#   exit 130
# end

@base_rub_json

Start_Text = "I can exchange $, €, ₽ currencies. Ask me '$4' for example. Or '100 ₽'."

def detect_currency value
  case value
  when '$'
    :USD
  when '€'
    :EUR
  when '₽'
    :RUB
  end
end

def convert hash
  amount = hash[:amount]
  currency = detect_currency hash[:currency]

  if @base_rub_json.nil?
    response = Net::HTTP.get_response('api.fixer.io', '/latest?base=RUB')
    @base_rub_json = JSON.parse response.body
  end

  if currency == :RUB
    to_cur = :USD
  elsif currency == :USD || currency == :EUR
    to_cur = :RUB
  end

  val = @base_rub_json['rates'][:USD.to_s] if currency == :USD || currency == :RUB
  val = @base_rub_json['rates'][:EUR.to_s] if currency == :EUR

  if currency == :RUB
    result = (amount.to_f * val.to_f).round(2)
  else
    result = (amount.to_f / val.to_f).round(2)
  end

  "#{result} of #{to_cur}"
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when /([$€₽])?\s*(\d+)\s*([$€₽])?/
      amount = $2
      currency = [$1, $3].compact.first
      hash = {amount: amount, currency: currency}
      bot.api.send_message(chat_id: message.chat.id, text: "#{convert hash} ")
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}. #{Start_Text}")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    else
      bot.api.send_message(chat_id: message.chat.id, text: "Not sure. #{Start_Text}")
    end
  end
end
