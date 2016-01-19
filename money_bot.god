God.watch do |w|
  w.name = "moneybot"
  w.start = "ruby ~/telegrambot/money_bot/bot.rb"
  w.keepalive
end
