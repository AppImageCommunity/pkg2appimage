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
  FILES=$(find . -type f -executable)
  DEPS=""
  for FILE in $FILES ; do
    ldd "${FILE}" | grep "=>" | awk '{print $3}' | xargs -I '{}' echo '{}' > DEPSFILE
  done
  DEPS=$(cat DEPSFILE  |sort | uniq)
  for FILE in $DEPS ; do
    if [ -f $FILE ] ; then
      echo $FILE
      cp --parents -rfL $FILE ./
    fi
  done
  rm -f DEPSFILE
}
