FROM inzinger/alpine-ruby

MAINTAINER Marat Saytakov <remarr@gmail.com>

RUN mkdir /money_bot
COPY ["bot.rb", "/money_bot/"]
CMD ["ruby", "/money_bot/bot.rb"]
