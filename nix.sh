# fail accepts a string argument, prints it and exits with a non-zero exit code
function fail() {
    printf "%s\n" "$1"
    exit 1
}

function checkgov() {
	go version | grep $goversion
}

wd=$(pwd)

if [ ! -f ~/.ssh/id_ed25519 ]; then
	echo "Generating SSH Key Pair"
	ssh-keygen -q -t ed25519 -N '' -f ~/.ssh/id_ed25519 <<<y >/dev/null 2>&1
fi

if [ ! -f /bin/bash ]; then
	echo "Adding /bin/bash symlink"
	if ! sudo ln -sf "$(which bash)" /bin/bash 
	then
	    fail "$(printf "Unable to symlink directory /bin/bash\n" "$lnsrc")"
	fi
fi

folder="${HOME}/bin"
if [ ! -d "$folder" ]; then
	echo "Creating ~/bin directory"
	mkdir "$folder"
fi

if [ ! -d ~/.zsh ]; then
	mkdir -p ~/.zsh
fi

if [ ! -f ~/.zsh/git-completion.bash ]; then
	echo "Installing Git Auto Completion for ZSH"
	cd ~/.zsh || exit
	curl -o git-completion.bash https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash
	cd "$wd" || exit
fi

if [ ! -f ~/.zsh/git-completion.zsh ]; then
	cd ~/.zsh || exit
	curl -o _git https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
	cd "$wd" || exit
fi

echo "Configuring Terraform Auto-Completion"
terraform -install-autocomplete

echo "Initializing Pre-Commit Global Hooks"
pre-commit init-templatedir ~

if which zsh > /dev/null
then
  if [[ $(echo $SHELL) != $(which zsh) ]]; then
    chsh -s $(which zsh)
    export SHELL=$(which zsh)
  fi
fi

if ! which detect-secrets > /dev/null
then
	nix-env -i detect-secrets
fi

# SEO Tools
# TODO: Install these in SEO env
#npm i -g keywordsextract
#npm install -g lighthouse
#npm install lighthouse-batch -g

echo '############################################'
echo 'Installing Go Tools'
echo '############################################'

echo "Installing go tools"
go install golang.org/x/tools/...@latest

echo "Installing gopsutil"
go install github.com/shirou/gopsutil@latest

echo "Installing act"
go install github.com/nektos/act@latest

echo "Installing Benchstat"
go install golang.org/x/perf/cmd/benchstat@latest

echo "Installing Delve Debugger"
go install github.com/go-delve/delve/cmd/dlv@latest

echo 'Setting up git global'
git config --global core.hookspath "${HOME}"/hooks
git config --global core.editor "nvim"
git config --global rerere.enabled true
git config --global pull.rebase true
git config --global init.defaultBranch main 

# GPG Settings
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.program gpg2 


file="${HOME}/.local/share/nvim/site/autoload/plug.vim" 
if [ ! -f "$file" ]; then
	echo 'Installing vim-plug'
        curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim>/dev/null 2>&1
fi

#if [ ! -d ~/.fzf ]; then
#	echo 'Cloning fzf plugin'
#	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
#else
#	echo 'Updating fzf plugin repository'
#	cd ~/.fzf || exit
#	git pull origin master
#	cd "$wd" || exit
#fi
#
#echo 'Executing fzf plugin installer'
#~/.fzf/install --all

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

if ! diff -r ./nvim/ ~/.config/nvim/ &> /dev/null; then
	echo 'Setting Up Neovim'
	echo 'Updating nvim configuration'
	cp -Rf ./nvim ~/.config/

	echo 'VIM plugin installation'
	nvim +'PlugInstall --sync' +qall &> /dev/null

	echo 'VIM-GO Install / Update Binaries'
	nvim +GoInstallBinaries +qall &> /dev/null
	nvim +GoUpdateBinaries +qall &> /dev/null
fi


echo 'Copying Environment Binaries'
cp -rpf ./bin/* ~/bin

echo "Updating TMUX Environment"
if [ -d ~/.tmux ]; then
	rm -rf ~/.tmux
fi

git clone https://github.com/gpakosz/.tmux.git ~/.tmux
ln -s -f .tmux/.tmux.conf ~/.tmux.conf

#mkdir -p ~/.config/alacritty
#cp -f ./alacritty.yml ~/.config/alacritty/

if ! diff ./.tmux.conf.local ~/.tmux.conf.local&> /dev/null; then
	echo 'Updating tmux configuration'
	cp -f ./.tmux.conf.local ~/
fi

if ! diff ./.env.shared ~/.env.shared&> /dev/null; then
	echo 'Updating environment script'
	cp -f ./.env.shared ~/
	chmod +x ~/.env.shared
fi

if ! diff ./.env.bash ~/.env.bash&> /dev/null; then
	echo "Updating .env.bash"
        cp -f ./.env.bash ~/
	chmod +x ~/.env.bash
fi

if ! grep -q "source ~/.env.bash" ~/.zshrc; then
        echo "source ~/.env.bash" >> ~/.zshrc
fi

cp -rf ./.icons "$HOME"/
cp ./gpg-agent.conf ~/.gnupg

# Update the running terminal instance
exec zsh
