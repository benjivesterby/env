#!/bin/bash

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

                echo "Installing / Updating neovim"
                brew reinstall neovim

                echo "Installing / Updating tmux"
                brew reinstall tmux

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

        # Remove the existing tpm installation if it exists and reinstall
        echo "Installing tmux plugin manager"
        folder="${HOME}/.tmux/plugins/tpm"
        [ -e $folder ] && rm -rf $folder
        git clone https://github.com/tmux-plugins/tpm $folder
fi

# override the environment settings
cp -Rf ./nvim ~/.config/
cp -f ./.tmux.conf ~/
cp -f ./.env ~/
chmod +x ~/.env

# if [ -f "~/.zshrc" ]; then
# 	# echo env loader to .zshrc here
# elif [ -f "~/.bashrc" ]; then
# 	# echo to bashrc here
# else 
# 	# echo to .profile here
# fi