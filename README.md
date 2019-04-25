# Money Bot for Telegram

Bot is handy in group chats. She looks for the currencies in chat context and converts $, €, ₽, CAD currencies to opposite ones (based on Open Exchange Rates). _Opposite ones_ are set empirically.

For example:
* someone sent to a chat `bought a backpack for $119 free shipping`
* she replies `7691 ₽`

Start chat with **[@USDRUB_bot](https://telegram.me/USDRUB_bot)** in Telegram. Ask '$1', '5€' or even '100 RUB'.

### Build Docker Image

In the folder:

```sh
$ echo "BOT_TOKEN = 'YOUR_TOKEN'" >> money_bot/token.rb       # Telegram Bot Token from @BotFather
$ echo "OXR_APP_ID = 'YOUR_OXR_ID'" >> money_bot/token.rb # App token from Open Exchange Rates

$ docker build -t m4rr/money_bot .                        # Build Docker image
```

### Start Up the Container

```sh
$ docker run -d --name money_bot --restart=always m4rr/money_bot           # Run Docker container
```
