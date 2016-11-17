FROM alpine:latest
MAINTAINER Marat Saytakov <remarr@gmail.com>

RUN echo 'gem: --no-rdoc --no-ri'>/etc/gemrc

RUN apk add --update \
  ca-certificates \
  libstdc++ \
  ruby \
  ruby-json \
  ruby-bigdecimal \
  && rm -rf /var/cache/apk/*

RUN  ["mkdir", "/money_bot"]
COPY ["./money_bot", "/money_bot"]
RUN  ["gem", "install", "telegram-bot-ruby"]
CMD  ["ruby", "/money_bot/bot.rb"]
