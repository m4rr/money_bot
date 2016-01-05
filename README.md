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
$ echo "OXR_APP_ID = 'YOUR_OXR_TOKEN'" >> token.rb    # Open Exchange Rates Token
```

# Starting

```sh
$ bundle exec ruby bot.rb            # foreground execution with stdout
#                                    # OR
$ nohup bundle exec ruby bot.rb &    # background execution
#                                    # OR
$ ./start.sh                         # bash-script to start background execution
```
