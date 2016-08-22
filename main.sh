#!/bin/bash -m

# Store menu options selected by the user
INPUT=/tmp/menu.sh.$$

# Get the editor, if its not set, set it as nano

if [ $EDITOR -eq ""]; then
	EDITOR="nano";
fi

mode=""
type=""


# Generate a key
function generateKeys() {
	whiptail --msgbox "You will choose the type of key to generate (You probably want \"RSA and RSA\").\n \n When asked for a key size, you will probably want 2048 or 4096, however, larger keys take longer to generate." 15 75
	gpg --gen-key
}

# List the users keys
function listKeys() {
	gpg --list-keys | more
	sleep 3 # sleep for a few seconds so the user doesn't keep pressing enter into the main menu
}

# Encryption menu
function encryption() {
		mode=$(whiptail --menu --nocancel "Encrypt or Decrypt?" 15 20 5 "Encrypt" "" "Decrypt" "" "Return" "" 3>&1 1>&2 2>&3)
		
		if [ $mode == "Return" ]; then 
			return 
		fi

		#type=$(whiptail --menu --nocancel "File Or Text?" 15 20 5 "File" "" "Text" "" "Return" "" 3>&1 1>&2 2>&3)

		#if [ $TYPE == "Return" ]; then 
		#	return 
		#fi

		if [ $mode == "Encrypt" ]; then

			while [ 1 ]
			do
				recip=$(whiptail --inputbox --nocancel "Recipient id or name:" 15 20 3>&1 1>&2 2>&3)
				if [ "$recip" != "" ]; then
					break
				fi
			done

			touch /tmp/easypg-text.txt

			$EDITOR /tmp/easypg-text.txt

			whiptail --yesno "Do you want to sign your message?" 15 20
			if [ $? == 0 ]; then
				gpg -s -a -e -r $recip /tmp/easypg-text.txt
			else
				gpg -a -e -r $recip /tmp/easypg-text.txt
			fi

			clear

			echo "Message encrypted"

			cat /tmp/easypg-text.txt.asc
			echo ""
			echo "Press enter to continue"
			read

			shred /tmp/easypg-text.txt
			rm /tmp/easypg-text.txt
			rm /tmp/easypg-text.txt.asc
		else
			touch /tmp/easypg-text-encrypted.txt
			$EDITOR /tmp/easypg-text.txt
		fi
		

}

# Main menu
while [ 1 ]
do

CHOICE=$(whiptail --menu --nocancel --noitem "EasyPG - Main Menu" 15 30 6 "Generate Key" "" "List Keys" "" "Encryption" "" "Signing" "" "About" "" "Quit" "" 3>&1 1>&2 2>&3)

case "$CHOICE" in
        "Generate Key")
            generateKeys
            ;;
        "List Keys")
            listKeys
            ;;
        "Encryption")
			encryption
			;;
		"Signing")
			echo "Signing"
			;;
		"About")
			whiptail --msgbox "EasyPG © 2016 (MIT License) \n \nKevin Froman (https://ChaosWebs.net) \n \n\"Because GPG is too hard\"" 20 50
			;;
         "Quit")
			echo "Exiting"
			exit
			;;
         
        *)
esac

done

rm $INPUT
