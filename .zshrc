
# Tab completion
autoload -Uz compinit promptinit
compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION
promptinit
zstyle ':completion:*' menu select

# History
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=~/.cache/zsh/history

# Color and prompt
autoload -U colors && colors
PROMPT="%n@%m %F{yellow}[%B%1~%b]%f %# "
stty stop undef     # Disable ctrl-s to freeze terminal.

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Thanks to https://github.com/LukeSmithxyz/voidrice/blob/master/.config/zsh/.zshrc
# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Aliases
alias ls="exa"
alias ll="exa -la"
alias lla="exa -l"
alias bg="feh --bg-scale"
alias mbs="hledger bs -B --forecast -M"
alias mis="hledger is -M"
alias rr="ranger"
alias pc="sxiv"
alias pdf="zathura"
alias usbeject="udiskie-umount -d -e"

# ENV VARS
export LEDGER_FILE="$HOME/notes/finance/2021.journal"
export PATH="$PATH:$HOME/.local/bin"
export EDITOR="emacs"
