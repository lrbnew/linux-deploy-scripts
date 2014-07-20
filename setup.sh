#!/bin/bash
echo "*********************************************"
echo "* A CentOS 6.5 deployment script.            "
echo "* Updates Linux, installs LEMP stack,        "
echo "* configures Nginx with ngx_cache_purge and  "
echo "* installs WordPress and/or Middleman        "
echo "* --by Keegan Mullaney                       "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*                                            "
echo "* I would like to thank nixCraft at:         "
echo "* http://www.cyberciti.biz/faq               "
echo "* for providing many clear and useful code   "
echo "* examples.                                  "
echo "*                                            "
echo "* ---run instructions---                     "
echo "* set execute permissions on this script:    "
echo "* chmod +x setup.sh                          "
echo "*                                            "
echo "* if coming from Windows:                    "
echo "* dos2unix -k setup.sh                       "
echo "*********************************************"

# set new Linux user name, SSH port number and website domain name
REAL_NAME='Keegan Mullaney'
USER_NAME='Keegan'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_PORT='22'
WORDPRESS_DOMAIN='kmauthorized.com'
MIDDLEMAN_DOMAIN='keeganmullaney.com'

# set software versions to latest
NGINX_VERSION='1.7.2'
OPENSSL_VERSION='1.0.1h'
PCRE_VERSION='8.35'
ZLIB_VERSION='1.2.8'
FRICKLE_VERSION='2.1'
RUBY_VERSION='2.1.2'

# set variable defaults
SERVER_GO=false
WORKSTATION_GO=false
SSH_GO=false
FIREWALL_GO=false
ALIASES_GO=false
LINUX_UPDATE_GO=false
LEMP_GO=false
WORDPRESS_GO=false
MIDDLEMAN_GO=false
NGINX_CONFIG_GO=false
SWAP_GO=false

# run script as sudo after removing DOS line breaks
# takes name of script to be run as first argument
# source the script to be run so it can access local variables
RunScript()
{
   # make sure dos2unix is installed
   hash dos2unix 2>/dev/null || { echo >&2 "dos2unix will be installed."; yum -y install dos2unix; }
   RUN_FILE="scripts/$1"
   dos2unix -k $RUN_FILE && echo "carriage returns removed"
   chmod +x $RUN_FILE && echo "execute permissions set"
   read -p "Press enter to run: $RUN_FILE"
   sudo . ./$RUN_FILE
}

# collect user inputs to determine which sections of this script to execute
echo
echo "Is this a server or workstation deployment?"
select sw in "Server" "Workstation"; do
   case $sw in
           "Server") SERVER_GO=true;;
      "Workstation") WORKSTATION_GO=true;;
                  *) echo "case not found, exiting..."
                     exit 0;;
   esac
   break
done

# both servers and workstations need SSH, a firewall and EPEL
echo
echo "Do you wish to configure SSH?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") SSH_GO=true;;
       "No") break;;
          *) echo "case not found";;
   esac
   break
done
echo
echo "Do you wish to run the firewall script?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") FIREWALL_GO=true;;
       "No") break;;
          *) echo "case not found";;
   esac
   break
done
echo
echo "Do you wish to add useful bash shell aliases for new SSH user?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") ALIASES_GO=true;;
       "No") break;;
          *) echo "case not found";;
   esac
   break
done
echo
echo "Do you wish to update Linux and install basic programs?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") LINUX_UPDATE_GO=true;;
       "No") break;;
          *) echo "case not found";;
   esac
   break
done

if $SERVER_GO; then
   echo
   echo "Do you wish to install the LEMP stack?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") LEMP_GO=true
          "No") break;;
             *) echo "case not found";;
      esac
      break
   done
   echo
   echo "Do you wish to install WordPress?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") WORDPRESS_GO=true;;
          "No") break;;
             *) echo "case not found";;
      esac
      break
   done
   echo
   echo "Do you wish to configure Nginx?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") NGINX_CONFIG_GO=true;;
          "No") break;;
             *) echo "case not found";;
      esac
      break
   done
   echo
   echo "Do you wish to add a swap file?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") SWAP_GO=true;;
          "No") break;;
             *) echo "case not found";;
      esac
      break
   done
fi

if $WORKSTATION_GO; then
   echo
   echo "Do you wish to install Middleman and deploy to BitBalloon?"
   select yn in "Yes" "No"; do
      case $yn in
         "Yes") MIDDLEMAN_GO=true;;
          "No") break;;
             *) echo "case not found";;
      esac
      break
   done
fi

echo
echo "********************************"
echo "SECTION 1: USERS & SECURITY     "
echo "********************************"
echo 

if $SSH_GO; then
   if $SERVER_GO; then
      # set SSH port and client alive interval so SSH session doesn't quit so fast, add public SSH key and restrict root user access
      RunScript server_ssh.sh
   elif $WORKSTATION_GO; then
      # generate new SSH key pair if none exist and start the SSH-agent
      RunScript workstation_ssh.sh
   fi
else
   echo "skipping SSH..."
fi

if $FIREWALL_GO; then
   if $SERVER_GO; then
      # includes web server firewall rules
      RunScript server_firewall.sh
   elif $WORKSTATION_GO; then
      # workstation firewall rules
      RunScript workstation_firewall.sh
   fi
else
   echo "skipping firewall..."
fi

if $ALIASES_GO; then
   # add useful aliases for new SSH user
   RunScript aliases.sh
else
   echo "skipping aliases..."
fi

echo
echo "********************************"
echo "SECTION 2: INSTALLS & UPDATES   "
echo "********************************"
echo 

if $LINUX_UPDATE_GO; then
   # LINUX (L)
   RunScript linux_update.sh
else
   echo "skipping Linux update..."
fi

echo
echo "********************************"
echo "SECTION 3: LEMP                 "
echo "********************************"
echo

if $LEMP_GO; then 
   # NGINX (E), MYSQL (M), PHP (P)
   RunScript lemp.sh
else
   echo "skipping LEMP install..."
fi

echo
echo "********************************"
echo "SECTION 4: WEBSITE PLATFORMS    "
echo "********************************"
echo

if $WORDPRESS_GO; then
   # install WordPress and its MySql database
   RunScript wordpress_install.sh
else
   echo "skipping WordPress install..."
fi

if $MIDDLEMAN_GO; then
   # install Ruby, RubyGems, Middleman, Redcarpet and Rouge
   RunScript middleman.sh
else
   echo "skipping Middleman install..."
fi

echo
echo "********************************"
echo "SECTION 5: NGINX CONFIG         "
echo "********************************"
echo 

if $NGINX_CONFIG_GO; then
   # configure nginx with fastcgi_cache and cache purging
   RunScript nginx_config.sh
else
   echo "skipping nginx config..."
fi

echo
echo "********************************"
echo "SECTION 6: ADDITIONAL SETTINGS  "
echo "********************************"
echo

if $SWAP_GO; then
   # add swap to CentOS 6
   RunScript swap.sh
fi

if $LINUX_GO; then
   # display the list of repositories
   read -p "Press enter to view the repository list..."
   yum repolist
fi

if $DEFAULT_NGINX_GO || $CUSTOM_NGINX_GO; then
   # get public IP
   echo
   echo "go to this IP address to confirm nginx is working:"
   ifconfig eth0 | grep --color inet | awk '{ print $2 }'
fi

if [ -a /var/www/$WORDPRESS_DOMAIN/public_html/testphp.php ]; then
   # another way to get public IP
   PUBLIC_IP=$(curl http://ipecho.net/plain)
   echo
   echo "Go to http://$PUBLIC_IP/testphp.php to test the web server."
fi

if $SERVER_GO && $SSH_GO; then
   echo
   echo "edit configuresudoers.sh with your Linux username for SSH access and run it to finish server setup"
fi
