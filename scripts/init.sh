#!/bin/bash

# set -x

BACKUP_DIR=backup

function get_backup_repo
{
    if [[ ! -r ".gitmodules" ]]; then
        echo ""
        return
    fi

    echo "$(grep 'submodule' ".gitmodules" | sed 's/.*\"\(.*\)\".*/\1/' 2>/dev/null)"
}

while [[ "$(get_backup_repo)" == "" ]]; do
    echo "The backup repo doesn't exist yet"
    echo "Please enter URL or path of the git repository you would like to store backup to: "
    echo -n "> "
    read -r repo
    git submodule add "${repo}"
done

git submodule init
git submodule update


