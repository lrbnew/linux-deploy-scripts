#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 config script to              "
echo "* set global variables for init.sh and       "
echo "* setup.sh scripts                           "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# library files
LIBS='linuxkm.lib gitkm.lib'

# source function libraries
for lib in $LIBS; do
   [ -d "$LIBS_DIR" ] && { source "$LIBS_DIR/$lib" > /dev/null 2>&1 && echo "sourced: $LIBS_DIR/$lib" || echo "can't find: $LIBS_DIR/$lib"; } ||
                         { source "$lib" > /dev/null 2>&1 && echo "sourced: $lib" || echo "can't find: $lib"; }
done

# check to make sure script is being run as root
is_root && echo "root user detected, proceeding..." || die "\033[40m\033[1;31mERROR: root check FAILED (you must be root to use this script). Quitting...\033[0m\n"

####################################################
# EDIT THESE VARIABLES WITH YOUR INFO
USER_NAME='kmullaney' #Linux user you will/already use
REAL_NAME='Keegan Mullaney'
EMAIL_ADDRESS='keegan@kmauthorized.com'
SSH_KEY_COMMENT='kma server'
SSH_PORT='666' #set your own custom port number
WORDPRESS_DOMAIN='kmauthorized.com'
MIDDLEMAN_DOMAIN='keeganmullaney.com'
GITHUB_USER='keegoid' #your GitHub username
LIBS_DIR='includes' #where you put extra stuff

# OPTIONALLY, UPDATE THESE VARIABLES
# set software versions here
EPEL_VERSION='7-1'         # http://dl.fedoraproject.org/pub/epel/beta/7/x86_64/
REMI_VERSION='7'           # http://rpms.famillecollet.com/enterprise/
NGINX_VERSION='1.7.4'      # http://nginx.org/download/
OPENSSL_VERSION='1.0.1i'   # http://www.openssl.org/source/
ZLIB_VERSION='1.2.8'       # http://zlib.net/
PCRE_VERSION='8.35'        # http://www.pcre.org/
FRICKLE_VERSION='2.1'      # http://labs.frickle.com/files/
RUBY_VERSION='2.1.2'       # https://www.ruby-lang.org/en/downloads/

# programs to install
# use " " as delimiter
REQUIRED_PROGRAMS='wget man lynx'
WORKSTATION_PROGRAMS='gedit k3b ntfs-3g git'
SERVER_PROGRAMS=''

# what services, TCP and UDP ports we allow from the Internet
# use " " as delimiter
SERVICES='http https smtp imaps pop3s ftp ntp'
TCP_PORTS="$SSH_PORT"
UDP_PORTS=''

# whitelisted IPs (Cloudflare)
TRUSTED_IPV4_HOSTS="199.27.128.0/21 \
173.245.48.0/20 \
103.21.244.0/22 \
103.22.200.0/22 \
103.31.4.0/22 \
141.101.64.0/18 \
108.162.192.0/18 \
190.93.240.0/20 \
188.114.96.0/20 \
197.234.240.0/22 \
198.41.128.0/17 \
162.158.0.0/15 \
104.16.0.0/12"

TRUSTED_IPV6_HOSTS="2400:cb00::/32 \
2606:4700::/32 \
2803:f800::/32 \
2405:b500::/32 \
2405:8100::/32"
####################################################

# upstream project names
UPSTREAM_PROJECT='linux-deploy-scripts'
MM_UPSTREAM_PROJECT='middleman-html5-foundation'

# init
DROPBOX=false

# use Dropbox?
echo
echo "Do you wish to use Dropbox for your repositories?"
select yn in "Yes" "No"; do
   case $yn in
      "Yes") DROPBOX=true;;
       "No") break;;
          *) echo "case not found..."
   esac
   break
done
