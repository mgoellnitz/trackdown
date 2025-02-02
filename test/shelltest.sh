#!/bin/sh
#
# Copyright 2016-2025 Martin Goellnitz
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.
#

before() {
  CWD=`pwd`
  TEST=`basename $0 .sh`
  export DEB_GREP_ENABLE_STRAY_BACKSLASH_WARN=1
  # test mercurial availability
  HGAVAIL=`which hg`
  # echo "$HGAVAIL"
  if [ -z "$HGAVAIL" ] ; then
    echo "No hg/Mercurial available on the command line."
    exit 1
  fi

  rm -rf build/test/$TEST
  mkdir -p build/test/$TEST
  cd build/test/$TEST
  echo "Executing test '$TEST'"
}

after() {
  cd $CWD
}

# assert that variable $2 has value $3, outputs message $1 otherwise
assertEquals() {
  if [ "$2" != "$3" ] ; then
    echo "$1: '$2' - expected '$3'"
    pwd
    exit 1
  fi
}

# assert that file $2 exists, outputs message $1 otherwise
assertExists() {
  if [ ! -f $2 ] ; then 
    echo "$1: $2" 
    pwd
    exit 1
  fi
}
