#!/bin/bash

if ! ruby money_bot/tests.rb ; then
  echo tests failed
  exit 1
fi
echo "tests succeeded"

SECONDS=0
ssh rails '
  echo SSH connecting...
  cd ~/telegrambot/money_bot/
  git pull
  docker build -t m4rr/money_bot .
  docker kill "$(docker ps -q --filter ancestor=m4rr/money_bot | grep \w* | head -1)"
  docker run -d --restart=always m4rr/money_bot
  docker ps
  echo exitting...
  exit
'
duration=$SECONDS
echo "Done in $(($duration)) seconds."

exit 0
