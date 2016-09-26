#!/bin/bash
#
# flip phillips
# fall 2016
#
# read a twine's temperature sensor, upload to a wolfram data drop databin
#
 
WGET="/usr/local/bin/wget"
DROP="/usr/local/bin/drop_data.sh"

# sets  EMAIL, PASSWORD, DATABIN, and TWINEID
if [[ -f ./twine.config ]]; then
    source ./twine.config
elif [[ -f /usr/local/etc/twine.config ]]; then
    source /usr/local/etc/twine.config
elif [[ -f /etc/twine.config ]]; then
    source /etc/twine.config
else
    echo "No configuration found."
    exit -1
fi

: "${EMAIL?Need to set EMAIL non-empty}"
: "${PASSWORD?Need to set PASSWORD non-empty}"
: "${DATABIN:?Need to set DATABIN non-empty}"
: "${TWINEID:?Need to set TWINEID non-empty}"

LOGIN="email=$EMAIL&password=$PASSWORD"

$WGET -o /tmp/log.txt --quiet -O /tmp/temp.txt --keep-session-cookies --save-cookies /tmp/cookies.txt --no-check-certificate --post-data=${LOGIN} https://twine.cc/login

$WGET -o /tmp/log.txt --quiet -O /tmp/temp.txt --load-cookies /tmp/cookies.txt --no-check-certificate https://twine.cc/${TWINEID}/rt?cached=1

TEMP=`cat /tmp/temp.txt | awk -F"," '{print $7}' | awk -F"]" '{print $1}' | tr -d ' '`
TEMP=`bc <<< "scale=2; $TEMP/100"`

# these are obviously not necessary, but hesful for debugging
$DROP $DATABIN time `date "+%m%d%H%M%Y.%S"`
$DROP $DATABIN host `hostname`
$DROP $DATABIN ssid-count `defaults read /Library/Preferences/SystemConfiguration/com.apple.airport.preferences | grep "SSIDString =" | wc -l`

$DROP $DATABIN temperature $TEMP

$DROP $DATABIN --send &> /tmp/twine.log
