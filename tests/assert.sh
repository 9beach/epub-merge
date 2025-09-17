#!/usr/bin/bash

# Simple assertion helpers for bash scripts.
# Keeps counts of tests and failures, prints helpful messages including caller 
# location.

TESTS=0
FAILS=0

# Print a failure message with caller info.
# $1: message
_fail() {
	local msg="$1"
	local src="${BASH_SOURCE[2]:-unknown}"
	local line="${BASH_LINENO[1]:-0}"
	printf "FAIL: %s (at %s:%s)\n" "$msg" "$src" "$line" >&2
}

# Print a success message (optional).
# $1: message
_pass() {
	local msg="$1"
	printf "ok: %s\n" "$msg"
}

# assert_true: run a command and assert it exits 0
# Usage: assert_true "command" "optional message"
assert_true() {
	local cmd="$1"; shift
	local msg="${*:-$cmd}"
	(( TESTS++ ))
	# shellcheck disable=SC2086
	eval "$cmd"
	local status=$?
	if [ $status -ne 0 ]; then
		(( FAILS++ ))
		_fail "command failed: $msg"
		return 1
	else
		_pass "$msg"
		return 0
	fi
}

# assert_eq: compare two strings for equality
# Usage: assert_eq "expected" "actual" "optional message"
assert_eq() {
	local expected="$1"; local actual="$2"; shift 2
	local msg="${*:-expected == actual}"
	(( TESTS++ ))
	if [ "$expected" != "$actual" ]; then
		(( FAILS++ ))
		_fail "assert_eq failed: expected='$expected' actual='$actual' -- $msg"
		return 1
	else
		_pass "$msg (expected='$expected')"
		return 0
	fi
}

# assert_ne: compare two strings for inequality
# Usage: assert_ne "not_expected" "actual" "optional message"
assert_ne() {
	local not_expected="$1"; local actual="$2"; shift 2
	local msg="${*:-expected != actual}"
	(( TESTS++ ))
	if [ "$not_expected" = "$actual" ]; then
		(( FAILS++ ))
		_fail "assert_ne failed: both='$actual' -- $msg"
		return 1
	else
		_pass "$msg (not_expected='$not_expected', actual='$actual')"
		return 0
	fi
}

# assert_file_exists: check file exists and is a regular file
# Usage: assert_file_exists "/path/to/file" "optional message"
assert_file_exists() {
	local f="$1"; shift
	local msg="${*:-file exists: $f}"
	(( TESTS++ ))
	if [ ! -f "$f" ]; then
		(( FAILS++ ))
		_fail "file not found: $f -- $msg"
		return 1
	else
		_pass "$msg"
		return 0
	fi
}

# assert_dir_exists: check directory exists
# Usage: assert_dir_exists "/path/to/dir" "optional message"
assert_dir_exists() {
	local d="$1"; shift
	local msg="${*:-directory exists: $d}"
	(( TESTS++ ))
	if [ ! -d "$d" ]; then
		(( FAILS++ ))
		_fail "directory not found: $d -- $msg"
		return 1
	else
		_pass "$msg"
		return 0
	fi
}

# Summary: print totals and exit non-zero if any failures.
# Call this at the end of your test script.
assert_summary() {
	printf "\nTests: %d, Failures: %d\n" "$TESTS" "$FAILS"
	if [ "$FAILS" -ne 0 ]; then
		return 1
	fi
	return 0
}

