#!/usr/bin/env bash

# we want these files
# https://pkgbuild.com/~tpowa/archboot-images/x86_64/2022.01/boot/initramfs_x86_64.img
# https://pkgbuild.com/~tpowa/archboot-images/x86_64/2022.01/boot/initramfs_x86_64.img.sig
# https://pkgbuild.com/~tpowa/archboot-images/x86_64/2022.01/boot/vmlinuz_archboot_x86_64
# https://pkgbuild.com/~tpowa/archboot-images/x86_64/2022.01/boot/vmlinuz_archboot_x86_64.sig

# print an error and exit with failure
# $1: error message
function error() {
  echo "$0: error: $1" >&2
  exit 1
}

# ensure the programs needed to execute are available
function check_progs() {
  local PROGS="curl pacman-key mktemp install"
  which ${PROGS} > /dev/null 2>&1 || error "Searching PATH fails to find executables among: ${PROGS}"
}

function check_root() {
  [ "${EUID}" = 0 ] || error "Script must be run with root privileges."
}

function main() {
  check_root
  check_progs

  _ARCHBOOT_X86_64_BASE_URL="https://pkgbuild.com/~tpowa/archboot-images/x86_64/$(date --utc +%Y.%m)/boot"
  _ARCHBOOT_X86_64_INITRAMFS="initramfs_x86_64.img"
  _ARCHBOOT_X86_64_VMLINUZ="vmlinuz_archboot_x86_64"
  printf "Updating Archboot using URL: %s\n" "${_ARCHBOOT_X86_64_BASE_URL}"

  _ARCHBOOT_TEMPDIR=$(mktemp --directory)
  curl --no-progress-meter --create-dirs \
        --output-dir "${_ARCHBOOT_TEMPDIR}" \
        --remote-name-all \
        "${_ARCHBOOT_X86_64_BASE_URL}/${_ARCHBOOT_X86_64_INITRAMFS}" \
        "${_ARCHBOOT_X86_64_BASE_URL}/${_ARCHBOOT_X86_64_INITRAMFS}.sig" \
        "${_ARCHBOOT_X86_64_BASE_URL}/${_ARCHBOOT_X86_64_VMLINUZ}" \
        "${_ARCHBOOT_X86_64_BASE_URL}/${_ARCHBOOT_X86_64_VMLINUZ}.sig" || error "Error downloading files."

  pacman-key --verify "${_ARCHBOOT_TEMPDIR}/${_ARCHBOOT_X86_64_INITRAMFS}.sig" > /dev/null 2>&1 \
    || error "${_ARCHBOOT_X86_64_INITRAMFS} signature verification failed"
  pacman-key --verify "${_ARCHBOOT_TEMPDIR}/${_ARCHBOOT_X86_64_VMLINUZ}.sig" > /dev/null 2>&1 \
    || error "${_ARCHBOOT_X86_64_VMLINUZ} signature verification failed"

  # install files to /boot
  install --mode=0755 --target-directory="/boot" "${_ARCHBOOT_TEMPDIR}/${_ARCHBOOT_X86_64_INITRAMFS}"
  install --mode=0755 --target-directory="/boot" "${_ARCHBOOT_TEMPDIR}/${_ARCHBOOT_X86_64_VMLINUZ}"
}

main "$@"