#!/bin/bash

# Checks AppDir for maximum compatibility with AppImage best practices.
# This might evolve into a more formal specification one day.

set -e

APPDIR="${1}"

fatal () {
  echo "FATAL: $1"
  exit 1
} 

warn () {
  echo "WARNING: $1"
}

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
  warn "No appdata file(s) present. Get some from upstream, https://github.com/hughsie/fedora-appstream/tree/master/appdata-extra/desktop or debian packages"
fi
