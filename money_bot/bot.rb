require 'json'
require 'net/http'
require 'telegram/bot'
require 'uri'

$stdout.sync = true

path = File.expand_path(File.dirname(__FILE__))
load "#{path}/token.rb"
load "#{path}/parser.rb"

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

Keys = [['100 рублей', '1000 rubles', '5000 ₽'],
        ['1 dollar', '$100', '$500', '$1000'  ],
        ['1 euro', '100 €', '500 €',  '1000 €'],]

Greet = """
Напишите “`$10k`” или что-то вроде «`Я выиграл 100 000 рублей в конкурсе`» — и бот ответит на такое сообщения, где указана сумма и валюта.

Добавляйте бота в групповые чаты, это очень удобно! Бот не собирает и не хранит переписку. [Открытый](https://github.com/m4rr/money_bot) исходный код.

Подписывайтесь на мой канал @CitoyenMarat и твиттер [@m4rr](https://twitter.com/m4rr).

Группа поддержки: @usdrubBotSupport
"""

# Bot replies to messages containing amount & currency info. Converts <b>$ and € to rubles</b>, and back. Ask “<b>$10k</b>” or “<b>100 000 RUB</b>.”
# Freely add her to group chats. Doesn’t collect and/or store converstaions. Uses Open Exchange Rates. <a href='https://github.com/m4rr/money_bot'>Open source</a>.
# Author: Marat Saytakov. Join my channel <a href='https://t.me/CitoyenMarat'>@CitoyenMarat</a> and twitter <a href='https://twitter.com/m4rr'>@m4rr</a>.

def parse_message message
  result = { chat_id: message.chat.id }

  parsed = parse_text(message.text)

  case parsed
  when :start
    result[:reply_markup] = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: Keys, resize_keyboard: true, one_time_keyboard: false)
    result[:disable_web_page_preview] = true
    result[:parse_mode] = 'Markdown'
    result[:text] = Greet
  when :stop
    result[:reply_markup] = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    result[:text] = "Клавиатура убрана.\n\n* * *\n\nKeyboard has been removed."
    happy_bday = []
  else
    result[:text] = parsed if !parsed.nil?
  end

  # respond with reply if timeout
  result[:reply_to_message_id] = message.message_id if Time.now.to_i - message.date >= 30

  result if !result[:text].nil?
end

number_of_msgs_sent = 0
last_update = Time.now

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.listen do |message|
    parameters = parse_message(message)
    if !parameters.nil? && !parameters.empty?
      begin
        bot.api.send_message(parameters)
        number_of_msgs_sent += 1
        if Time.now.to_i - last_update.to_i > 30 * 60
          bot.api.send_message({ chat_id: "@usdrubbotsupport",
                                 text: number_of_msgs_sent.to_s + " msgs sent" })
          last_update = Time.now
          # number_of_msgs_sent = 0 # unexpected 0 shows restart
        end
      rescue => exception
        puts exception
        bot.api.send_message({ chat_id: "@usdrubbotsupport", text: exception.to_s })
      end
    end
  end
end
