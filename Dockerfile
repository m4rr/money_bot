FROM ruby:2.6-alpine
MAINTAINER Marat Saytakov <remarr@gmail.com>

RUN  ["mkdir", "/money_bot"]
COPY ["./money_bot", "/money_bot"]
RUN  ["gem", "install", "telegram-bot-ruby"]
CMD  ["ruby", "/money_bot/bot.rb"]
