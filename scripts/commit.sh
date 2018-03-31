#!/bin/bash

REPO_DIR="$(grep 'submodule' .gitmodules | sed 's/.*\"\(.*\)\".*/\1/')"
COMMIT_MSG=$(date "+backup_%Y-%m-%d_%H-%M")

git -C "${REPO_DIR}" commit -m "${HOSTNAME} ${COMMIT_MSG}" 2>&1 1>/dev/null
