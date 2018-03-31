#!/bin/bash

REPO_DIR="$(grep 'submodule' .gitmodules | sed 's/.*\"\(.*\)\".*/\1/')"

git -C "${REPO_DIR}" add --all
