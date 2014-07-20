#!/bin/bash
echo "*********************************************"
echo "* A CentOS 6.5 deployment script to          "
echo "* generate a new SSH key pair if none        "
echo "* exists and start the SSH-agent             "
echo "* --by Keegan Mullaney                       "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# check if user exists
read -p "Press enter to check if user $USER_NAME exists"
egrep -i "^$USER_NAME" /etc/passwd
if [ $? -eq 0 ]; then
   SSH_FILE="$HOME/.ssh/id_rsa"
   read -p "Press enter to check if id_rsa exists for $USER_NAME"
   if [ -e $SSH_FILE ]; then
      echo "$SSH_FILE already exists for $USER_NAME"
   else
      # create a new ssh key using the provided email as a label
      read -p "Press enter to generate a new SSH key for ${EMAIL_ADDRESS}"
      ssh-keygen -b 4096 -t rsa -C ${EMAIL_ADDRESS}
      echo "SSH key generated"
      
      # edit .bash_profile to start keychain automatically
      read -p "Press enter to check if keychain has been added to .bash_profile for $USER_NAME"
      if grep -Fxq "keychain" $HOME/.bash_profile; then
         echo "Keychain already added to .bash_profile"
      else
         cat << 'EOF' >> $HOME/.bash_profile
### START-Keychain ###
# restart ssh-agent between logins
/usr/bin/keychain $HOME/.ssh/id_rsa
source $HOME/.keychain/$HOSTNAME-sh
### End-Keychain ###
EOF
         echo "$HOME/.bash_profile was updated"
         read -p "Press enter to print .bash_profile"
         cat $HOME/.bash_profile
         echo
         echo "copy contents of id_rsa.pub to remote server (Github)"
      fi
   fi
else
   echo "user $USER_NAME doesn't exist, create user $USER_NAME before configuring SSH"
fi
echo
echo "done with workstation_ssh.sh"

