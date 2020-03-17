parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# export PS1="\u | \[\033[32m\]\W\[\033[33m\]\$(parse_git_branch)\[\033[00m\] $ "
function _update_ps1() {
    PS1="$($GOPATH/bin/powerline-go -error $? -modules "venv,ssh,cwd,perms,git,hg,jobs,exit,root" -cwd-mode dironly)"
}

if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

export GOPATH=~/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:/usr/local/go/bin:$GOBIN

# Install Ruby Gems to ~/gems
export GEM_HOME="$HOME/gems"
export PATH="$HOME/gems/bin:$PATH"

alias pbcopy="xclip -sel clip"

alias vim="nvim"
alias vi="nvim"
alias oldvim="vim"

[ -z "$TMUX" ] && export TERM=xterm-256color
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

dpull() {
	for d in */ ; do
    		cd $d
		if git remote | grep -q devnw; then
			git pull origin master
			git push --force-with-lease devnw --all
		fi
		cd ../
	done
}

[ -z "$TMUX" ] && export TERM=xterm-256color
if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi
