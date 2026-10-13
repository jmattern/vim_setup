#!/usr/bin/env bash
# Source this file so SSH_AUTH_SOCK and SSH_AGENT_PID remain in the shell.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    printf 'Source this script: . %s\n' "$0" >&2
    exit 2
fi

_vim_setup_start_ssh_agent() {
    local vim_setup_agent_status=2
    local vim_setup_ssh_key=${1:-$HOME/.ssh/id_rsa}
    local vim_setup_key_fingerprint

    if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
        if ssh-add -l >/dev/null 2>&1; then vim_setup_agent_status=0; else vim_setup_agent_status=$?; fi
    fi
    if ((vim_setup_agent_status <= 1)); then
        printf 'Using the existing SSH agent.\n'
    else
        eval "$(ssh-agent -s)" >/dev/null || return
    fi

    if [[ -r "$vim_setup_ssh_key" ]]; then
        vim_setup_key_fingerprint=$(ssh-keygen -lf "$vim_setup_ssh_key" 2>/dev/null | awk '{print $2}')
        if [[ -n "$vim_setup_key_fingerprint" ]] && ! ssh-add -l 2>/dev/null | awk '{print $2}' | grep -Fqx "$vim_setup_key_fingerprint"; then
            ssh-add "$vim_setup_ssh_key"
        fi
    fi
}

if _vim_setup_start_ssh_agent "$@"; then
    unset -f _vim_setup_start_ssh_agent
    return 0
else
    unset -f _vim_setup_start_ssh_agent
    return 1
fi
