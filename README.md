# Money/USDRUB Bot

I convert $, €, ₽ currencies based on Open Exchange Rates. Ask me '$1' for example. Or '100 ₽'.

Telegram chat bot like
* you ask `$10`
* she replies `735 ₽`

## Use bot

Start chat with [@USDRUB_bot](https://telegram.me/USDRUB_bot) in Telegram.

# Installation

```sh
$ bundle
$ echo "TOKEN = 'YOUR_TOKEN'" >> token.rb
$ echo "OXR_APP_ID = 'Open Exchange Rates token'" >> token.rb
$ bundle exec ruby bot.rb
```

# Starting

```sh
$ bundle exec ruby bot.rb            # foreground execution with stdout
#                                    # OR
$ nohup bundle exec ruby bot.rb &    # background execution
```
