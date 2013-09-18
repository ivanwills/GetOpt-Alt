_auto-complete() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    # get list of auto-complete line options
    opts=$(eg/auto-complete.pl --auto-complete --auto-complete-list)

    if [[ ${cur} == -* && ${COMP_CWORD} -eq 1 ]]; then
        COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    else
        local sonames=$(eg/auto-complete.pl --auto-complete ${COMP_WORDS[@]})
        COMPREPLY=($(compgen -W "${sonames}" -- ${cur}))
    fi
}
complete -F _auto-complete eg/auto-complete.pl

