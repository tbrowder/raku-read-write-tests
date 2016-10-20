#!/bin/bash

if [[ -z "$1" ]] ; then
  echo "Usage: $0 go"
  echo 
  echo "Runs tests."
  exit
fi

VERS="\
2015.12 \
2016.01 \
2016.02 \
2016.03 \
2016.04 \
2016.05 \
"

for v in $VERS
do
  #echo "Switching to rakudo version $v..."
  rakudobrew switch $v
  run-rw-test.pl6 short 
done

