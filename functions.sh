# This file is supposed to be sourced by each Recipe
# that wants to use the functions contained herein
# like so:
# wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh
# . ./functions.sh

# RECIPE=$(realpath "$0")

# Options for apt-get to use local files rather than the system ones
OPTIONS="-o Debug::NoLocking=1
-o APT::Cache-Limit=125829120
-o Dir::Etc::sourcelist=./sources.list
-o Dir::State=./tmp
-o Dir::Cache=./tmp
-o Dir::State::status=./status
-o Dir::Etc::sourceparts=-
-o APT::Get::List-Cleanup=0
-o APT::Get::AllowUnauthenticated=1
-o Debug::pkgProblemResolver=true
-o Debug::pkgDepCache::AutoInstall=true
-o APT::Install-Recommends=0
-o APT::Install-Suggests=0
"

git_pull_rebase_helper()
{
  git reset --hard HEAD
  git pull
}

# Patch /usr to ././ in ./usr
# to make the contents of usr/ relocateable
# (this requires us to cd ./usr before running the application; AppRun does that)
patch_usr()
{
  find usr/ -type f -executable -exec sed -i -e "s|/usr|././|g" {} \;
}

# Download AppRun and make it executable
get_apprun()
{
  # wget -c https://github.com/probonopd/AppImageKit/releases/download/5/AppRun -O ./AppRun # 64-bit
  wget -c https://github.com/probonopd/AppImageKit/releases/download/6/AppRun_6-x86_64 -O AppRun # 64-bit
  chmod a+x AppRun
}

# Copy the library dependencies of all exectuable files in the current directory
# (it can be beneficial to run this multiple times)
copy_deps()
{
  FILES=$(find . -type f -executable -or -name *.so.* -or -name *.so | sort | uniq )
  for FILE in $FILES ; do
    ldd "${FILE}" | grep "=>" | awk '{print $3}' | xargs -I '{}' echo '{}' >> DEPSFILE
  done
  DEPS=$(cat DEPSFILE | sort | uniq)
  for FILE in $DEPS ; do
    if [ -e $FILE ] ; then
      cp -v --parents -rfL $FILE ./
    fi
  done
  rm -f DEPSFILE
}

# Move ./lib/ tree to ./usr/lib/
move_lib()
{
  mkdir -p ./usr/lib ./lib && find ./lib/ -exec cp -v --parents -rfL {} ./usr/ \; && rm -rf ./lib
  mkdir -p ./usr/lib ./lib64 && find ./lib64/ -exec cp -v --parents -rfL {} ./usr/ \; && rm -rf ./lib64
}

# Delete blacklisted files
delete_blacklisted()
{
  BLACKLISTED_FILES=$(wget -q https://github.com/probonopd/AppImages/raw/master/excludelist -O - | sed '/^\s*$/d' | sed '/^#.*$/d')
  echo $BLACKLISTED_FILES
  for FILE in $BLACKLISTED_FILES ; do
    FOUND=$(find . -type f -name "${FILE}" 2>/dev/null)
    if [ ! -z "$FOUND" ] ; then
      echo "Deleting blacklisted ${FOUND}"
      rm -f "${FOUND}"
    fi
  done
}

# Echo highest glibc version needed by the executable files in the current directory
glibc_needed()
{
  find . -name *.so -or -name *.so.* -or -type f -executable  -exec strings {} \; | grep ^GLIBC_2 | sed s/GLIBC_//g | sort --version-sort | uniq | tail -n 1
}
# Add desktop integration
# Usage: get_desktopintegration name_of_desktop_file_and_exectuable
get_desktopintegration()
{
  wget -O ./usr/bin/$1.wrapper https://raw.githubusercontent.com/probonopd/AppImageKit/master/desktopintegration
  chmod a+x ./usr/bin/$1.wrapper
  sed -i -e "s|Exec=$1|Exec=$1.wrapper|g" $1.desktop
}

# Generate AppImage; this expects $ARCH, $APP and $VERSION to be set
generate_appimage()
{
  # if [[ "$RECIPE" == *ecipe ]] ; then
  #   echo "#!/bin/bash -ex" > ./$APP.AppDir/Recipe
  #   echo "# This recipe was used to generate this AppImage." >> ./$APP.AppDir/Recipe
  #   echo "# See http://appimage.org for more information." >> ./$APP.AppDir/Recipe
  #   echo "" >> ./$APP.AppDir/Recipe
  #   cat $RECIPE >> ./$APP.AppDir/Recipe
  # fi
  #
  # Detect the architecture of what we are packaging.
  # The main binary could be a script, so let's use a .so library
  BIN=$(find . -name *.so* -type f | head -n 1)
  INFO=$(file "$BIN")
  if [ -z $ARCH ] ; then
    if [[ $INFO == *"x86-64"* ]] ; then
      ARCH=x86_64
    elif [[ $INFO == *"i686"* ]] ; then
      ARCH=i686
    elif [[ $INFO == *"armv6l"* ]] ; then
      ARCH=armhf
    else
      echo "Could not automatically detect the architecture."
      echo "Please set the \$ARCH environment variable."
     exit 1
    fi
  fi
  wget -c "https://github.com/probonopd/AppImageKit/releases/download/6/AppImageAssistant_6-x86_64.AppImage" -O  AppImageAssistant # (64-bit)
  chmod a+x ./AppImageAssistant
  mkdir -p ../out
  rm ../out/$APP"-"$VERSION"-x86_64.AppImage" 2>/dev/null || true
  ./AppImageAssistant ./$APP.AppDir/ ../out/$APP"-"$VERSION"-"$ARCH".AppImage"
}

# Generate AppImage; this expects $ARCH, $APP and $VERSION to be set
# TODO: Remove the need for the ENVs
generate_type2_appimage()
{
  mkdir -p ../out
  rm ../out/$APP"-"$VERSION"-x86_64.AppImage" 2>/dev/null || true
  # Get the ID of the last successful build on Travis CI
  ID=$(wget -q https://api.travis-ci.org/repos/probonopd/appimagetool/builds -O - | head -n 1 | sed -e 's|}|\n|g' | grep '"result":0' | head -n 1 | sed -e 's|,|\n|g' | grep '"id"' | cut -d ":" -f 2)
  # Get the transfer.sh URL from the logfile of the last successful build on Travis CI
  URL=$(wget -q "https://s3.amazonaws.com/archive.travis-ci.org/jobs/$((ID+1))/log.txt" -O - | grep "https://transfer.sh/.*/appimagetool" | tail -n 1 | sed -e 's|\r||g')
  wget "$URL" -o appimagetool
  chmod a+x ./appimagetool
  ./appimagetool ./$APP.AppDir/ ../out/$APP"-"$VERSION"-"$ARCH".AppImage"
}

# Generate status file for use by apt-get; assuming that the recipe uses no newer
# ingredients than what would require more recent dependencies than what we assume 
# to be part of the base system
generate_status()
{
  mkdir -p ./tmp/archives/
  mkdir -p ./tmp/lists/partial
  touch tmp/pkgcache.bin tmp/srcpkgcache.bin
  wget -q -c "https://github.com/probonopd/AppImages/raw/master/excludedeblist"
  rm status 2>/dev/null || true
  for PACKAGE in $(cat excludedeblist | cut -d "#" -f 1) ; do
    printf "Package: $PACKAGE\nStatus: install ok installed\nArchitecture: all\nVersion: 9:9999.9999.9999\n\n" >> status
  done
}

# transfer.sh
transfer() { if [ $# -eq 0 ]; then echo "No arguments specified. Usage:\necho transfer /tmp/test.md\ncat /tmp/test.md | transfer test.md"; return 1; fi 
tmpfile=$( mktemp -t transferXXX ); if tty -s; then basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g'); curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> $tmpfile; else curl --progress-bar --upload-file "-" "https://transfer.sh/$1" >> $tmpfile ; fi; cat $tmpfile; rm -f $tmpfile; } 
