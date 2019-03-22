#!/bin/bash

if ! ruby money_bot/tests.rb ; then
  echo tests failed
  exit 1
fi
echo "tests succeeded"
