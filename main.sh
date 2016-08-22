#!/bin/bash

export LD_PRELOAD=$(dirname $0)/randpatch/randpatch.so
export USER=$(whoami) # Just in case it's not already set

new_user() {
    whiptail --msgbox "Looks like you haven't used GPG before. Welcome! Let's get you set up." 7 80
    gen_key
}

gen_key() {
    GPGSCRIPT=$(mktemp)
    echo -e "Key-Type: RSA\nSubkey-Type: RSA\nKey-Length: 4096\nSubkey-Length: 4096" > $GPGSCRIPT
    REALNAME=$(whiptail --inputbox "Please enter your full name." 10 60 ${USER^} 3>&1 1>&2 2>&3)
    EMAIL=$(whiptail --inputbox "Please enter your email address." 10 60 $USER@ 3>&1 1>&2 2>&3)
    COMMENT=$(whiptail --inputbox "Enter an optional comment for your key. For example, it could be your website or Keybase profile." 10 60 3>&1 1>&2 2>&3)
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
        echo TODO
	;;
    "enc")
        echo TODO
	;;
    "sign")
        echo TODO
	;;
    "exit")
        exit
	;;
esac
sleep 1
}

if [ ! -d ~/.gnupg ]; then new_user;fi

while true; do main_menu; done
