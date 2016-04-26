# This file is supposed to be sourced by each Recipe
# that wants to use the functions contained herein
# like so:
# wget -q https://github.com/probonopd/AppImages/raw/master/functions.sh -O ./functions.sh
# . ./functions.sh

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
  wget -c https://github.com/probonopd/AppImageKit/releases/download/5/AppRun -O ./AppRun # 64-bit
  chmod a+x AppRun
}

# Copy the library dependencies of all exectuable files in the current directory
# (it can be beneficial to run this multiple times)
copy_deps()
{
  FILES=$(find . -type f -executable -or -path *lib* -name *.so.* | wc -l)
  for FILE in $FILES ; do
    ldd "${FILE}" | grep "=>" | awk '{print $3}' | xargs -I '{}' echo '{}' >> DEPSFILE
  done
  DEPS=$(cat DEPSFILE | sort | uniq)
  for FILE in $DEPS ; do
    if [ -f $FILE ] ; then
      echo $FILE
      cp --parents -rfL $FILE ./
    fi
  done
  rm -f DEPSFILE
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
  find . -type f -executable -exec strings {} \; | grep ^GLIBC_2 | sed s/GLIBC_//g | sort --version-sort | uniq | tail -n 1
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
  wget -c "https://github.com/probonopd/AppImageKit/releases/download/5/AppImageAssistant" # (64-bit)
  chmod a+x ./AppImageAssistant
  mkdir -p ../out
  rm ../out/$APP"-"$VERSION"-x86_64.AppImage" || true
  ./AppImageAssistant ./$APP.AppDir/ ../out/$APP"-"$VERSION"-"$ARCH".AppImage"
}
