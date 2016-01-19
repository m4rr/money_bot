God.watch do |w|
  w.name  = "bot"
  w.start = "bundle exec ruby /home/m4rr/telegrambot/money_bot/bot.rb"
  w.keepalive
end
