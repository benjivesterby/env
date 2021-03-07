GOPATH=$(go env GOPATH)

# export PS1="\u | \[\033[32m\]\W\[\033[33m\]\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')\[\033[00m\] $ "
# function _update_ps1() {
#     PS1="$($GOPATH/bin/powerline-go -error $? -modules "venv,ssh,cwd,perms,git,hg,jobs,exit,root" -cwd-mode dironly)"
# }

# if [ "$TERM" != "linux" ] && [ -f "$GOPATH/bin/powerline-go" ]; then
#     PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
# fi

if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

# setxkbmap -layout us -option ctrl:swapcaps

re() {
	source ~/.bashrc
}

source ~/.env.shared
