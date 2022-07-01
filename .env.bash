#!/bin/bash

# Load Git completion
zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit
re() {
  # shellcheck disable=SC1091
	source "$HOME/.$SHELLrc"
}

renet() {
  sudo /etc/init.d/network-manager restart
}

# shellcheck disable=SC1091
source "$HOME/.env.shared"
