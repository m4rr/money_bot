require 'json'
require 'net/http'
require 'telegram/bot'
require 'uri'

$stdout.sync = true

path = File.expand_path(File.dirname(__FILE__))
load "#{path}/token.rb"
load "#{path}/parser.rb"
load "#{path}/stat.rb"

# check open exchange rates or return cached
def usd_base_json
  if @last_check.nil? || Time.now.to_i - @last_check.to_i > 30 * 60
    oxr_latest_uri = URI.parse("https://openexchangerates.org/api/latest.json?app_id=#{OXR_APP_ID}")
    oxr_response = Net::HTTP.get_response(oxr_latest_uri)
    @json_storage = JSON.parse(oxr_response.body)
    @last_check = Time.now
  end

  @json_storage
end

Greet = """
Напишите боту: 

`Я выиграл 10 000 баксов в конкурсе Дурова!`

... и бот ответит на такое сообщение, где есть _валюта и сумма_ — удобно в чатах. Ничего не собирает и не хранит. [Исходный код.](https://github.com/m4rr/money_bot) Бот бесплатный. Группа поддержки: @usdrubbotsupport

Если вам нравится, присылайте биткоины:
"""

BTC_Wallet = "`3EfdG6DtxK29KoTvQffG2ZhRHCjcp1o8EX`"

Keys = [['100 рублей', '1000 rubles', '0,1 BTC'],
        ['1 dollar', '$100', '100 €', '$10k' ],
        ['Я выиграл 10 000 баксов!'],]

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    
    begin
      result = { chat_id: message.chat.id }
      result[:parse_mode] = 'Markdown'

      case message.text
      when '/start'
        result[:text] = Greet
        result[:disable_web_page_preview] = true
        result[:reply_markup] = Telegram::Bot::Types::ReplyKeyboardMarkup.new(
          keyboard: Keys, resize_keyboard: true, one_time_keyboard: false)

        bot.api.send_message(result)
        
        result[:text] = BTC_Wallet
        result[:reply_markup] = nil
        bot.api.send_message(result)

        bot.api.send_message(support_msg("new user 🚀 (" + (message.from.language_code || "") + ")"))

      when '/stop'
        result[:text] = "Клавиатура убрана."
        result[:reply_markup] = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    
        bot.api.send_message(result)

      when /гугол/i && message.chat.id == -280573945
        result[:text] = 'Ираклий, ну хватит!'

        bot.api.send_message(result)

      else
        parsed_message = parse_message(message.text)

        if parsed_message.nil?
          next
        end
        
        result[:text] = parsed_message

        # respond with reply if timeout
        result[:reply_to_message_id] = message.message_id if Time.now.to_i - message.date >= 30

        bot.api.send_message(result)
      
        # usage statistics
        stat_msg = chat_id_inc(message.chat.id)
        bot.api.send_message(support_msg(stat_msg)) if !stat_msg.nil?

      end # case else

    rescue => e
      puts e.full_message
      bot.api.send_message(support_msg(e.full_message(highlight: false)))
    end # begin

  end # listen
end # run
