path = File.expand_path(File.dirname(__FILE__))

God.watch do |w|
  w.name = "simple"
  w.interval = 10.seconds # default
  w.start = "ruby #{path}/bot.rb"
  w.keepalive
end
