# Money/USDRUB Bot

Convert $, €, ₽, CAD currencies based on Open Exchange Rates.
Ask '$1' for example. Or '100 ₽'. Telegram chat bot like:
* you ask `$10`
* she replies `735 ₽`

## Use bot

Start chat with [@USDRUB_bot](https://telegram.me/USDRUB_bot) in Telegram.

# Installation via Docker

In the folder:

```sh
$ echo "TOKEN = 'YOUR_TOKEN'" >> money_bot/token.rb          # Telegram Bot Token from @BotFather
$ echo "OXR_APP_ID = 'YOUR_OXR_ID'" >> money_bot/token.rb    # App token from Open Exchange Rates
$ docker build -t m4rr/money_bot .
```

# Start up container

```sh
$ docker run -d m4rr/money_bot
```
