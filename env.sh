#!/bin/bash

goversion=1.19.4

checkgov() {
	go version | grep $goversion
}

wd=$(pwd)

echo "Updating GVM"
curl -L https://github.com/devnw/gvm/releases/download/latest/gvm > "$HOME"/bin/gvm && chmod +x "$HOME"/bin/gvm

if [[ "$1" == "-i" ]]
then

        echo 'Mode: Install Environment'
        if [[ "$OSTYPE" == "linux"* ]] ; then
                echo '############################################'
                echo 'Linux Environment Installation'
                echo '############################################'

                sudo apt-get update
                sudo apt-get install -y apt-transport-https \
    			ca-certificates \
    			curl \
    			gnupg2 gnupg-agent \
    			software-properties-common

		echo 'adding correct repository for git'
		sudo add-apt-repository -y ppa:git-core/ppa

		# update the symbols file so that it's the right
		# control button that swaps with capslock
        	# echo 'updating caps-swap with RCTRL'
		# sudo cp ./ctrl /usr/share/X11/xkb/symbols

                # 1. Install our official public software signing key
                wget -O- https://updates.signal.org/desktop/apt/keys.asc | gpg --dearmor > signal-desktop-keyring.gpg
                cat signal-desktop-keyring.gpg | sudo tee /usr/share/keyrings/signal-desktop-keyring.gpg > /dev/null

                echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main' | sudo tee /etc/apt/sources.list.d/signal-xenial.list

                # Adding Go Releaser
                echo 'deb [trusted=yes] https://repo.goreleaser.com/apt/ /' | sudo tee /etc/apt/sources.list.d/goreleaser.list

                echo "Adding Docker repository"
                curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
                echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
                sudo apt update
                apt-cache policy docker-ce

                echo "Adding Terraform repository"
                curl https://apt.releases.hashicorp.com/gpg | gpg --dearmor > hashicorp.gpg
                sudo install -o root -g root -m 644 hashicorp.gpg /etc/apt/trusted.gpg.d/
                sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com focal main"
	
		echo "Installing pre-reqs"

                wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

		# Activate NVM as part of the current run
		export NVM_DIR="$HOME/.nvm"
		[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
		[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
		source ~/.bashrc

                nvm install --lts

		sudo add-apt-repository -y ppa:nm-l2tp/network-manager-l2tp

                sudo add-apt-repository -y ppa:wireshark-dev/stable

        	echo 'apt-get update'
		if ! sudo apt-get -y update; then
                        echo 'apt-get update failed'
                        exit 0
                fi

                if ! sudo apt-get install -y net-tools nscd resolvconf neovim tmux \
                autotools-dev ecryptfs-utils cryptsetup \
		ng-common gcc g++ make python3 python3-pip \
                tree kazam nmap graphviz network-manager-l2tp \
		network-manager-l2tp-gnome scdaemon pcscd \
                bolt shellcheck xclip libpam-u2f docker-ce docker-ce-cli \
                containerd.io terraform build-essential linux-headers-generic \
                make clang llvm libelf-dev libpcap-dev wireguard \
                yubikey-luks signal-desktop tcpdump wireshark goreleaser \
		gcc-9-arm-linux-gnueabi gcc-9-arm-linux-gnueabihf docker-compose \
                unattended-upgrades apt-listchanges setserial cu screen putty \
                minicom zsh jq pre-commit lua-nvim; then
                        echo 'apt-get install failed'
                        exit 0
                fi


                if ! sudo dpkg-reconfigure -plow unattended-upgrades; then
                        echo 'dpkg-reconfigure failed'
                        exit 0
                fi

                if ! sudo cp ./50unattended-upgrades /etc/apt/apt.conf.d/; then
                        echo 'Auto upgrade configuration failed'
                        exit 0
                fi
		
		if ! sudo usermod -aG wireshark "$USER"; then
                        echo 'wireshark usermod failed'
                fi

                # unable to find libbpf-dev 

                if ! sudo apt-get install -y gnome-keyring; then #https://github.com/microsoft/vscode-docker/issues/1515
                        echo 'gnome-keyring install failed'
                fi

                echo "Adding GH CLI Repository"
                if ! sudo snap install gh; then
                        echo 'github CLI install failed'
                fi

                if ! grep -q "AddKeysToAgent yes" ~/.ssh/config; then
                        echo "Adding 'AddKeysToAgent yes' to ~/.ssh/config"
			sed -i '1s/^/AddKeysToAgent yes\n/' ~/.ssh/config
                fi

                if [[ "$2" == "wsl" ]]
                then
                        sudo apt-get install -y socat
                        if [ ! -d ~/.ssh ]; then
                                mkdir ~/.ssh
                        fi

                        if [ ! -f ~/.ssh/wsl2-ssh-pageant.exe ]; then
                                wget https://github.com/BlackReloaded/wsl2-ssh-pageant/releases/download/v1.2.0/wsl2-ssh-pageant.exe -O ~/.ssh/wsl2-ssh-pageant.exe
                                chmod +x ~/.ssh/wsl2-ssh-pageant.exe
                        fi

                        if ! diff ./.env.wsl ~/.env.wsl&> /dev/null; then
                                echo "Updating .env.wsl"
                                cp -f ./.env.wsl ~/
                                chmod +x ~/.env.wsl
                        fi

                        if ! grep -q "source ~/.env.wsl" ~/.bashrc; then
                                echo "source ~/.env.wsl" >> ~/.bashrc
                        fi

                        # Create the folder structure
                        if [ ! -d ~/.gnupg ]; then
                                echo "Adding ~/.gnupg"
                                mkdir ~/.gnupg
                        fi

                        if ! grep -q "allow-loopback-pinentry" ~/.gnupg/gpg-agent.conf; then
                                echo "Adding loopback to ~/.gnupg/gpg-agent.conf"
                                echo "allow-loopback-pinentry" >> ~/.gnupg/gpg-agent.conf
                        fi

                        if ! grep -q "pinentry-mode loopback" ~/.gnupg/gpg.conf; then
                                echo "Adding loopback to ~/.gnupg/gpg.conf"
                                echo "pinentry-mode loopback" >> ~/.gnupg/gpg.conf
                        fi
                        
                        gpgconf --reload gpg-agent
                fi


                echo "Installing / Updating Go"
                if ! gvm $goversion; then
                        printf "gvm %s install failed" "$goversion"
                        exit 0
                fi

                echo "Installing Git Auto Completion"
		if [ ! -d ~/.zsh ]; then
			mkdir -p ~/.zsh
		fi

		if [ ! -f ~/.zsh/git-completion.bash ]; then
			cd ~/.zsh || exit
			curl -o git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
			cd "$wd" || exit
		fi

		if [ ! -f ~/.zsh/git-completion.zsh ]; then
			cd ~/.zsh || exit
			curl -o _git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
			cd "$wd" || exit
		fi


		echo "Yarn installation"
		curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --nightly

		echo "Setting gpg2 as default GIT gpg handler"
        git config --global gpg.program gpg2 
                
        echo "Configuring Docker"

		sudo groupadd docker

		sudo usermod -aG docker "$USER"

		sudo systemctl enable docker

                echo "Configuring Terraform Auto-Completion"
                terraform -install-autocomplete

                curl -sSfL https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | sh -s -- -b "$(go env GOPATH)"/bin v1.37.1
                golangci-lint --version
        
                echo "Initializing Pre-Commit Global Hooks"
                pre-commit init-templatedir ~

                # Source: https://linuxize.com/post/how-to-install-vmware-workstation-player-on-ubuntu-20-04/
                # echo "Installing VMWare Workstation"
                # wget --user-agent="Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0" https://www.vmware.com/go/getplayer-linux
                # chmod +x getplayer-linux
                # sudo ./getplayer-linux --required --eulas-agreed
                # rm ./getplayer-linux

                echo "Installing Keybase"
                curl --remote-name https://prerelease.keybase.io/keybase_amd64.deb
                sudo apt install -y ./keybase_amd64.deb
                rm ./keybase_amd64.deb

                # benji | ~ $ sudo update-alternatives --config editor
                # There are 8 choices for the alternative editor (providing /usr/bin/editor).

                # Selection    Path               Priority   Status
                # ------------------------------------------------------------
                # * 0            /usr/bin/ng         80        auto mode
                # 1            /bin/ed            -100       manual mode
                # 2            /bin/nano           40        manual mode
                # 3            /usr/bin/code       0         manual mode
                # 4            /usr/bin/ng         80        manual mode
                # 5            /usr/bin/nvim       30        manual mode
                # 6            /usr/bin/vim.gtk3   50        manual mode
                # 7            /usr/bin/vim.nox    40        manual mode
                # 8            /usr/bin/vim.tiny   15        manual mode

                # Press <enter> to keep the current choice[*], or type selection number: 5
                # update-alternatives: using /usr/bin/nvim to provide /usr/bin/editor (editor) in manual mode
                # benji | ~ $ 

                # sudo visudo 
                # %sudo   ALL=(ALL:ALL) ALL replace with ->  %sudo   ALL=(ALL:ALL) NOPASSWD:ALL


        elif [[ "$OSTYPE" == "darwin"* ]] ; then

                echo '############################################'
                echo 'MAC Environment Installation'
                echo '############################################'

                if ! which brew &> /dev/null; then
                        echo "Install Homebrew"
                        exit 1
                fi

                if ! which gpg &> /dev/null; then
                        echo "Install GPG (gnupg.org)"
                        exit 1
                fi

				if ! which nvm &> /dev/null; then
					echo "Installing NVM"
					curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
					export NVM_DIR="$HOME/.nvm"
					[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
					[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
				fi

                echo "Updating brew"
                brew update>/dev/null 2>&1

                brew install python wget python3 git neovim tmux \
                tree graphviz golangci-lint pinentry-mac jq nvm libpcap \
                pre-commit nodejs shellcheck lefthook gsed webp fd \
				atuin kitty tailscale

                # Link GIT into the path properly
                brew link --force git
		
                if ! grep pinentry-mac ~/.gnupg/gpg-agent.conf; then
                        echo "Configuring pinentry-mac"
			echo "pinentry-program /usr/local/bin/pinentry-mac" >> ~/.gnupg/gpg-agent.conf
                fi

                if ! grep "reader-port Yubico Yubi" ~/.gnupg/scdaemon.conf; then
                        echo "Configuring scdaemon.conf"
			echo "reader-port Yubico Yubi" >> ~/.gnupg/scdaemon.conf
                fi

                if [ ! -f /.ssh/config ]; then
                        touch ~/.ssh/config
                fi

                if ! grep "UseKeychain" ~/.ssh/config ; then
                        echo "Configuring SSH for Keychain Access"
			echo "Host *" >> ~/.ssh/config 
			echo "    UseKeychain yes" >> ~/.ssh/config 
                fi


                gvm $goversion
                
                # Clear out auto complete cache
                if [ -d ~/.zcompdump ]; then
                        sudo rm ~/.zcompdump
                fi

		echo 'Upgrading pynvim support'
		pip3 install --user --upgrade pip
		pip3 install --user --upgrade pynvim


        elif [[ "$OSTYPE" == "cygwin" ]] ; then
                # POSIX compatibility layer and Linux environment emulation for Windows
                echo "$OSTYPE"
        elif [[ "$OSTYPE" == "msys" ]] ; then
                # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
                echo "$OSTYPE"
        elif [[ "$OSTYPE" == "win32" ]] ; then
                # I'm not sure this can happen.
                echo "$OSTYPE"
        elif [[ "$OSTYPE" == "freebsd"* ]] ; then
                # ...
                echo "$OSTYPE"
        else
                # Unknown.
                echo "$OSTYPE"
        fi

	echo "Installing oh-my-zsh"
	# installing oh-my-zsh
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

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

  	if which zsh > /dev/null
  	then
  	  if [[ $(echo $SHELL) != $(which zsh) ]]; then
  	    chsh -s $(which zsh)
  	    export SHELL=$(which zsh)
  	  fi
  	fi

        # Setup node to use latest for installs
        nvm install --lts

        npm install -g npm
        npm install -g @vue/cli
        npm i -g @vue/cli-service-global
        
        # SEO Tools
        npm i -g keywordsextract
        npm install -g lighthouse
        npm install -g netlify-cli
        npm install -g lighthouse-batch
        npm install -g broken-link-checker

        folder="${HOME}/bin"
        if [ ! -d "$folder" ]; then
		echo "Creating ~/bin directory"
		mkdir "$folder"
        fi
        echo '############################################'
        echo 'Installing Go Linters'
        echo '############################################'

        echo "Installing go tools"
	sudo rm -rf ~/go/src/golang.org/x/tools
	go install golang.org/x/tools/...@latest

        echo "Installing gopsutil"
	sudo rm -rf ~/go/src/github.com/shirou/gopsutil
	go install github.com/shirou/gopsutil@latest

        echo "Installing act"
	sudo rm -rf ~/go/src/github.com/nektos/act
        go install github.com/nektos/act@latest

        echo "Installing Benchstat"
        go install golang.org/x/perf/cmd/benchstat@latest

	#NOTE: This doesn't work on linux
	#echo "Installing smimesign for x509 Signing"
	#go get github.com/github/smimesign

        echo 'Setting up git global'
        git config --global commit.gpgsign true
        git config --global tag.gpgsign true
        #git config --global core.hookspath ${HOME}/hooks
        git config --global core.editor "nvim"
		git config --global push.autoSetupRemote true
	    git config --global rerere.enabled true
	    git config --global pull.rebase true
	    git config --global init.defaultBranch main 
        git config --global push.autoSetupRemote true 
		git config --global credential.helper store

        folder="${HOME}/.tmux/plugins/tpm"
        if [ ! -d "$folder" ]; then
                # Remove the existing tpm installation if it exists and reinstall
                echo 'Installing tmux plugin manager'
                [ -e "$folder" ] && rm -rf "$folder"
                git clone https://github.com/tmux-plugins/tpm "$folder" &> /dev/null
	else
		echo 'Updating tmux plugin manager *master* branch'
		cd "$folder" || exit
		git pull origin master &> /dev/null
		cd "$wd" || exit
        fi


	file="${HOME}/.local/share/nvim/site/autoload/plug.vim" 
	if [ ! -f "$file" ]; then
        	echo 'Installing vim-plug'
	        curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim>/dev/null 2>&1
	fi
	
	if [ ! -d ~/.fzf ]; then
		echo 'Cloning fzf plugin'
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
	else
		echo 'Updating fzf plugin repository'
		cd ~/.fzf || exit
		git pull origin master
		cd "$wd" || exit
	fi

	echo 'Executing fzf plugin installer'
	~/.fzf/install --all

	# If copilot doesn't currently exist then clone it
	if [ ! -d ~/.config/nvim/pack/github/start/ ]; then
		echo 'Installing copilot'
		git clone https://github.com/github/copilot.vim.git \
			~/.config/nvim/pack/github/start/copilot.vim
	else 
		echo 'Updating copilot'

		cd ~/.config/nvim/pack/github/start/ || exit
		git pull origin release

		cd "$wd" || exit
	fi
else
        echo 'Mode: Update Environment'
fi

echo '############################################'
echo 'Global Environment Installation'
echo '############################################'


# override the environment settings
if ! diff -r ./nvim/ ~/.config/nvim/ &> /dev/null; then
	echo 'Updating nvim configuration'
	cp -Rf ./nvim ~/.config/

	echo 'VIM plugin installation'
	#nvim +'PlugInstall --sync' +qall &> /dev/null
fi

echo 'VIM-GO Install / Update Binaries'
#nvim +GoInstallBinaries +qall &> /dev/null
#nvim +GoUpdateBinaries +qall &> /dev/null

cp -rpf ./bin/* ~/bin

if ! diff ./.tmux.conf.local ~/.tmux.conf.local&> /dev/null; then
	echo 'Updating tmux.conf.local configuration'
	cp -f ./.tmux.conf.local ~/
fi

if ! diff ./.tmux.conf ~/.tmux.conf&> /dev/null; then
	echo 'Updating tmux.conf configuration'
	cp -f ./.tmux.conf ~/
fi

if ! diff ./.env.shared ~/.env.shared&> /dev/null; then
	echo 'Updating environment script'
	cp -f ./.env.shared ~/
	chmod +x ~/.env.shared
fi

if [[ "$OSTYPE" == "linux"* ]] ; then
	if ! diff ./.env.bash ~/.env.bash&> /dev/null; then
		echo "Updating .env.bash"
	        cp -f ./.env.bash ~/
        	chmod +x ~/.env.bash
	fi

        if ! grep -q "source ~/.env.bash" ~/.zshrc; then
	        echo "source ~/.env.bash" >> ~/.zshrc
        fi
elif [[ "$OSTYPE" == "darwin"* ]] ; then
	if ! diff ./.env.darwin ~/.env.darwin&> /dev/null; then
		echo "Updating .env.darwin"
        	cp -f ./.env.darwin ~/
        	chmod +x ~/.env.darwin
	fi

        if ! grep -q "source ~/.env.darwin" ~/.zshrc; then
            echo "source ~/.env.darwin" >> ~/.zshrc
        fi
elif [[ "$OSTYPE" == "cygwin" ]] ; then
        # POSIX compatibility layer and Linux environment emulation for Windows
        echo "$OSTYPE"
elif [[ "$OSTYPE" == "msys" ]] ; then
        # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
        echo "$OSTYPE"
elif [[ "$OSTYPE" == "win32" ]] ; then
        # I'm not sure this can happen.
        echo "$OSTYPE"
elif [[ "$OSTYPE" == "freebsd"* ]] ; then
        # ...
        echo "$OSTYPE"
else
        # Unknown.
        echo "$OSTYPE"
fi

# Update the running terminal instance
exec zsh
