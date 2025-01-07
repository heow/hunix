export PATH=${HOME}/.local/bin:${PATH}

# most aliases were made into files so they could be run without readline
alias lo='exit'
alias bye='exit'
alias pd='pushd'
alias pd2='pushd +2'
alias pd3='pushd +3'
alias pd4='pushd +4'

# ensure these work
if ls --color=auto > /dev/null 2>&1; then
    alias ls='ls --color=auto -F' # color and classify (append /)
else
    alias ls='ls -F' # classify (append /)
fi

alias  l='ls -C'              # colum
alias la='ls -A'              # almost all (no ./ ../)
alias ll='ls -l'
alias lo='exit'
