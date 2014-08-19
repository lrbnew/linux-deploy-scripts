#!/bin/bash
echo "*********************************************"
echo "* A CentOS 7.0 x64 deployment script to      "
echo "* install Middleman and dependencies         "
echo "*                                            "
echo "* Author : Keegan Mullaney                   "
echo "* Company: KM Authorized LLC                 "
echo "* Website: http://kmauthorized.com           "
echo "*                                            "
echo "* MIT: http://kma.mit-license.org            "
echo "*********************************************"

# install Ruby and RubyGems
read -p "Press enter to install ruby and rubygems..."
if ruby -v | grep -q "ruby $RUBY_VERSION"; then
   echo "ruby is already installed"
else
   curl -L https://get.rvm.io | bash -s stable --ruby=$RUBY_VERSION
fi

# start using rvm
echo
read -p "Press enter to start using rvm..."
if cat /home/$USER_NAME/.bashrc | grep -q "/usr/local/rvm/scripts/rvm"; then
   echo "already added rvm to .bashrc"
else
   echo "source /usr/local/rvm/scripts/rvm" >> /home/$USER_NAME/.bashrc
   source /usr/local/rvm/scripts/rvm && echo "rvm sourced and added to .bashrc"
fi

# update gems
echo
read -p "Press enter to update gems..."
gem update

echo
read -p "Press enter to update the gem package manager..."
gem update --system

# install Node.js for running the local web server and npm for the CLI
if rpm -qa | grep -q nodejs; then
   echo "nodejs was already installed"
else
   echo
   read -p "Press enter to install nodejs and npm..."
   yum --enablerepo=epel -y install nodejs npm
fi

# install Middleman
if $(gem list middleman -i); then
   echo "middleman gem already installed"
else
   echo
   read -p "Press enter to install middleman..."
   gem install middleman
fi

# Middleman web root
#mkdir -pv /var/www/$MIDDLEMAN_DOMAIN/public_html
#chown -R $USER_NAME:$USER_NAME /var/www/$MIDDLEMAN_DOMAIN
#echo "set permissions to $USER_NAME"

# Middleman repository location
MM_REPOS="/home/$USER_NAME/repos"
if [ -d $HOME/Dropbox ]; then
   MM_REPOS=$REPOS
fi

# make and change to repos directory
mkdir -pv $MM_REPOS
cd $MM_REPOS
echo "changing directory to $_"

# generate a blog template for Middleman
if [ -d "$MM_REPOS/$MIDDLEMAN_DOMAIN" ]; then
   echo "$MIDDLEMAN_DOMAIN directory already exists, skipping clone operation..."
else
   echo
   echo "Before proceeding, make sure to fork $MIDDLEMAN_UPSTREAM"
   echo "and change the project name to $MIDDLEMAN_DOMAIN on GitHub"
   read -p "Press enter to clone $MIDDLEMAN_DOMAIN from GitHub..."
   echo
   echo "Do you wish to clone using HTTPS or SSH (recommended)?"
   select hs in "HTTPS" "SSH"; do
      case $hs in
         "HTTPS") git clone https://github.com/$GITHUB_USER/$MIDDLEMAN_DOMAIN.git;;
           "SSH") git clone git@github.com:$GITHUB_USER/$MIDDLEMAN_DOMAIN.git;;
               *) echo "case not found..."
      esac
      break
   done
   # TODO: give user option to start from a fresh Middleman app
   #middleman init ${MIDDLEMAN_DOMAIN%.*} --template=html5
   #middleman init ${MIDDLEMAN_DOMAIN%.*} --template=blog
fi

# change to newly cloned directory
cd $MIDDLEMAN_DOMAIN
echo "changing directory to $_"

# assign the original repository to a remote called "upstream"
if git config --list | grep -q $MIDDLEMAN_UPSTREAM; then
   echo "upstream repo already configured: https://github.com/$MIDDLEMAN_UPSTREAM"
else
   echo
   read -p "Press enter to assign upstream repository..."
   git remote add upstream https://github.com/$MIDDLEMAN_UPSTREAM && echo "remote upstream added for https://github.com/$MIDDLEMAN_UPSTREAM"
fi

# pull in changes not present local repository, without modifying local files
echo
read -p "Press enter to fetch changes from upstream repository..."
git fetch upstream
echo "upstream fetch done"

# merge any changes fetched into local working files
echo
read -p "Press enter to merge changes..."
git merge upstream/master

# add middleman-syntax extension to Gemfile
if cat Gemfile | grep -q "middleman-syntax"; then
   echo "middleman-syntax extension already added"
else
   echo
   read -p "Press enter to configure the Gemfile..."
   echo '# Ruby based syntax highlighting utilizing Rouge' >> Gemfile
   echo 'gem "middleman-syntax"' >> Gemfile
   echo "middleman-syntax added to Gemfile"
fi 

# set permissions
echo
read -p "Press enter to change to set permissions..."
chown -R $USER_NAME:$USER_NAME $MM_REPOS
echo "set permissions on $MM_REPOS to $USER_NAME"

# update gems
echo
read -p "Press enter to update gems..."
gem update

echo "done with middleman.sh"

