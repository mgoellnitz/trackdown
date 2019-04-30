#!/bin/bash
#
# Copyright 2015-2018 Martin Goellnitz
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

# wind up the directory tree until we find a hidden folder of the given name $1
function windUp {
  while [ `pwd` != "/"  -a ! -d .$1 ] ; do
    cd ..
  done
}


# $1 message to issue when not given $2 parameter to check
function bailOnZero {
  if [ -z "$2" ] ; then
    echo $1
    exit
  fi
}  

# Exit if trackdown is not initialized
function checkTrackdown {
    if [ ! -f $TDCONFIG ] ; then
      echo "Project not initialized for trackdown use."
      exit
    fi
}

# Exit if jq is not installed
function checkJq {
  if [ `jq 2>&1|wc -l` = 0 ] ; then
    echo "To use this functionality, jq must be installed."
    exit
  fi
}

# Discover issues collection file from setup
function discoverIssues {
  if [ -z "$ISSUES" ] ; then
    ISSUES=`test -f $TDCONFIG && grep location= $TDCONFIG|cut -d '=' -f 2`
    if [ -z "$ISSUES" ] ; then
      test -d $TDBASE/.git && ISSUES=".git/trackdown/issues.md"
      test -d $TDBASE/.hg && ISSUES=".hg/trackdown/issues.md"
    fi
    ESCAPEDBASE=`echo $TDBASE|sed -e 's/\//\\\_xxxxx_\//g'|sed -e 's/_xxxxx_//g'`
    ISSUES=`echo $ISSUES|sed -e "s/^\([a-zA-Z0-9\.]\)/$ESCAPEDBASE\/\1/g"`
  fi
  if [ ! -f $ISSUES ] ; then
    echo "No issue collection file found. Are we in a TrackDown context?"
    exit
  fi
}

# Prevent mirror setup to occur repeatedly
function preventRepeatedMirrorInit {
  MIRROR=`test -f $TDCONFIG && grep mirror.type= $TDCONFIG|cut -d '=' -f 2`
  if [ ! -z $MIRROR ] ; then
    echo "Mirror setup already done in this repository with type $MIRROR."
    exit
  fi
}

# Discovers the VCS in use and sets up ignore file suppport variables
function ignoreFileHelper {
  if [ -d $TDBASE/.git ] ; then
    IGNOREFILE="$TDBASE/.gitignore"
    IFBEGIN="/"
    IFEND=""
  fi
  if [ -d $TDBASE/.hg ] ; then
    IGNOREFILE="$TDBASE/.hgignore"
    IFBEGIN="^"
    IFEND="\$"
  fi
  if [ ! -z "$IGNOREFILE" ] ; then
    CHECK=`grep -s .trackdown $IGNOREFILE|wc -l`
    if [ $CHECK = 0 ] ; then
      echo "${IFBEGIN}.trackdown${IFEND}" >> $IGNOREFILE
    fi
  fi
}

# Do common setup steps for collection for mirror type $1
function setupCollectionReference {
  COLLECTION=$1-issues.md
  test ! -d $TDBASE/.trackdown && mkdir $TDBASE/.trackdown
  echo "autocommit=false" > $TDCONFIG
  echo "autopush=false" >> $TDCONFIG
  echo "location=$COLLECTION" >> $TDCONFIG
  ignoreFileHelper
  if [ ! -z "$IGNOREFILE" ] ; then
    CHECK=`grep -s $COLLECTION $IGNOREFILE|wc -l`
    if [ $CHECK = 0 ] ; then
      echo "${IFBEGIN}$COLLECTION${IFEND}" >> $IGNOREFILE
    fi
    CHECK=`grep -s roadmap.md $IGNOREFILE|wc -l`
    if [ $CHECK = 0 ] ; then
     echo "${IFBEGIN}roadmap.md${IFEND}" >> $IGNOREFILE
    fi
  fi
  echo "mirror.type=$1" >> $TDCONFIG
  touch $TDBASE/$COLLECTION
}

# check if export result file $1 exists. Bails otherwise...
function checkExport {
  if [ ! -f $1 ] ; then
    echo "JSON export file $1 not found. Export seemed to have failed..."
    exit
  fi
}

# Create issue collection header with title $1 in issue collection file
function issueCollectionHeader {
  test -z "$2" && echo -n "" > $ISSUES
  echo "# $1" >>$ISSUES
  echo "" >>$ISSUES
  echo "" >>$ISSUES
  echo "[Roadmap](roadmap)" >>$ISSUES
}

# Generate a roadmap from the issue collection
function roadmap {
  echo "# Roadmap"
  echo ""
  IC=`basename $ISSUES .md`
  for rr in `grep -A2 "^\#\#\ " $ISSUES|grep "^\*[A-Za-z0-9][A-Za-z0-9\._\ -]*\*"|cut -d '*' -f 2|sort|uniq|sed -e 's/\ /__/g'` ; do
    r=`echo $rr|sed -e 's/__/ /g'`
    TOTAL=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|wc -l`
    RESOLVED=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|grep -i '(resolved)'|wc -l`
    PROGRESS=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|grep -i '(in progress)'|wc -l`
    RESPERC=$[$RESOLVED * 100 / $TOTAL]
    PROPERC=$[$PROGRESS * 100 / $TOTAL]
    RESTPERC=$[ 100 - $PROPERC - $RESPERC ]
    echo "## ${r}:"
    echo ""
    if [ $RESPERC -gt 0 ] ; then
      echo -n "![$RESPERC%](https://di.9f8.de/$[ $RESPERC * 7 ]x30/000000/FFFFFF.png&text=$RESPERC%25)"
    fi
    if [ $PROPERC -gt 0 ] ; then
      echo -n "![$PROPERC%](https://di.9f8.de/$[ $PROPERC * 7 ]x30/606060/FFFFFF.png&text=$PROPERC%25)"
    fi
    if [ $RESTPERC -gt 0 ] ; then
      echo -n "![$RESTPERC%](https://di.9f8.de/$[ $RESTPERC * 7 ]x30/eeeeee/808080.png&text=$RESTPERC%25)"
    fi
    echo ""
    echo ""
    echo "$RESPERC% completed ($RESOLVED/$TOTAL) - $PROPERC% in progress ($PROGRESS/$TOTAL)"
    echo ""
    grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /* /g'|awk '{print $NF,$0}'| sort | cut -f2- -d' '
    echo ""
  done
}

# Write the roadmap to the roadmap file
function writeRoadmap {
  ROADMAP=`dirname $ISSUES`/roadmap.md
  roadmap > $ROADMAP
}
