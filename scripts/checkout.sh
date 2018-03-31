#!/bin/bash

# Find the name of submodule holding the actual backup
REPO_DIR="$(grep 'submodule' .gitmodules | sed 's/.*\"\(.*\)\".*/\1/')"
function hostname_branch_exists()
{
	IFS=$'\n'
	BRANCHES=("$(git -C "${REPO_DIR}" branch -a | grep 'remotes/')")

	# Check if there is a branch with the name same as hostname
	for branch in $BRANCHES; do
		branch=$(echo $branch | tr -s ' ' | cut -d\  -f 2 | cut -d\/ -f3-)
		if [[ "$branch" == "${HOSTNAME}" ]]; then
			return 0
		fi
	done
	unset IFS
	return 1
}

function hostname_checked_out()
{
	# Check if the currently selected branch has the same name as hostname
	CUR_BRANCH="$(git -C ${REPO_DIR} rev-parse --abbrev-ref HEAD)"
	if [[ "${CUR_BRANCH}" == "${HOSTNAME}" ]]; then
		return 0
	fi
	return 1
}

# Create branch if not exists
if [[ $(hostname_branch_exists; echo $?) -eq 1 ]]; then
	echo "Branch ${HOSTNAME} doesn't exists, creating..."
	git -C "${REPO_DIR}" branch "${HOSTNAME}"
fi

# Check-out the branch if not already checked
if [[ $(hostname_checked_out; echo $?) -eq 1 ]]; then
	git -C "${REPO_DIR}" checkout "${HOSTNAME}"
fi
