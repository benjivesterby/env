#!/bin/bash

# Mac update / install function
function install_or_upgrade() {
    if brew ls --versions "$1" >/dev/null; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade "$1">/dev/null 2>&1
    else
        HOMEBREW_NO_AUTO_UPDATE=1 brew install "$1">/dev/null 2>&1
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
        echo 'Mode: Install Environment'
        if [[ "$OSTYPE" == "linux-gnu" ]] ; then
                echo "Installing neovim"
                sudo apt-get install neovim

                echo "Installing tmux"
                sudo apt-get install tmux
                
                which go>/dev/null 2>&1
                if [ $? -ne 0 ]; then
                        echo "Installing Go"
                        install_go "go1.14.linux-amd64.tar.gz" "/usr/local"
                fi

                echo "Installing Git Auto Completion"
                curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash>/dev/null 2>&1
        elif [[ "$OSTYPE" == "darwin"* ]] ; then

                echo '############################################'
                echo 'MAC Environment Installation'
                echo '############################################'

                # Checking for brew and installing
                # Check to see if Homebrew is installed, and install it if it is not
                # command from: https://gist.github.com/ryanmaclean/4094dfdbb13e43656c3d41eccdceae05
                command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; \
                /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }>/dev/null 2>&1

                echo "Updating brew"
                brew update>/dev/null 2>&1

                echo "Installing / Updating python"
                install_or_upgrade "python"

                echo "Installing / Updating wget"
                install_or_upgrade "wget"

                echo "Installing / Updating git"
                install_or_upgrade "git"

                echo "Installing / Updating neovim"
                install_or_upgrade "neovim"

                echo "Installing / Updating tmux"
                install_or_upgrade "tmux"

                echo "Installing / Updating gnupg"
                install_or_upgrade "gnupg"
                
                which go>/dev/null 2>&1
                if [ $? -ne 0 ]; then
                        echo "Installing Go"
                        install_go "go1.14.darwin-amd64.pkg" "/usr/local"
                fi

                echo "Installing Git Auto Completion"
                # Create the folder structure
                if [ -d ~/.zsh ]; then
                        rm -rf ~/.zsh
                fi

                mkdir -p ~/.zsh

                # Download the scripts
                echo 'Pulling Git Auto Completion Scripts'
                curl -o ~/.zsh/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash>/dev/null 2>&1
                curl -o ~/.zsh/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh>/dev/null 2>&1
                
                # Clear out auto complete cache
                if [ -d ~/.zcompdump ]; then
                        rm ~/.zcompdump
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

        echo "Installing powerline-go"
        go get -u github.com/justjanne/powerline-go

        echo '############################################'
        echo 'Installing Go Linters'
        echo '############################################'

        echo "Installing golint"
        go get -u golang.org/x/lint/golint

        echo "Installing ineffassign"
        go get -u github.com/gordonklaus/ineffassign

        echo "Installing misspell"
        go get -u github.com/client9/misspell/cmd/misspell

        echo "Installing errcheck"
        go get -u github.com/kisielk/errcheck

        echo "Installing gosec"
        go get -u github.com/securego/gosec/cmd/gosec

        echo 'Installing staticcheck'
        go get -u honnef.co/go/tools/cmd/staticcheck

        echo 'Setting up git global'
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
        git config --global core.hookspath ${HOME}/hooks
        git config --global core.editor "vim"

        # TODO: setup to pull latest for current branch in this folder if it exists
        folder="${HOME}/.tmux/plugins/tpm"
        if [ ! -d $folder ]; then
                # Remove the existing tpm installation if it exists and reinstall
                echo 'Installing tmux plugin manager'
                [ -e $folder ] && rm -rf $folder
                git clone https://github.com/tmux-plugins/tpm $folder
        fi

        # TODO: setup to pull latest for current branch in this folder if it exists
        folder="${HOME}/hooks"
        if [ ! -d $folder ]; then
                # Remove the existing Git Hooks installation if it exists and reinstall
                echo 'Installing GIT hooks'
                [ -e $folder ] && rm -rf $folder
                git clone https://github.com/benjivesterby/gogithooks $folder
        fi

        echo 'Installing vim-plug'
        curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim>/dev/null 2>&1

        # nf="./nerd-fonts"
        # if [ ! -d $nf ]; then
        #         echo "Cloning Nerd Fonts"
        #         git clone https://github.com/ryanoasis/nerd-fonts.git
        # fi
        
        # cd $nf
        # echo "Nerd Fonts: Checking out verion v2.1.0"
        # git checkout v2.1.0
        # echo "Nerd Fonts: Installing"
        # ./install.sh
        # cd ../

        pf="./fonts"
        if [ ! -d $pf ]; then
                git clone git@github.com:powerline/fonts.git
        fi
        echo 'Powerline Fonts: Installing'
        ./fonts/install.sh
else
        echo 'Mode: Update Environment'
fi

echo '############################################'
echo 'Global Environment Installation'
echo '############################################'

# override the environment settings

echo 'Updating nvim configuration'
cp -Rf ./nvim ~/.config/

echo 'VIM plugin installation'
nvim +'PlugInstall --sync' +qall +slient &> /dev/null

echo 'VIM-GO Install Binaries'
nvim +GoInstallBinaries +qall +slient &> /dev/null
nvim +GoUpdateBinaries +qall +slient &> /dev/null

echo 'Updating tmux configuration'
cp -f ./.tmux.conf ~/

echo 'Updating environment script'
cp -f ./.env.shared ~/
chmod +x ~/.env.shared

if [[ "$OSTYPE" == "linux-gnu" ]] ; then
        cp -f ./.env.bash ~/
        chmod +x ~/.env.bash

        if ! grep -q "source ~/.env.bash" ~/.bashrc; then
            echo "source ~/.env.bash" >> ~/.bashrc
        fi

        # Update the running terminal instance
        exec bash
elif [[ "$OSTYPE" == "darwin"* ]] ; then
        cp -f ./.env.darwin ~/
        chmod +x ~/.env.darwin

        if ! grep -q "source ~/.env.darwin" ~/.zshrc; then
            echo "source ~/.env.darwin" >> ~/.zshrc
        fi

        # Update the running terminal instance
        exec zsh
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

# if [ -f "~/.zshrc" ]; then
# 	# echo env loader to .zshrc here
# elif [ -f "~/.bashrc" ]; then
# 	# echo to bashrc here
# else 
# 	# echo to .profile here
# fi