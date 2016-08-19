#!/bin/bash

# Store menu options selected by the user
INPUT=/tmp/menu.sh.$$

# Main menu
while [ 1 ]
do

CHOICE=$(whiptail --menu --nocancel --noitem "EasyPG - Main Menu" 15 20 5 "Generate Key" "" "List Keys" "" "Encryption" "" "Signing" "" "Quit" "" 3>&1 1>&2 2>&3)

case "$CHOICE" in
        "Generate Key")
            echo "Hey! generate a key!"
            ;;
         
        "List Keys")
            echo "List keys"
            ;;
        "Encryption")
			echo "Encryption"
			;;
		"Signing")
			echo "Signing"
			;;
         "Quit")
			echo "Quiting"
			exit
			;;
         
        *)
esac

sleep 1

done

rm $INPUT