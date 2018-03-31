#!/bin/bash

# Should be comments in the file $FILE_LIST honored?
# If negative, leading hashes will be stripped
HONOR_COMMENTS=true
# Remove any accidentally copied git repos into the destination folder
PRUNE_GIT_REPOS=true
# List containing files and folders to be backeped
FILE_LIST="backup.list"
# Find name of the submodule holding actual backup data
REPO_DIR="$(grep 'submodule' .gitmodules | sed 's/.*\"\(.*\)\".*/\1/')"
# Directory where everything should be copied to
OUTPUT_DIR="${REPO_DIR}/backup/${USER}"
# OUTPUT_FILE="$(date "+backup_%Y-%m-%d_%H-%M")"

# Prune the output directory
rm -Rf "${OUTPUT_DIR}/"

# Make the backup directory great again
if [[ ! -e "$OUTPUT_DIR" || ! -d "$OUTPUT_DIR" ]]; then
	mkdir -p "$OUTPUT_DIR"
fi

# As a bonus backup installed packages
if [[ -x "$(command -v yaourt)" ]]; then
	yaourt -Qe > "${OUTPUT_DIR}/installed_as_explicit.txt"
	yaourt -Qd > "${OUTPUT_DIR}/installed_as_dependencies.txt"
fi

if [[ -x "$(command -v apt)" ]]; then
	apt list --installed > "${OUTPUT_DIR}/installed_packages.txt"
fi

# Loop through the list of files and directories to be backuped
cnt=1
while read line; do
	# If the line starts with a hash
	if [[ "$line" == \#* ]]; then
		# Skip the line
		if [[ $HONOR_COMMENTS ]]; then
			continue;
		# Remove the comment
		else
			line = ${line:1}
		fi
	fi

	# Store a whole path
	source_abs=$(readlink -m "${line}")
	# We are dealing with a nonexisting file
	if [[ ! -e "$source_abs" ]]; then
		>&2 printf "  [%04d] Item doesn't exist: %s\n" "${cnt}" "$source_abs"
	# We are dealing with a directory
	elif [[ -d "$source_abs" ]]; then
		ret=$(cp --no-preserve mode,ownership -R --parents "$source_abs" "$OUTPUT_DIR" 2>&1)
		if [[ "$?" == "0" ]]; then
			printf "  [%04d] OK: %s\n" "${cnt}" "$source_abs"
		else
			>&2 printf "  [%04d] Can't copy folder: [%s], exception: [%s]\n" "${cnt}" "$source_abs" "$ret"
		fi
	# We are dealing with a readable file
	elif [[ -f "$source_abs" ]]; then
		if [[ -r "$source_abs" ]]; then
			ret=$(cp --no-preserve mode,ownership --parents "$source_abs" "$OUTPUT_DIR" 2>&1)
			if [[ "$?" == "0" ]]; then
				printf "  [%04d] OK: %s\n" "${cnt}" "$source_abs"
			else
				>&2 printf "  [%04d] Can't copy file: [%s], exception: [%s]\n" "${cnt}" "$source_abs" "$ret"
			fi
		else
			>&2 printf "  [%04d] File is not readable: [%s]\n" "${cnt}" "$source_abs"
		fi
	else
		>&2 printf "  [%04d] Unknown filetype: [%s]\n" "${cnt}" "$source_abs"
	fi

	cnt=$((cnt+1))
done < "$FILE_LIST"

# Prune all .git repos if user wants so
if [[ $PRUNE_GIT_REPOS ]]; then
	find "$OUTPUT_DIR" -name ".git*" -prune -exec rm -Rf "{}" \;
fi

