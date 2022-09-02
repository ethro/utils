#!/bin/bash

# get the directory where the script is on the filesystem
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# get the absolute path of the top directory of the repository
TOP_DIR=$(readlink -f "$SCRIPT_DIR/..")

# set where we want soft links to be created
LINK_BASE=~/.local/bin

# Declare a string array with type
# strings are to be absolute paths to the targets to link into $LINK_BASE
declare -a target_paths=(
#"$TOP_DIR/ssh/gen_rsa.sh"
)

# Read the array values with space
for target in "${target_paths[@]}"; do

    # pull off the name of the target we want to create a link for
    link_name=$(basename "${target%.*}")

    # make a soft link to the target and replace anything that is there
    ln -sf "$target" "$LINK_BASE/$link_name"
done

