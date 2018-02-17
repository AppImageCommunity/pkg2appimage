#!/bin/bash

# Checks AppDir for maximum compatibility with AppImage best practices.
# This might evolve into a more formal specification one day.

set -e

HERE="$(dirname "$(readlink -f "${0}")")"
APPDIR="${1}"

fatal () {
  echo "FATAL: $1"
  exit 1
}

warn () {
  echo "WARNING: $1"
}

which desktop-file-validate >/dev/null
if [ ! $? -eq 0 ] ; then
  fatal "desktop-file-validate is missing, please install it"
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
  fatal "AppRun is not executable" // This seems to generate false alarms? https://travis-ci.org/AppImage/AppImageHub/builds/266084511#L539
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

desktop-file-validate "${APPDIR}"/*.desktop
if [ ! $? -eq 0 ] ; then
  fatal "desktop-file-validate did not exit cleanly on the .desktop file"
fi

num_keys_warn () {
  NUM_KEYS=$(grep -e "^${1}=.*" "${APPDIR}"/*.desktop | wc -l)
  if [ ${NUM_KEYS} != 1 ] ; then
    warn "Key $1 is not in .desktop file exactly once"
  fi
}

# num_keys_fatal Name # This is not a valid test since [Desktop Action ...] sections can also have Name=
# num_keys_fatal Exec # This is not a valid test since [Desktop Action ...] sections can also have Name=
# e.g, https://github.com/CDrummond/cantata/blob/master/cantata.desktop.cmake
num_keys_fatal Icon
num_keys_fatal Categories
# num_keys_warn Comment

# Find the relevant appdata.xml file;
# according to ximion, usr/share/appdata is a legacy path replaced by usr/share/metainfo
APPDATA=$(ls "${APPDIR}"/usr/share/metainfo/*appdata.xml 2>/dev/null | head -n 1) # TODO: Handle more than one better
if [ -z "$APPDATA" ] ; then
  APPDATA=$(ls "${APPDIR}"/usr/share/appdata/*appdata.xml 2>/dev/null | head -n 1) # TODO: Handle more than one better
fi
if [ -z "$APPDATA" ] ; then
  warn 'No appdata file present. Please provide one in the AppImage as per the instructions on https://www.freedesktop.org/software/appstream/docs/chap-Quickstart.html#sect-Quickstart-DesktopApps'
else
  if [ ! -z $(which appstreamcli) ] ; then
    appstreamcli validate-tree "${APPDIR}"
  else
    echo "Skipping AppStream validation since appstreamcli is not on the \$PATH"
  fi
fi


BLACKLISTED_FILES=$(cat "${HERE}/excludelist" | sed '/^\s*$/d' | sed '/^#.*$/d')
for FILE in $BLACKLISTED_FILES ; do
  if [ ! -z $(find "${APPDIR}" -name $FILE) ] ; then
    warn "Blacklisted file $FILE found"
  fi
done

echo "Lint found no fatal issues"
exit 0
