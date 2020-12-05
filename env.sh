#!/bin/bash

goversion=1.15.6

checkgov() {
	go version | grep $goversion
}

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

	sudo rm -rf $s
        sudo installer -pkg ./$1 -target /
	rm ./$1
}

# Install Go into the correct directory
function install_go_linux() {
        wget https://dl.google.com/go/$1

	sudo rm -rf $s
        sudo mkdir -p $2
        sudo tar -C $2 -xzf $1
	rm ./$1
}

function check() {
	if [ $1 -ne 0 ]; then
		exit 0
	fi
}

wd=$(pwd)

if [[ "$1" == "-i" ]]
then

        echo 'Mode: Install Environment'
        if [[ "$OSTYPE" == "linux-gnu" ]] ; then
                echo '############################################'
                echo 'Linux Environment Installation'
                echo '############################################'

		# update the symbols file so that it's the right
		# control button that swaps with capslock
        	echo 'updating caps-swap with RCTRL'
		sudo cp ./ctrl /usr/share/X11/xkb/symbols

        	echo 'apt-get update'
		sudo apt-get update
		check $?
	
		echo "Installing pre-reqs"

		sudo add-apt-repository ppa:nm-l2tp/network-manager-l2tp

                sudo apt-get install net-tools nscd resolvconf neovim tmux nodejs \
		npm autotools-dev ecryptfs-utils cryptsetup \
		ng-common gcc g++ make fonts-powerline python3 python3-pip curl \
		powerline-gitstatus tree kazam nmap graphviz network-manager-l2tp \
		network-manager-l2tp-gnome gnupg2 gnupg-agent scdaemon pcscd bolt

		check $?

                which go>/dev/null
                if [ $? -ne 0 ]; then
                        echo "Installing Go"
                        install_go_linux "go$goversion.linux-amd64.tar.gz" "/usr/local"
			check $?
                fi

		checkgov
                if [ $? -ne 0 ]; then
			echo "Upgrading Go"
			sudo rm -rf /usr/local/go
                        install_go_linux "go$goversion.linux-amd64.tar.gz" "/usr/local"
			check $?
		fi

                echo "Installing Git Auto Completion"
                curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash>/dev/null

		echo "Yarn installation"
		curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --nightly

		echo "Setting gpg2 as default GIT gpg handler"
        	git config --global gpg.program gpg2 


		##### DOCKER INSTALLATION / Configuration
		echo "INSTALLING DOCKER"
		sudo apt-get install \
    			apt-transport-https \
    			ca-certificates \
    			curl \
    			gnupg-agent \
    			software-properties-common

		curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

		sudo add-apt-repository \
   			"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   			$(lsb_release -cs) \
   			stable"

		sudo apt-get update

		sudo apt-get install docker-ce docker-ce-cli containerd.io

		sudo groupadd docker

		sudo usermod -aG docker $USER

		sudo systemctl enable docker

		echo 'Upgrading pynvim support'
		sudo pip3 install --upgrade pip3
		sudo pip3 install --upgrade pynvim

        elif [[ "$OSTYPE" == "darwin"* ]] ; then

                echo '############################################'
                echo 'MAC Environment Installation'
                echo '############################################'

                # Checking for brew and installing
                # Check to see if Homebrew is installed, and install it if it is not
                # command from: https://gist.github.com/ryanmaclean/4094dfdbb13e43656c3d41eccdceae05
                command -v brew >/dev/null 2>&1 || { echo >&2 "Installing Homebrew Now"; \ /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"; }>/dev/null 2>&1 
                echo "Updating brew"
                brew update>/dev/null 2>&1

                echo "Installing / Updating python"
                install_or_upgrade "python"

                echo "Installing / Updating python3"
                install_or_upgrade "python3"

                echo "Installing / Updating pip"
                install_or_upgrade "pip"

                echo "Installing / Updating pip3"
                install_or_upgrade "pip3"

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

                echo "Installing / Updating tree"
                install_or_upgrade "tree"

                echo "Installing / Updating pbcopy"
                install_or_upgrade "pbcopy"

                echo "Installing / Updating graphviz"
                install_or_upgrade "graphviz"
                
                which go>/dev/null
                if [ $? -ne 0 ]; then
                        echo "Installing Go"
                        install_go "go$goversion.darwin-amd64.pkg" "/usr/local"
                fi

		checkgov
                if [ $? -ne 0 ]; then
			echo "Upgrading Go"
			sudo rm -rf /usr/local/go
                        install_go "go$goversion.darwin-amd64.pkg" "/usr/local"
			check $?
		fi

                echo "Installing Git Auto Completion"
                # Create the folder structure
                if [ -d ~/.zsh ]; then
                        sudo rm -rf ~/.zsh
                fi

                mkdir -p ~/.zsh

                # Download the scripts
                echo 'Pulling Git Auto Completion Scripts'
                curl -o ~/.zsh/git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash>/dev/null 2>&1
                curl -o ~/.zsh/_git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh>/dev/null 2>&1
                
                # Clear out auto complete cache
                if [ -d ~/.zcompdump ]; then
                        sudo rm ~/.zcompdump
                fi

		echo 'Upgrading pynvim support'
		pip install --user --upgrade pip
		pip install --user --upgrade pynvim


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

        folder="${HOME}/bin"
        if [ ! -d $folder ]; then
		echo "Creating ~/bin directory"
		mkdir $folder
        fi
        echo '############################################'
        echo 'Installing Go Linters'
        echo '############################################'

        echo "Installing golint"
	sudo rm -rf ~/go/src/golang.org/x/lint
        go get -u golang.org/x/lint/...

        echo 'Installing staticcheck'
	sudo rm -rf ~/go/src/honnef.co/go/tools
        go get -u honnef.co/go/tools/...
	
        echo "Installing go tools"
	sudo rm -rf ~/go/src/golang.org/x/tools
	go get -u golang.org/x/tools/...

        echo "Installing gopsutil"
	sudo rm -rf ~/go/src/github.com/shirou/gopsutil
	go get -u github.com/shirou/gopsutil

        echo "Installing ineffassign"
	sudo rm -rf ~/go/src/github.com/gordonklaus/ineffassign
        go get -u github.com/gordonklaus/ineffassign

        echo "Installing misspell"
	sudo rm -rf ~/go/src/github.com/client9/misspell
        go get -u github.com/client9/misspell/...

        echo "Installing errcheck"
	sudo rm -rf ~/go/src/github.com/kisielk/errcheck
        go get -u github.com/kisielk/errcheck

        echo "Installing gosec"
	sudo rm -rf ~/go/src/github.com/securego/gosec
        go get -u github.com/securego/gosec/...

        echo "Installing powerline-go"
	sudo rm -rf ~/go/src/github.com/justjanne/powerline-go
        go get -u github.com/justjanne/powerline-go

        echo 'Setting up git global'
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
        git config --global core.hookspath ${HOME}/hooks
        git config --global core.editor "vim"
	git config --global rerere.enabled true
	git config --global pull.rebase true

        folder="${HOME}/.tmux/plugins/tpm"
        if [ ! -d $folder ]; then
                # Remove the existing tpm installation if it exists and reinstall
                echo 'Installing tmux plugin manager'
                [ -e $folder ] && rm -rf $folder
                git clone https://github.com/tmux-plugins/tpm $folder &> /dev/null
	else
		echo 'Updating tmux plugin manager *master* branch'
		cd $folder
		git pull origin master &> /dev/null
		cd $wd
        fi

	file="${HOME}/.local/share/nvim/site/autoload/plug.vim" 
	if [ ! -f $file ]; then
        	echo 'Installing vim-plug'
	        curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim>/dev/null 2>&1
	fi

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
		echo 'Cloning fonts'
                git clone git@github.com:powerline/fonts.git &> /dev/null
	else
		echo 'Updating fonts *master* branch'
		cd $pf
		git pull origin master &> /dev/null
		cd $wd
        fi

	echo 'Powerline Fonts: Installing'
        ./fonts/install.sh
	
	if [ ! -d ~/.fzf ]; then
		echo 'Cloning fzf plugin'
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	else
		echo 'Updating fzf plugin repository'
		cd ~/.fzf 
		git pull origin master
		cd $wd
	fi

	echo 'Executing fzf plugin installer'
	~/.fzf/install --all

else
        echo 'Mode: Update Environment'
fi

echo '############################################'
echo 'Global Environment Installation'
echo '############################################'

folder="${HOME}/hooks"
if [ ! -d $folder ]; then
        # Remove the existing Git Hooks installation if it exists and reinstall
        echo 'Installing GIT hooks'
        [ -e $folder ] && rm -rf $folder
        git clone https://github.com/devnw/hooks $folder &> /dev/null
else
	echo 'Updating hooks *master* branch'
	cd $folder
	git pull origin master &> /dev/null
	cd $wd
fi


# override the environment settings
diff -r ./nvim/ ~/.config/nvim/ &> /dev/null
if [ $? -ne 0 ]; then
	echo 'Updating nvim configuration'
	cp -Rf ./nvim ~/.config/

	echo 'VIM plugin installation'
	nvim +'PlugInstall --sync' +qall &> /dev/null
fi

echo 'VIM-GO Install / Update Binaries'
nvim +GoInstallBinaries +qall &> /dev/null
nvim +GoUpdateBinaries +qall &> /dev/null

cp -f ./bin/* ~/bin

diff ./.tmux.conf ~/.tmux.conf&> /dev/null
if [ $? -ne 0 ]; then
	echo 'Updating tmux configuration'
	cp -f ./.tmux.conf ~/
fi

diff ./.env.shared ~/.env.shared&> /dev/null
if [ $? -ne 0 ]; then
	echo 'Updating environment script'
	cp -f ./.env.shared ~/
	chmod +x ~/.env.shared
fi

# NODE installs
#echo "Installing Typescript and Angular CLI"
#sudo npm install -g typescript@latest
#sudo npm install typescript@latest --save-dev
#sudo npm uninstall -g @angular/cli
#sudo npm install -g @angular/cli@latest

if [[ "$OSTYPE" == "linux-gnu" ]] ; then
	diff ./.env.bash ~/.env.bash&> /dev/null
	if [ $? -ne 0 ]; then
		echo "Updating .env.bash"
	        cp -f ./.env.bash ~/
        	chmod +x ~/.env.bash

        	if ! grep -q "source ~/.env.bash" ~/.bashrc; then
	            echo "source ~/.env.bash" >> ~/.bashrc
        	fi
	fi

        # Update the running terminal instance
        exec bash
elif [[ "$OSTYPE" == "darwin"* ]] ; then
	diff ./.env.darwin ~/.env.darwin&> /dev/null
	if [ $? -ne 0 ]; then
		echo "Updating .env.darwin"
        	cp -f ./.env.darwin ~/
        	chmod +x ~/.env.darwin

        	if ! grep -q "source ~/.env.darwin" ~/.zshrc; then
        	    echo "source ~/.env.darwin" >> ~/.zshrc
        	fi
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
