#!/usr/bin/env bash

set -e

# Push AppImages and related metadata to Bintray
# Make it generic for general consumption, I find it useful.
. ./common.sh

HERE="$(dirname "$($READLINK -f "${0}")")"

# Load environments from .env if exist
. ${HERE}/dotenv.sh

# https://bintray.com/docs/api/

set -e # Exit on errors
trap 'exit 1' ERR

API=https://api.bintray.com
FILE="$1"

[ -f "$FILE" ] || { echo "File '$FILE' doesn't exist"; exit; }

if [ "${BINTRAY_API_KEY}" == "" ] ; then
  echo "BINTRAY_API_KEY is missing; assuming this is a PR, uploading to transfer.sh"
  curl --upload-file ./"$FILE" https://transfer.sh/$(basename "$FILE")
  exit 0
fi

BINTRAY_USER="${BINTRAY_USER:-probono}"
BINTRAY_API_KEY="$BINTRAY_API_KEY" # env
BINTRAY_REPO="${BINTRAY_REPO:-AppImages}"
BINTRAY_REPO_OWNER="${BINTRAY_REPO_OWNER:-$BINTRAY_USER}" # owner and user not always the same
BINTRAY_PARAMETERS="${BINTRAY_PARAMETERS}"
if [ "x${BINTRAY_PARAMETERS}" != "x" ]; then
  BINTRAY_PARAMETERS=";${BINTRAY_PARAMETERS}"
fi
WEBSITE_URL="${WEBSITE_URL:-http://appimage.org}"
ISSUE_TRACKER_URL="${ISSUE_TRACKER_URL:-https://github.com/probonopd/AppImages/issues}"
VCS_URL="${VCS_URL:-https://github.com/probonopd/AppImages.git}" # Mandatory for packages in free Bintray repos
if [ "x${LICENSES}" != "x" ]; then
  IFS=',' read -r -a LIC <<< "${LICENSES}"
  LICENSES=
  for index in "${!LIC[@]}"
  do
    LICENSES=${LICENSES}_\"${LIC[index]}\"
  done
  LICENSES="@${LICENSES}@"
  LICENSES=$(echo $LICENSES | $SED "s|\@_||" | $SED "s/_/, /g" | $SED "s/\@//")
else
  LICENSES="\"MIT\""
fi
if [ "x${LABELS}" != "x" ]; then
  IFS=',' read -r -a LAB <<< "${LABELS}"
  LABELS=
  for index in "${!LAB[@]}"
  do
    LABELS=${LABELS}_\"${LAB[index]}\"
  done
  LABELS="@${LABELS}@"
  LABELS=$(echo $LABELS | $SED "s|\@_||" | $SED "s/_/, /g" | $SED "s/\@//")
else
  LABELS="\"AppImage\", \"AppImageKit\""
fi

# Figure out whether we should use sudo
SUDO=''
if (( EUID != 0 )); then
  SUDO='sudo'
fi

if [ -e /usr/bin/apt-get ] ; then
  $SUDO apt-get update >/dev/null
  $SUDO apt-get -y install curl bsdtar zsync
fi

if [ -e /usr/bin/yum ] ; then
  $SUDO yum install -y curl bsdtar zsync
fi

if [ -e /usr/bin/pacman ] ; then
  builddeps=('curl' 'libarchive' 'zsync')
  for i in "${builddeps[@]}"; do
    if ! pacman -Q "$i" >/dev/null; then
      $SUDO pacman -S "$i"
    fi
  done
fi

if [ -e /usr/bin/zypper ] ; then
  $SUDO zypper install -y curl bsdtar zsync
fi

if [ -e /usr/local/bin/brew ] ; then
  brew install curl coreutils zsync #Mac comes with bsdtar
fi

which curl >/dev/null || exit 1
which bsdtar >/dev/null || exit 1 # https://github.com/libarchive/libarchive/wiki/ManPageBsdtar1 ; isoinfo cannot read zisofs
which grep >/dev/null || exit 1
which zsyncmake >/dev/null || exit 1

# Do not upload artefacts generated as part of a pull request
if [ ! -z "$TRAVIS_PULL_REQUEST" ] ; then
  if [ "$TRAVIS_PULL_REQUEST" != "false" ] ; then
    echo "Not uploading since this is a pull request"
    exit 0
  fi
fi

CURL="curl -u${BINTRAY_USER}:${BINTRAY_API_KEY} -H Accept:application/json -w \n"

set -x # Be verbose from here on

CONTENT_TYPE="Content-Type:application/octet-stream"
IS_AN_APPIMAGE=$(file -kib "$FILE" | grep -q "application/x-executable" && file -kib "$FILE" | grep -q "application/x-iso9660-image" && echo 1 || true);
if [ "$IS_AN_APPIMAGE" ] ; then
  # Set content-type
  CONTENT_TYPE="Content-Type:application/x-iso9660-appimage" 
  # Get metadata from the desktop file inside the AppImage
  DESKTOP=$(bsdtar -tf "$FILE" | grep '^./[^/]*.desktop$' | head -n 1)
  # Extract the description from the desktop file

  echo "* DESKTOP $DESKTOP"

  PCK_NAME=$(bsdtar -f "$FILE" -O -x ./"${DESKTOP}" | grep -e "^Name=" | head -n 1 | $SED s/Name=//g | cut -d " " -f 1 | xargs)
  if [ "$PCK_NAME" == "" ] ; then
    bsdtar -f "$FILE" -O -x ./"${DESKTOP}"
    echo "PCK_NAME missing in ${DESKTOP}"
  fi

  DESCRIPTION=$(bsdtar -f "$FILE" -O -x ./"${DESKTOP}" | grep -e "^Comment=" | $SED s/Comment=//g)

  # Check if there is appstream data and use it
  APPDATANAME=$(echo "${DESKTOP}" | $SED 's/.desktop/.appdata.xml/g' | $SED 's|./||'  )
  APPDATAFILE=$(bsdtar -tf "$FILE" | grep "${APPDATANAME}$" | head -n 1 || true)
  APPDATA=$(bsdtar -f "$FILE" -O -x "${APPDATAFILE}" || true)
  if [ "$APPDATA" == "" ] ; then
    echo "* APPDATA missing"
  else
    echo "* APPDATA found"
    DESCRIPTION=$(echo "$APPDATA" | grep -o -e "<description.*description>" | $SED -e 's/<[^>]*>//g')
    WEBSITE_URL=$(echo "$APPDATA" | grep "homepage" | head -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1)
  fi

  if [ "$DESCRIPTION" == "" ] ; then
    bsdtar -f "$FILE" -O -x ./"${DESKTOP}"
    echo "DESCRIPTION missing and no Comment= in ${DESKTOP}"
  fi
fi

IS_TYPE2_APPIMAGE=$(dd if="$FILE" bs=1 skip=8 count=3 | xxd -u -ps | grep -q 414902 && echo 1 || true)
if [ "$IS_TYPE2_APPIMAGE" ] ; then
  ./"$FILE" --appimage-mount &
  AIPID=$?
  echo Mounted with PID $AIPID
  AIMOUNTPOINT=$(mount | grep "$($READLINK -f "$FILE")" | cut -d " " -f 3)
  echo "$AIMOUNTPOINT"

  # Get metadata from the desktop file inside the AppImage
  DESKTOP=$(find "$AIMOUNTPOINT" -maxdepth 1 -name '*.desktop' | head -n 1)
  # Extract the description from the desktop file
  echo "* DESKTOP $DESKTOP"

  PCK_NAME=$(cat "${DESKTOP}" | grep -e "^Name=" | head -n 1 | $SED s/Name=//g | cut -d " " -f 1 | xargs)
  if [ "$PCK_NAME" == "" ] ; then
    echo "PCK_NAME missing in ${DESKTOP}"
  fi
  echo "* PCK_NAME PCK_NAME"

  DESCRIPTION=$(cat "${DESKTOP}" | grep -e "^Comment=" | $SED s/Comment=//g)
  echo "* DESCRIPTION $DESCRIPTION"

  # Check if there is appstream data and use it
  APPDATA=$(echo "${DESKTOP}" | $SED 's/.desktop/.appdata.xml/g' | $SED 's|./||')
  if [ ! -e "$APPDATA" ] ; then
    echo "* APPDATA missing"
  else
    echo "* APPDATA found"
    DESCRIPTION=$(cat "$APPDATA" | grep -o -e "<description.*description>" | $SED -e 's/<[^>]*>//g')
    WEBSITE_URL=$(cat "$APPDATA" | grep "homepage" | head -n 1 | cut -d ">" -f 2 | cut -d "<" -f 1)
  fi

  if [ "$DESCRIPTION" == "" ] ; then
    echo "No AppStream data and no Comment= in ${DESKTOP}"
  fi
fi

[ "$PCK_NAME" == "" ] && PCK_NAME=$(basename "$FILE" | cut -d "_" -f 1)
[ "$VERSION" == "" ] && VERSION=$(basename "$FILE" | cut -d "_" -f 2)
[ "$PCK_NAME" == "" ] && PCK_NAME=$(basename "$FILE" | cut -d "-" -f 1)
[ "$VERSION" == "" ] && VERSION=$(basename "$FILE" | cut -d "-" -f 2)

if [ "$PCK_NAME" == "" ] ; then
  echo "* PCK_NAME missing, exiting"
  exit 1
else
  echo "* PCK_NAME $PCK_NAME"
fi

if [ "$VERSION" == "" ] ; then
  echo "* VERSION missing, exiting"
  exit 1
else
  echo "* VERSION $VERSION"
fi

if [ "$DESCRIPTION" == "" ] ; then
  echo "* DESCRIPTION <missing>"
else
  echo "* DESCRIPTION $DESCRIPTION"
fi

if [ "$LICENSES" == "" ] ; then
  echo "* LICENSES <missing>"
else
  echo "* LICENSES $LICENSES"
fi

if [ "$LABELS" == "" ] ; then
  echo "* LABELS <missing>"
else
  echo "* LABELS $LABELS"
fi

set +x # Do not be verbose from here on
##########

echo ""
echo "Creating package ${PCK_NAME}..."
data="{
    \"name\": \"${PCK_NAME}\",
    \"desc\": \"${DESCRIPTION}\",
    \"desc_url\": \"auto\",
    \"website_url\": [\"${WEBSITE_URL}\"],
    \"vcs_url\": [\"${VCS_URL}\"],
    \"issue_tracker_url\": [\"${ISSUE_TRACKER_URL}\"],
    \"licenses\": [${LICENSES}],
    \"labels\": [${LABELS}]
    }"
${CURL} -H Content-Type:application/json -X POST -d "${data}" "${API}/packages/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}"

if [ "$IS_AN_APPIMAGE" ] ; then
  # Eventually AppImageAssistant/package should do this. Do it manually in the meantime.
  echo "Embedding magic bytes for AppImage MIME type into ${FILE}..."
  printf "\x41\x49\x01" | dd bs=1 seek=8 conv=notrunc of="$FILE"
  if which zsyncmake > /dev/null 2>&1; then
    echo ""
    echo "Embedding update information into ${FILE}..."
    # Clear ISO 9660 Volume Descriptor #1 field "Application Used"
    # (contents not defined by ISO 9660) and write URL there
    dd if=/dev/zero of="$FILE" bs=1 seek=33651 count=512 conv=notrunc
    # Example for next line: Subsurface-_latestVersion-x86_64.AppImage
    NAMELATESTVERSION="$(basename "$FILE" | $SED -e "s|${VERSION}|_latestVersion|g")"
    # Example for next line: bintray-zsync|probono|AppImages|Subsurface|Subsurface-_latestVersion-x86_64.AppImage.zsync
    LINE="bintray-zsync|${BINTRAY_REPO_OWNER}|${BINTRAY_REPO}|${PCK_NAME}|${NAMELATESTVERSION}.zsync"
    echo "$LINE" | dd of="$FILE" bs=1 seek=33651 count=512 conv=notrunc
    echo ""
    echo "Uploading and publishing zsync file for ${FILE}..."
    zsyncmake -u "http://dl.bintray.com/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/$(basename "$FILE")" "$FILE" -o "${FILE}.zsync"
    ${CURL} -H Content-Type:application/octet-stream -T "${FILE}.zsync" "${API}/content/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${VERSION}/$(basename "$FILE").zsync?publish=1&override=1"
  else
    echo "zsyncmake not found, skipping zsync file generation and upload"
  fi
fi

if [ "$IS_TYPE2_APPIMAGE" ] ; then
  if which zsyncmake > /dev/null 2>&1; then
    echo ""
    echo "Sanity checking update information of ${FILE}..."
    HEXOFFSET=$(objdump -h "${FILE}" | grep .upd_info | awk '{print $6}')
    dd bs=1 if="${FILE}" skip=$((0x$HEXOFFSET)) count=7 | grep "bintray" || exit 1
    echo ""
    echo "Uploading and publishing zsync file for ${FILE}..."
    zsyncmake -u "http://dl.bintray.com/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/$(basename "$FILE")" "$FILE" -o "${FILE}.zsync"
    ${CURL} -H Content-Type:application/octet-stream -T "${FILE}.zsync" "${API}/content/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${VERSION}/$(basename "$FILE").zsync?publish=1&override=1"
  else
    echo "zsyncmake not found, skipping zsync file generation and upload"
  fi
fi

echo ""
echo "Uploading and publishing ${FILE}..."
${CURL} -H "$CONTENT_TYPE" -T "$FILE" "${API}/content/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/${VERSION}/$(basename "$FILE")${BINTRAY_PARAMETERS}?publish=1&override=1"

if [ "$TRAVIS_JOB_ID" ] ; then
echo ""
echo "Adding Travis CI log to release notes..."
BUILD_LOG="https://api.travis-ci.org/jobs/${TRAVIS_JOB_ID}/log.txt?deansi=true"
    data='{
  "bintray": {
    "syntax": "markdown",
    "content": "'${BUILD_LOG}'"
  }
}'
${CURL} -H Content-Type:application/json -X POST -d "${data}" "${API}/packages/${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}/versions/${VERSION}/release_notes"
fi

"${HERE}/bintray-tidy.sh" archive "${BINTRAY_REPO_OWNER}/${BINTRAY_REPO}/${PCK_NAME}" # -s to simulate
