require 'json'
require 'net/http'
require 'telegram/bot'
require 'uri'

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
Бот отвечает на сообщения с ценой и валютой. Конвертирует <b>$ и € в рубли</b>, и обратно. Напишите „<b>$10k</b>“ или „<b>100 000 рублей</b>“.

Свободно добавляйте в групповые чаты. Не собирает и не хранит переписки. Весь <a href='https://github.com/m4rr/money_bot'>код открыт</a>.

Подписывайтесь на мой канал <a href='https://t.me/CitoyenMarat'>@CitoyenMarat</a> и твиттер <a href='https://twitter.com/m4rr'>@m4rr</a>.

© Марат Сайтаков.
"""

# Bot replies to messages containing amount & currency info. Converts <b>$ and € to rubles</b>, and back. Ask “<b>$10k</b>” or “<b>100 000 RUB</b>.”
# Freely add her to group chats. Doesn’t collect and/or store converstaions. Uses Open Exchange Rates. <a href='https://github.com/m4rr/money_bot'>Open source</a>.
# Author: Marat Saytakov. Join my channel <a href='https://t.me/CitoyenMarat'>@CitoyenMarat</a> and twitter <a href='https://twitter.com/m4rr'>@m4rr</a>.

def parse_message message
  result = { chat_id: message.chat.id }


  happy_bday = [
    "Божена! Ты самая обаятельная и привлекательная.",

    "Божена! Все мужчины оборачиваются и смотрят тебе вслед безумными глазами.",

    "Божена! Мужчины будут счастливы, если ты их одаришь мимолетным взглядом, улыбкой.",

    "Божена! У тебя стройная фигура, красивые ноги, грациозная походка, чарующий взгляд.",


    "Божена! Твои родители случайно не садовники? Нет? Тогда откуда у них такой цветок?",

    "Божена! Тут звонили из рая и сказали, что у них сбежал самый красивый ангел, но мы тебя не выдали!",

    "Божена! Однажды Небо и Земля поспорили, кто из них красивее. И тогда, что бы доказать свою красоту, небо показало звезды, а Земля показала тебя!",
  ]

  if message.chat.title == "тест-марат-ираклий" # message.from.username == "maratacrobat" # "pearl_hush"
    result[:text] = happy_bday[Random.new.rand(0..happy_bday.count-1)]
  end # if

  parsed = parse_text(message.text)

  case parsed
  when :start
    result[:reply_markup] = Telegram::Bot::Types::ReplyKeyboardMarkup.new(keyboard: Keys, resize_keyboard: true, one_time_keyboard: false)
    result[:disable_web_page_preview] = true
    result[:parse_mode] = 'HTML'
    result[:text] = Greet
  when :stop
    result[:reply_markup] = Telegram::Bot::Types::ReplyKeyboardRemove.new(remove_keyboard: true)
    result[:text] = "Клавиатура убрана.\n\n* * *\n\nKeyboard has been removed."
  else
    result[:text] = parsed if !parsed.nil?
  end

  # respond with reply if timeout
  result[:reply_to_message_id] = message.message_id if Time.now.to_i - message.date >= 30

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
