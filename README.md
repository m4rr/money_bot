# Money Bot for Telegram

Bot is handy in group chats. It listen for the context and convert $, €, ₽, CAD to opposite currencies (based on Open Exchange Rates).

Ask '$1' for example. Or '100 ₽'. Like this:
* someone told in chat `I bought a backpack for $119 free shipping`
* she replies `7691 ₽`

Start chat with **[@USDRUB_bot](https://telegram.me/USDRUB_bot)** in Telegram.

# Installation via Docker

In the folder:

```sh
$ echo "TOKEN = 'YOUR_TOKEN'" >> money_bot/token.rb          # Telegram Bot Token from @BotFather
$ echo "OXR_APP_ID = 'YOUR_OXR_ID'" >> money_bot/token.rb    # App token from Open Exchange Rates
$ docker build -t m4rr/money_bot .
```

# Start Up the Container

```sh
$ docker run -d --restart=always m4rr/money_bot
```
