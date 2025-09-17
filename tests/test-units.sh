#!/bin/bash

source "$(dirname "$0")/assert.sh"

path_to_trunk() {
        local parent
        parent="$(dirname "$(dirname "$1" | sed -e 's:^\./::')")"

        if [ "$parent" = "." ]; then
                echo ""
        else
                echo "$parent/" | sed 's#[^/][^/]*#..#g'
        fi
}

path_to_root() {
        local parent
        parent="$(dirname "$1" | sed -e 's:^\./::')"

        if [ "$parent" = "." ]; then
                echo "."
        else
                echo "$parent" | sed 's#[^/][^/]*#..#g'
        fi
}

assert_eq "$(path_to_root "a/b/c.txt")" "../.."

assert_eq "$(path_to_trunk "a/b/c.txt")" "../"
assert_eq "$(path_to_trunk "a/bb/ccc/dddd/eeee.txt")" "../../../"
assert_eq "$(path_to_trunk "a/b")" ""

# Not ideal, but we assume $i is always within a trunk and the 
# path is always normalized
assert_eq "$(path_to_trunk "a")" ""
assert_eq "$(path_to_trunk "../b/c.txt")" "../"

assert_summary
