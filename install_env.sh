#!/bin/bash

# Mac update / install function
function install_or_upgrade() {
    if brew ls --versions "$1" >/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "$1"
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew install "$1"
    fi
}

# Install Go into the correct directory
function install_go() {
        wget https://dl.google.com/go/$1
        mkdir -p $2
        tar -C $2 -xzf $1
}

# UPSTREAM=${1:-'@{u}'}
# LOCAL=$(git rev-parse @)
# REMOTE=$(git rev-parse "$UPSTREAM")
# BASE=$(git merge-base @ "$UPSTREAM")

# if [ $LOCAL = $REMOTE ]; then
#     echo "Environment Up To Date"
# elif [ $LOCAL = $BASE ]; then
#         echo "Pull master env"
#         git pull origin master
# elif [ $REMOTE = $BASE ]; then
#     echo "Need to push"
# else
#     echo "Diverged"
# fi

if [[ "$1" == "-i" ]]
then

        if [[ "$OSTYPE" == "linux-gnu" ]] ; then
                echo "Installing neovim"
                sudo apt-get install neovim

                echo "Installing tmux"
                sudo apt-get install tmux
        elif [[ "$OSTYPE" == "darwin"* ]] ; then

                # Checking for brew and installing
                # Check to see if Homebrew is installed, and install it if it is not
                # command from: https://gist.github.com/ryanmaclean/4094dfdbb13e43656c3d41eccdceae05
                command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; \
                /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }

                echo "Updating brew"
                brew update

                echo "Installing / Updating wget"
                install_or_upgrade "wget"

                echo "Installing / Updating neovim"
                install_or_upgrade "neovim"

                echo "Installing / Updating tmux"
                install_or_upgrade "tmux"

                echo "Installing / Updating gnupg"
                install_or_upgrade "gnupg"
                
                which go>/dev/null 2>&1
                if [ $? -ne 0 ]; then
                        echo "Installing Go"
                        install_go "go1.14.linux-amd64.tar.gz" "/usr/local"
                fi

        elif [[ "$OSTYPE" == "cygwin" ]] ; then
                # POSIX compatibility layer and Linux environment emulation for Windows
                echo $OSTYPE
        elif [[ "$OSTYPE" == "msys" ]] ; then
                # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
                echo $OSTYPE
        elif [[ "$OSTYPE" == "win32" ]] ; then
                # I'm not sure this can happen.
                echo $OSTYPE
        elif [[ "$OSTYPE" == "freebsd"* ]] ; then
                # ...
                echo $OSTYPE
        else
                # Unknown.
                echo $OSTYPE
        fi


        folder="${HOME}/.tmux/plugins/tpm"
        if [ ! -d $folder ]; then
                # Remove the existing tpm installation if it exists and reinstall
                echo "Installing tmux plugin manager"
                [ -e $folder ] && rm -rf $folder
                git clone https://github.com/tmux-plugins/tpm $folder
        fi

        folder="${HOME}/hooks"
        if [ ! -d $folder ]; then
                # Remove the existing Git Hooks installation if it exists and reinstall
                echo "Installing GIT hooks"
                [ -e $folder ] && rm -rf $folder
                git clone https://github.com/benjivesterby/gogithooks $folder
        fi
fi

# override the environment settings
cp -Rf ./nvim ~/.config/
cp -f ./.tmux.conf ~/
cp -f ./.env ~/
chmod +x ~/.env

vim +PlugInstall
vim +GoInstallBinaries

# if [ -f "~/.zshrc" ]; then
# 	# echo env loader to .zshrc here
# elif [ -f "~/.bashrc" ]; then
# 	# echo to bashrc here
# else 
# 	# echo to .profile here
# fi