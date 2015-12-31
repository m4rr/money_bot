require 'telegram/bot'

load "token.rb"

# trap "SIGINT" do
#   puts "Exiting"
#   exit 130
# end

def parse_values values
  return {} if values.is_a?(Fixnum)
  puts values
  # hash = {}
  values.each do |e|
    case e
    when '$'
      hash[:currency] = :USD
    when '€'
      hash[:currency] = :EUR
    when '₽'
      hash[:currency] = :RUB
    when /(\d+)/
      hash[:amount] = $1
    end
  end
  hash
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    case message.text
    when /([$€₽])?\s*(\d+)\s*([$€₽])?/
      amount = $2
      currency = [$1, $3].compact.first
      hash = {amount: amount, currency: currency}
      bot.api.send_message(chat_id: message.chat.id, text: "got it #{hash.to_s}")
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Hello, #{message.from.first_name}")
    when '/stop'
      bot.api.send_message(chat_id: message.chat.id, text: "Bye, #{message.from.first_name}")
    end
  end
end
