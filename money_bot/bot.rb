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
  if @last_fetch.nil? || Time.now.to_i - @last_fetch.to_i > 1 * 60
    oxr_uri_latest = URI.parse("https://openexchangerates.org/api/latest.json?app_id=#{OXR_APP_ID}")
    oxr_response = Net::HTTP.get_response(oxr_uri_latest)
    @json_storage = JSON.parse(oxr_response.body)
    @last_fetch = Time.now
  end

  @json_storage
end

Greet = """
Напишите боту, и он ответит вам, если увидит _валюту и сумму_. Например: `я выиграл 10 000 баксов в конкурсе Дурова!`

Если вам все нравится, присылайте биткоины:
"""

Wallet = '3EfdG6DtxK29KoTvQffG2ZhRHCjcp1o8EX'

Keys = [['1 рубль', '100 ₽', '1 млн руб',],
        ['$1', '100 €', '£1k', '0,1 BTC',],
        ['Я выиграл 10 000 баксов!'],]

def start_reply chat_id
  {
    chat_id: chat_id,
    text: Greet,
    parse_mode: 'Markdown',
    disable_web_page_preview: true,
    reply_markup: Telegram::Bot::Types::ReplyKeyboardMarkup.new(
      keyboard: Keys, resize_keyboard: true, one_time_keyboard: false)
  }
end

def wallet_reply chat_id
  {
    chat_id: chat_id,
    text: Wallet
  }
end

def stop_reply chat_id
  {
    chat_id: chat_id,
    text: 'Клавиатура убрана',
    reply_markup: Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
  }
end

def any_text_reply(chat_id, text)
  parsed_message = parse_message(text)

  if parsed_message.nil?
    return nil
  end

  {
    chat_id: chat_id,
    text: parsed_message,
    parse_mode: 'Markdown'
  }
end

Telegram::Bot::Client.run(BOT_TOKEN) do |bot|
  bot.listen do |message|

    begin

      if message.text == '/start'
        bot.api.send_message(start_reply(message.chat.id))
        bot.api.send_message(wallet_reply(message.chat.id))
        bot.api.send_message(support_msg('#newuser @ ' + (message.from.language_code || '')))

      elsif message.text == '/stop'
        bot.api.send_message(stop_reply(message.chat.id))

      # elsif message.reply_to_message != nil && message.reply_to_message.from.is_bot
        # a reply with currency symbol to a bot's message
        # should send back a value converted from the message
        # to the replied currency
        #
        # result = {
        #   chat_id: message.chat.id,
        #   text: message.reply_to_message.text + " got it",
        # }
        #
        # bot.api.send_message(result)

      else
        result = any_text_reply(message.chat.id, message.text || message.caption)

        if result.nil?
          next
        end

        # respond with reply if timed out
        result[:reply_to_message_id] = message.message_id if Time.now.to_i - message.date >= 30

        bot.api.send_message(result)

        # usage statistics
        stat_msg = chat_id_inc(message.chat.id)
        bot.api.send_message(support_msg(stat_msg)) if !stat_msg.nil?

      end # if else

    rescue => e
      puts e.full_message
      bot.api.send_message(support_msg(e.full_message(highlight: false)))

    end # begin

  end # listen
end # run
