#!/bin/bash -m

export LD_PRELOAD=$(dirname $0)/randpatch/randpatch.so
export USER=$(whoami) # Just in case it's not already set

# Get the editor, if its not set, set it as nano

if [ "$EDITOR" == "" ]; then
	EDITOR="nano";
fi

# List the users keys
listKeys() {
	gpg --list-keys | more
	sleep 1 # sleep for a few seconds so the user doesn't keep pressing enter into the main menu
}

# Encryption menu
encrypt() {
		mode=$(whiptail --menu --nocancel "Encrypt or Decrypt?" 15 20 5 "Encrypt" "" "Decrypt" "" "Return" "" 3>&1 1>&2 2>&3)
		
		if [ $mode == "Return" ]; then 
			return 
		fi

		filetext=$(whiptail --menu --nocancel "File Or Text?" 15 20 5 "File" "" "Text" "" "Return" "" 3>&1 1>&2 2>&3)

		if [ $filetext == "Return" ]; then 
			return 
		fi

		if [ $mode == "Encrypt" ]; then

			while [ 1 ]
			do
				recip=$(whiptail --inputbox --nocancel "Recipient id or name:" 15 20 3>&1 1>&2 2>&3)
				if [ "$recip" != "" ]; then
					break
				fi
			done

			$TEXTFILE=$(mktemp)

			$EDITOR $TEXTFILE

			whiptail --yesno "Do you want to sign your message?" 15 20
			if [ $? == 0 ]; then
				gpg -s -a -e -r $recip $TEXTFILE
			else
				gpg -a -e -r $recip $TEXTFILE
			fi

			clear

			echo -e "Encrypted text:\n"

			cat $TEXTFILE.asc
			echo ""
			echo "Press enter to continue"
			read

			shred $TEXTFILE
			rm $TEXTFILE
			rm $TEXTFILE.asc
		else
			touch /tmp/easypg-text-encrypted.txt
			$EDITOR /tmp/easypg-text.txt
		fi
		

}

new_user() {
    whiptail --msgbox "Looks like you haven't used GPG before. Welcome! Let's get you set up." 7 80
    gen_key
}

gen_key() {
    GPGSCRIPT=$(mktemp)
    echo -e "Key-Type: RSA\nSubkey-Type: RSA\nKey-Length: 4096\nSubkey-Length: 4096" > $GPGSCRIPT
    REALNAME=$(whiptail --inputbox "Please enter your full name." 10 60 ${USER^} 3>&1 1>&2 2>&3)
    if [ $? == 1 ]; then
	rm $GPGSCRIPT
	return
    fi
    EMAIL=$(whiptail --inputbox "Please enter your email address." 10 60 $USER@ 3>&1 1>&2 2>&3)
    if [ $? == 1 ]; then
	rm $GPGSCRIPT
	return
    fi
    COMMENT=$(whiptail --inputbox "Enter an optional comment for your key. For example, it could be your website or Keybase profile." 10 60 3>&1 1>&2 2>&3)
    if [ $? == 1 ]; then
	rm $GPGSCRIPT
	return
    fi
    echo -e "Name-Real: $REALNAME\nName-Email: $EMAIL" >> $GPGSCRIPT
    if [ "$COMMENT" != "" ];then echo Name-Comment: $COMMENT >> $GPGSCRIPT;fi
    echo -e "Expire-Date: 0" >> $GPGSCRIPT
    while true; do
        PASSPHRASE=$(whiptail --passwordbox "Please enter a password for your key." 10 60 3>&1 1>&2 2>&3)
        if [ "$PASSPHRASE" == "" ]; then whiptail --msgbox "Sorry, password can't be blank." 10 60;
            else PASSCHK=$(whiptail --passwordbox "Please reenter the password for your key." 10 60 3>&1 1>&2 2>&3)
            if [ "$PASSPHRASE" != "$PASSCHK" ]; then whiptail --msgbox "Sorry, passwords don't match." 10 60
                else break
            fi
        fi
    done
    echo "Passphrase: $PASSPHRASE" >> $GPGSCRIPT
    echo "%commit" >> $GPGSCRIPT
    if whiptail --yesno "Do you want to generate this key?\nName: $REALNAME\nEmail: $EMAIL\nComment: $COMMENT" 10 40;then gpg --batch --gen-key $GPGSCRIPT;fi
    rm -f $GPGSCRIPT
    sleep 1
}

# Main menu
main_menu() {
SELECTION=$(whiptail --menu --nocancel --notags "EasyPG - Main Menu" 15 30 5 "gen" "Generate Key" "list" "List Keys" "enc" "Encryption" "sign" "Signing" "exit" "Exit" 3>&1 1>&2 2>&3)
echo $SELECTION
case $SELECTION in
    "gen") 
        gen_key
	;;
    "list")
        listKeys
	;;
    "enc")
        encrypt
	;;
    "sign")
        echo TODO
	;;
    "about")
	whiptail --msgbox "EasyPG © 2016 (MIT License) \n \nKevin Froman (ChaosWebs.net) & Duncan X. Simpson (www.k7dxs.xyz) \n \n\"Because GPG is too hard\"" 20 50
        ;;
    "exit")
        exit
	;;
esac
sleep 1
}

if [ ! -d ~/.gnupg ]; then new_user;fi

while true; do main_menu; done
