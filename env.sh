#!/bin/bash

wd=$(pwd)

update_config() {
    local src=$1
    local dest=$2
    if ! diff "$src" "$dest" &> /dev/null; then
        echo "Updating $(basename $dest) configuration"
        cp -rf "$src" "$dest"
        [ "${src##*.}" == "shared" ] && chmod +x "$dest"
    fi
}

install_packages() {
    apt-get update && apt-get install -y apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common || { echo 'apt-get update failed'; exit 0; }
        
    if ! which docker &> /dev/null; then
    	curl https://get.docker.com | sh &&  systemctl --now enable docker
    fi
    
     apt-get -y update || { echo 'apt-get update failed'; exit 0; }

    local packages=(net-tools nscd resolvconf tmux autotools-dev 
        ng-common gcc g++ make python3 python3-pip tree kazam nmap pcscd
		python-is-python3 shellcheck xclip libpam-u2f make clang llvm
        docker-compose unattended-upgrades apt-listchanges zsh jq lua-nvim
		clangd solaar fd-find)

     apt-get install -y "${packages[@]}" || { echo 'apt-get install failed'; exit 1; }
	
	 ln -s $(which fdfind) /usr/bin/fd

	
     dpkg-reconfigure -plow unattended-upgrades -u || { echo 'dpkg-reconfigure failed'; exit 0; }
     cp ./50unattended-upgrades /etc/apt/apt.conf.d/ || { echo 'Auto upgrade configuration failed'; exit 0; }

    sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

    wget https://github.com/neovim/neovim/releases/download/stable/nvim-linux64.tar.gz && \
		tar xzvf nvim-linux64.tar.gz -C $HOME && \
		rm ./nvim-linux64.tar.gz || \
		{ echo 'nvim installation or extraction failed'; exit 0; }

    echo "Installing Atuin"
	cargo install atuin
}

install_py_packages() {
	pip3 install --user --upgrade pip pynvim 
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

if [[ "$1" == "-i" ]]; then

	if [ ! -d ~/.config ]; then
		echo "Creating config directory"
		mkdir ~/.config
	fi
	
	# remove enteprise apt files for proxmox
	rm -rf /etc/apt/sources.list.d/pve-enterprise.list
	rm -rf /etc/apt/sources.list.d/ceph.list

	install_packages 
	
	# install void for dns
	apt install -y ./void_0.0.11_linux_amd64.deb
	
	# Overwrite the top of the resolve file so that localhost is used as primary
	echo "127.0.0.1" >> /etc/resolvconf/resolv.conf.d/head

	# restart the resolver
 	systemctl restart resolvconf.service
	
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
	
	export PATH="$HOME/.cargo/bin:$PATH"
	
	cargo install tree-sitter-cli
	
	curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
	
	export NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
	[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
	
	# install tailscale
	curl -fsSL https://tailscale.com/install.sh | sh
	
	nvim +PlugInstall +UpdateRemotePlugins +qa
	
	install_ohmyzsh
	install_fzf
	install_py_packages
	configure_git
    
	apt-get update && apt-get -y dist-upgrade
else
    echo 'Mode: Update Environment'
fi

update_config ./nvim ~/.config/nvim
[ $? -eq 0 ] && echo 'VIM plugin installation'

echo "Copying Bin"
cp -rpf ./bin/* ~/bin

echo "Update tmux config"
update_config ./.tmux.conf.local ~/.tmux.conf.local

echo "Update tmux config 2"
update_config ./.tmux.conf ~/.tmux.conf

echo "Update env.shared"
update_config ./.env.shared ~/.env.shared

env_source=".env.bash"

update_config "./$env_source" ~/"$env_source"

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

exec zsh

