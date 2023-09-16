#!/bin/bash

goversion="1.21.1"

wd=$(pwd)

install_linux_packages() {
    echo '############################################'
    echo 'Linux Environment Installation'
    echo '############################################'
    
    sudo apt-get update && sudo apt-get install -y apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common || { echo 'apt-get update failed'; exit 0; }
        
    sudo add-apt-repository -y ppa:git-core/ppa ppa:wireshark-dev/stable
    
    if ! which docker &> /dev/null; then
    	curl https://get.docker.com | sudo sh && sudo systemctl --now enable docker
    fi
    
    sudo apt-get -y update || { echo 'apt-get update failed'; exit 0; }

    local packages=(net-tools nscd resolvconf tmux autotools-dev ecryptfs-utils cryptsetup
        ng-common gcc g++ make python3 python3-pip tree kazam nmap graphviz
        pcscd python-is-python3 bolt shellcheck xclip libpam-u2f
        linux-headers-generic make clang llvm
        libelf-dev libpcap-dev yubikey-luks tcpdump wireshark
        docker-compose unattended-upgrades apt-listchanges setserial cu
        screen putty minicom zsh jq pre-commit lua-nvim clangd pinentry-curses
        protobuf-compiler solaar fd-find kitty)

    sudo apt-get install -y "${packages[@]}" || { echo 'apt-get install failed'; exit 1; }
	
	sudo ln -s $(which fdfind) /usr/bin/fd

    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz && \
		tar xzvf nvim-linux64.tar.gz -C $HOME && \
		rm ./nvim-linux64.tar.gz || \
		{ echo 'nvim installation or extraction failed'; exit 0; }
	
    sudo dpkg-reconfigure -plow unattended-upgrades -u || { echo 'dpkg-reconfigure failed'; exit 0; }
    sudo cp ./50unattended-upgrades /etc/apt/apt.conf.d/ || { echo 'Auto upgrade configuration failed'; exit 0; }

    sudo usermod -aG wireshark "$USER" || echo 'wireshark usermod failed'
    sudo apt-get install -y gnome-keyring || echo 'gnome-keyring install failed'

    echo "Adding GH CLI Repository"
    sudo snap install gh || echo 'github CLI install failed'
    
    
    echo "Installing gvm"
    curl -o- https://raw.githubusercontent.com/devnw/gvm/main/install.sh | bash

    echo "Installing / Updating Go"
    $HOME/bin/gvm $goversion || { printf "gvm %s install failed" "$goversion"; exit 0; }

	echo "Installing Atuin"
	bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)

    echo "Configuring Docker"
    sudo groupadd docker
    sudo usermod -aG docker "$USER"
    sudo systemctl enable docker
}

install_mac_packages() {
    echo '############################################'
    echo 'MAC Environment Installation'
    echo '############################################'

    if ! which brew &> /dev/null; then
        echo "Install Homebrew"
        exit 1
    fi

    brew update
    brew install python wget python3 tmux \
        tree graphviz golangci-lint jq nvm libpcap \
        pre-commit nodejs shellcheck lefthook gsed webp fd \
        atuin tailscale tig kubectl

    brew install --cask altair-graphql-client

    curl -LO https://github.com/neovim/neovim/releases/download/nightly/nvim-macos.tar.gz && \
		tar xzf nvim-macos.tar.gz -C $HOME && \
		rm ./nvim-macos.tar.gz || \
		{ echo 'nvim installation or extraction failed'; exit 0; }

    gvm $goversion

    [ -d ~/.zcompdump ] && rm ~/.zcompdump
}

install_py_packages() {
	pip3 install --user --upgrade pip pynvim pre-commit Commitizen
	
	echo "Initializing Pre-Commit Global Hooks"
	pre-commit init-templatedir ~
}

install_fzf() {
	if [ ! -d ~/.fzf ]; then
        echo 'Cloning fzf plugin'
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
    else
        echo 'Updating fzf plugin repository'
        cd ~/.fzf || exit
        git pull origin master
    fi

    cd "$wd" || exit
    echo 'Executing fzf plugin installer'
    ~/.fzf/install --all
}

install_ohmyzsh() {
 	echo "Installing oh-my-zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

configure_git() {
 	echo 'Setting up git global'
    git config --global commit.gpgsign true
    git config --global tag.gpgsign true
    git config --global core.hookspath ${HOME}/hooks
    git config --global core.editor "nvim"
    git config --global push.autoSetupRemote true
    git config --global rerere.enabled true
    git config --global pull.rebase true
    git config --global init.defaultBranch main 
    git config --global push.autoSetupRemote true 
    git config --global credential.helper store
}

install_go_tools(){
	echo '############################################'
    echo 'Installing Go Linters'
    echo '############################################'

    echo "Installing go tools"
    sudo rm -rf ~/go/src/golang.org/x/tools
    go install golang.org/x/tools/...@latest

	sudo rm -rf ~/go/src/google.golang.org/protobuf
	go install google.golang.org/protobuf/cmd/protoc-gen-go@latest

	sudo rm -rf ~/go/src/google.golang.org/grpc
	go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest

    echo "Installing gopsutil"
    sudo rm -rf ~/go/src/github.com/shirou/gopsutil
    go install github.com/shirou/gopsutil@latest

    echo "Installing act"
    sudo rm -rf ~/go/src/github.com/nektos/act
    go install github.com/nektos/act@latest

    echo "Installing Benchstat"
    go install golang.org/x/perf/cmd/benchstat@latest

    echo "Installing cosign"
	go install github.com/sigstore/cosign/v2/cmd/cosign@latest

    echo "Installing GoReleaser"
	go install github.com/goreleaser/goreleaser@latest
}

handle_nvm_installation() {
    if ! which nvm &> /dev/null; then
        echo "Installing NVM"
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
        export NVM_DIR="$HOME/.nvm"
        [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
        [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
        
        # Check if .profile already contains NVM_DIR related commands
        if ! grep -q 'NVM_DIR' ~/.profile; then
            cat ./nvm.sh >> ~/.profile
        fi
        
        source $HOME/.profile
    fi
}

if [[ "$1" == "-i" ]]; then
    echo 'Mode: Install Environment'
    case "$OSTYPE" in
        "linux"*) install_linux_packages ;;
        "darwin"*) install_mac_packages ;;
        *) echo "Unsupported OS: $OSTYPE" ;;
    esac

    handle_nvm_installation
	install_ohmyzsh
	install_fzf
	install_py_packages
	configure_git
	install_go_tools
    
     # Setup node to use latest for installs
    nvm install --lts
    npm install -g npm

    npm install -g typescript-language-server typescript lighthouse \
	lighthouse-batch broken-link-checker tree-sitter-cli keywordsextract

else
    echo 'Mode: Update Environment'
fi

echo '############################################'
echo 'Global Environment Installation'
echo '############################################'

update_config() {
    local src=$1
    local dest=$2
    if ! diff "$src" "$dest" &> /dev/null; then
        echo "Updating $(basename $dest) configuration"
        cp -rf "$src" "$dest"
        [ "${src##*.}" == "shared" ] && chmod +x "$dest"
    fi
}

update_config ./nvim ~/.config/nvim
[ $? -eq 0 ] && echo 'VIM plugin installation'

#echo 'VIM-GO Install / Update Binaries'
#nvim +'PlugInstall --sync' +qall &> /dev/null
#
#echo "Installing TreeSitter"
#nvim +'TSInstall all' +qall &> /dev/null
#
#echo "Installing Go Binaries"
#nvim +GoInstallBinaries +qall &> /dev/null
#nvim +GoUpdateBinaries +qall &> /dev/null

echo "Copying Bin"
cp -rpf ./bin/* ~/bin

echo "Update tmux config"
update_config ./.tmux.conf.local ~/.tmux.conf.local

echo "Update tmux config 2"
update_config ./.tmux.conf ~/.tmux.conf

echo "Update env.shared"
update_config ./.env.shared ~/.env.shared



env_source=".env.bash"
[[ "$OSTYPE" == "darwin"* ]] && env_source=".env.darwin"

update_config "./$env_source" ~/"$env_source"

#echo "override caplock with ctrl"
#if ! grep -q '/usr/bin/setxkbmap -option "ctrl:nocaps"'; then
#    echo '/usr/bin/setxkbmap -option "ctrl:nocaps"' >> ~/.zshrc
#fi

echo "source bash src"
if ! grep -q "source $HOME/$env_source" ~/.zshrc; then
    echo "source $HOME/$env_source" >> ~/.zshrc
fi


echo "Configuring .profile sourcing"
if ! grep -q "source $HOME/.profile" ~/.bashrc; then
    echo "source $HOME/.profile" >> ~/.bashrc
fi

if ! grep -q "source $HOME/.profile" ~/.zshrc; then
    echo "source $HOME/.profile" >> ~/.zshrc
fi

if ! grep -q 'nvim-linux64/bin' ~/.profile; then
    echo 'PATH="$HOME/nvim-linux64/bin:$PATH"' >> ~/.profile
fi

case "$OSTYPE" in
    "cygwin"|"msys"|"win32"|"freebsd"*)
        echo "$OSTYPE" ;;
    *) ;;
esac

exec zsh

