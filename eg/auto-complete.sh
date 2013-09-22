#!/bin/bash

# to use this for your own code all you should need to do is change the
# eg/auto-complete.pl to your scripts name and rename the function.
_auto-complete() {
    local cur opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    # get list of auto-complete line options
    opts=$(eg/auto-complete.pl --auto-complete --auto-complete-list)

    # split the reply into arguments and other
    if [[ ${cur} == -* && ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    else
        local sonames=$(eg/auto-complete.pl --auto-complete ${COMP_WORDS[@]})
        COMPREPLY=($(compgen -W "${sonames}" -- ${cur}))
    fi
}
complete -F _auto-complete eg/auto-complete.pl

