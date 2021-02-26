#!/bin/zsh
#
autoload -Uz compinit promptinit
compinit
promptinit

zstyle ':completion:*' menu select

PROMPT="%n@%m %F{yellow}[%B%1~%b]%f %# "

alias ls="ls --color=auto"
alias ll="ls -la"
export LEDGER_FILE="$HOME/notes/finance/2021.journal"
