#!/bin/bash

# Checks AppDir for maximum compatibility with AppImage best practices.
# This might evolve into a more formal specification one day.

set -e

HERE=$(dirname $(readlink -f "${0}"))
APPDIR="${1}"

fatal () {
  echo "FATAL: $1"
  exit 1
}

warn () {
  echo "WARNING: $1"
}

which desktop-file-edit
if [ ! $? -eq 0 ] ; then
  fatal "desktop-file-edit is missing, please install it"
fi

if [ ! -e "${HERE}/excludelist" ] ; then
  fatal "excludelist missing, please install it"
fi

if [ ! -d "${APPDIR}" ] ; then
  fatal "${APPDIR} is no directory"
fi

if [ ! -e "${APPDIR}/AppRun" ] ; then
  fatal "AppRun is missing in ${APPDIR}"
fi

if [ ! -x "${APPDIR}/AppRun" ] ; then
  fatal "AppRun is not executable"
fi

NUM_DESKTOP=$(ls "${APPDIR}"/*.desktop 2>/dev/null | wc -l)
if [ ${NUM_DESKTOP} != 1 ] ; then
  fatal "No .desktop file or multiple desktop files present"
fi

num_keys_fatal () {
  NUM_KEYS=$(grep -e "^${1}=.*" "${APPDIR}"/*.desktop | wc -l)
  if [ ${NUM_KEYS} != 1 ] ; then
    fatal "Key $1 is not in .desktop file exactly once"
  fi
}

desktop-file-edit "${APPDIR}"/*.desktop
if [ ! $? -eq 0 ] ; then
  fatal "desktop-file-edit did not exit cleanly on the .desktop file"
fi

num_keys_warn () {
  NUM_KEYS=$(grep -e "^${1}=.*" "${APPDIR}"/*.desktop | wc -l)
  if [ ${NUM_KEYS} != 1 ] ; then
    warn "Key $1 is not in .desktop file exactly once"
  fi
}

num_keys_fatal Name
num_keys_fatal Exec
num_keys_fatal Icon
num_keys_fatal Categories
num_keys_warn Comment

NUM_APPDATA=$(ls "${APPDIR}"/usr/share/appdata/.xml 2>/dev/null | wc -l)
if [ ! ${NUM_APPDATA} -gt 1 ] ; then
  warn 'No appdata file(s) present. Get some from upstream, https://github.com/hughsie/fedora-appstream/tree/master/appdata-extra/desktop or debian packages'
fi

BLACKLISTED_FILES=$(cat "${HERE}/excludelist" | sed '/^\s*$/d' | sed '/^#.*$/d')
FOUND=""
for FILE in $BLACKLISTED_FILES ; do
  FOUND=$(find "${APPDIR}" -type f -name "${FILE}" 2>/dev/null)
  echo $FOUND
  if [ ! -z "$FOUND" ] ; then
    fatal "Blacklisted file ${FOUND} found"
  fi
done
