#!/bin/bash
#
# flip phillips
# fall 2016
#
# read a twine's temperature sensor, upload to a wolfram data drop databin
#
 
WGET="/usr/local/bin/wget"
DROP="/usr/local/bin/drop_data.sh"

LOGIN="email=YOUR_TWINE_EMAIL_HERE&password=YOUR_TWINE_PW_HERE"
TWINEID="YOUR_TWINE_ID_HERE"
DATABIN="YOUR_WOLFRAM_DATABIN_HERE"

# login and 
$WGET -o /tmp/log.txt --quiet -O /tmp/temp.txt --keep-session-cookies --save-cookies /tmp/cookies.txt --no-check-certificate --post-data=${LOGIN} https://twine.cc/login

$WGET -o /tmp/log.txt --quiet -O /tmp/temp.txt --load-cookies /tmp/cookies.txt --no-check-certificate https://twine.cc/${TWINEID}/rt?cached=1

TEMP=`cat /tmp/temp.txt | awk -F"," '{print $7}' | awk -F"]" '{print $1}' | tr -d ' '`
let TEMP="TEMP/100"

$DROP $DATABIN "temperature" $TEMP
$DROP $DATABIN --send &> /tmp/twine.log
