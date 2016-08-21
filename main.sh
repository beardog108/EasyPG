#!/bin/bash

# Store menu options selected by the user
INPUT=/tmp/menu.sh.$$
export LD_PRELOAD=$(dirname $0)/randpatch/randpatch.so

# Main menu
while [ 1 ]
do

COLOR=$(whiptail --menu --nocancel --noitem "EasyPG - Main Menu" 15 20 5 "Generate Key" "" "List Keys" "" "Encryption" "" "Signing" "" 3>&1 1>&2 2>&3)

sleep 1
echo $COLOR
sleep 2
done

rm $INPUT
