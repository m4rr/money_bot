God.watch do |w|
  w.name = "moneybot"
  w.start = "bundle exec ruby ~/telegrambot/money_bot/bot.rb"
  w.keepalive
end
