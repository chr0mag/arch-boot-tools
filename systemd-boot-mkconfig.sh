#!/usr/bin/bash

shopt -s nullglob

CMDLINE_PATH="/etc"
CMDLINE_FILE="${CMDLINE_PATH}/cmdline"
BACKUP="${CMDLINE_FILE}.bak"

# print an error and exit with failure
# $1: error message
function error() {
        echo "$0: error: $1" >&2
        exit 1
}

# ensure the programs needed to execute are available
function check_progs() {
        local PROGS="sed cat bootctl"
        which ${PROGS} > /dev/null 2>&1 || error "Searching PATH fails to find executables among: ${PROGS}"
}

# ensure the files needed to execute are available
function check_conf_files() {
	# cmdline file must exist
	[[ -f "${CMDLINE_FILE}" ]] || error "${CMDLINE_FILE} does not exist"

	ESP=$(bootctl status --print-path)
	[[ -n "${ESP}" ]] || error "Cannot find EFI System Partition."
	ENTRIES_PATH="${ESP}/loader/entries"
	ENTRIES=(${ENTRIES_PATH}/arch*.conf)
}

# script to automate updates to systemd-boot loader entries' kernel options
# assumes all entries use the same kernel command line parameters
# does not change 'title' 'linux' or 'initrd' lines
function main() {

	check_progs
	check_conf_files
	
	# backup current options
	sed --quiet 's/^options[[:space:]]*//p' ${ENTRIES[0]} > ${BACKUP}

	# read in new options
	OPTS=$(cat ${CMDLINE_FILE})
	echo "Using options: $OPTS..."

	#update options for all entries
	for entry in ${ENTRIES[@]}
	do
		echo "Updating ${entry}..."
		sed --in-place "s#^options.*#options\t\t${OPTS}#" ${entry}
	done

	echo "Done."
	exit 0
}

main "$@"
