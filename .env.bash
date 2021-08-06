if [ -f ~/.git-completion.bash ]; then
  . ~/.git-completion.bash
fi

eval "$(ssh-agent -s)">/dev/null 2>&1

#keychain id_rsa id_dsa id_ed25519
#. ~/.keychain/`uname -n`-sh

export PS1="\u | \[\033[32m\]\W\[\033[33m\]\$(git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/')\[\033[00m\] $ "

re() {
	source ~/.bashrc
}

source ~/.env.shared
