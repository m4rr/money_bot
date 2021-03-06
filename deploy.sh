#!/bin/bash

if ! ruby money_bot/tests.rb ; then
  echo tests failed
  exit 1
fi
echo "tests succeeded"

SECONDS=0
ssh scw '
  echo SSH connecting...
  cd ~/money_bot/
  git pull
  docker stop money_bot
  docker rm money_bot
  docker build -t m4rr/money_bot .
  docker run -d --name money_bot --restart=always m4rr/money_bot
  docker ps
  echo exitting...
  exit
'
duration=$SECONDS
echo "Done in $(($duration)) seconds."

exit 0
