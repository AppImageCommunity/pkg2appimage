#!/usr/bin/env bash

# return true if the input command exists in $PATH
cmdExists() {
  command -v $1 >/dev/null 2>/dev/null;
  return $?;
}

getReadLink() {
  for read_tool in 'greadlink' 'readlink'; do
    cmdExists "$read_tool"
    if [ $? = 0 -o -f "$read_tool" ]; then
      READLINK="$read_tool"
      return 0
    fi
  done
  return 1
}

getSed() {
  for sed_tool in 'gsed' 'sed'; do
    cmdExists "$sed_tool"
    if [ $? = 0 -o -f "$sed_tool" ]; then
      SED="$sed_tool"
      return 0
    fi
  done
  return 1
}

getDate() {
  for date_tool in 'gdate' 'date'; do
    cmdExists "$date_tool"
    if [ $? = 0 -o -f "$date_tool" ]; then
      DATE="$date_tool"
      return 0
    fi
  done
  return 1
}

getReadLink
getSed
getDate

export READLINK
export SED
export DATE
