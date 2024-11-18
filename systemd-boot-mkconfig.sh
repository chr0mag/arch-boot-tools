#!/usr/bin/bash


ENTRIES_PATH="/boot/loader/entries"
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
        local PROGS="sed cat"
        which ${PROGS} > /dev/null 2>&1 || error "Searching PATH fails to find executables among: ${PROGS}"
}

# ensure the configuration files needed to execute are available
function check_conf_files() {
	# cmdline file must exist
	[[ -f "${CMDLINE_FILE}" ]] || error "${CMDLINE_FILE} does not exist"

	ENTRIES=$(ls ${ENTRIES_PATH}/*.conf 2> /dev/null) || error "No systemd-boot loader entries found in ${ENTRIES_PATH}"
}

# script to automate updates to systemd-boot loader entries' kernel options
# assumes all entries use the same kernel command line parameters
# does not change 'title' 'linux' or 'initrd' lines
function main() {

	check_progs
	check_conf_files
	
	# backup current options; assume arch.conf exists
	sed --quiet 's/^options[[:space:]]*//p' ${ENTRIES_PATH}/arch.conf > ${BACKUP}

	# read in new options
	OPTS=$(cat ${CMDLINE_FILE})
	echo "Using options: $OPTS..."

	#update options for all entries
	for entry in ${ENTRIES}
	do
		echo "Updating ${entry}..."
		sed --in-place "s#^options.*#options\t\t${OPTS}#" ${entry}
	done

	echo "Done."
	exit 0
}

main "$@"
