#!/bin/bash
#
# Copyright 2015-2026 Martin Goellnitz
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
# shellcheck disable=SC2086
# shellcheck disable=SC2129
# shellcheck disable=SC2164
DIR=$(dirname $(readlink -f $0))
. $DIR/trackdown-lib.sh
CWD=$(pwd)
windUp trackdown
TDBASE=$(pwd)
VCS=$(test -d .hg && echo hg || echo git)
TDCONFIG=$TDBASE/.trackdown/config
echo "TrackDown-$VCS: Base directory $TDBASE"
cd $CWD
checkTrackdown
discoverIssues
# Prefix for links to online commit descriptions
PREFIX=$(grep prefix= $TDCONFIG|cut -d '=' -f 2)
# echo "ISSUES $ISSUES"
if [ $VCS = "hg" ] ; then
  AUTHOR$(hg log -l 1 --template "{person(author)}\n")
  DATE=$(hg log -l 1 --template "{localdate(date)|date}\n")
  LINE=$(hg log -l 1 --template "{desc}\n"|grep \#)
  HASH=$(hg log -l 1 --template "{node}\n")
fi
if [ $VCS = "git" ] ; then
  AUTHOR=$(git log -n 1 --format=%an)
  DATE=$(git log -n 1 --format=%aD|cut -d '+' -f 1|sed -e 's/\ $//g')
  LINE=$(git log -n 1 --format=%s|grep \#)
  HASH=$(git log -n 1 --format="%H")
fi
STATUS=""
if [ ! -z "$LINE" ] ; then
  echo "Line: $LINE"
  ID=$(echo $LINE|sed -e 's/.*#\([0-9a-zA-Z,]*\).*/\1/g')
  echo "ID: $ID"
  MARKER=$(echo $LINE|grep -i "refs #$ID")
  if [ ! -z "$MARKER" ] ; then
    STATUS="in progress"
  fi
  MARKER=$(echo $LINE|grep -i "fixes #$ID")
  if [ ! -z "$MARKER" ] ; then
    STATUS="resolved"
  fi
  MARKER=$(echo $LINE|grep -i "resolves #$ID")
  if [ ! -z "$MARKER" ] ; then
    STATUS="resolved"
  fi
  MARKER=$(echo $LINE|grep -i "resolve #$ID")
  if [ ! -z "$MARKER" ] ; then
    STATUS="resolved"
  fi
fi
echo "TrackDown-$VCS: $ID $STATUS"
if [ ! -z "$STATUS" ] ; then
  for TID in $(echo "$ID"|sed -e 's/,/\ /g'); do
    HASID=$(grep "^##\s${TID}" $ISSUES)
    if [ ! -z "$HASID" ] ; then
      echo "TrackDown: Issue $TID"
      sed -i.remove -e "s/##\ $TID\ \(.*\)\ (.*)/## $TID \1/g" $ISSUES
      sed -i.remove -e "s/##\ $TID\ \(.*\)/## $TID \1 ($STATUS)/g" $ISSUES
      rm $ISSUES.remove
      ISLAST=$(grep -n "^##\s" $ISSUES|grep -A1 "${TID}.*$STATUS" |tail -1|grep $TID)
      # echo "last: $ISLAST"
      if [ -z "$ISLAST" ] ; then
        SECTION=$(grep -n "^##\s" $ISSUES|grep -A1 "${TID}.*$STATUS"|tail -1|cut -d ':' -f 1)
        LINES=$(cat $ISSUES|wc -l)
        # echo "SECTION $SECTION - LINES $LINES"
        FILE=$ISSUES.remove
        head -$(( SECTION - 1 )) $ISSUES >>$FILE
      else
        FILE=$ISSUES
        echo "" >>$FILE
      fi
      if [ -z "$PREFIX" ] ; then
        echo "$AUTHOR / ${DATE} (${HASH})" >>$FILE
      else
        echo "$AUTHOR / ${DATE} [${HASH}](${PREFIX}${HASH})" >>$FILE
      fi
      echo "" >>$FILE
      if [ $VCS = "hg" ] ; then
        hg log -l 1 --template "    {desc}\n" >>$FILE
      fi
      if [ $VCS = "git" ] ; then
        git log -n 1 --format="    %s" >>$FILE
        BODY=$(git log -n 1 --format="%b")
        if [ ! -z "$BODY" ] ; then
          git log -n 1 --format="    %b" >>$FILE
        fi
      fi
      if [ -z "$ISLAST" ] ; then
        echo "" >>$ISSUES.remove
        tail -$(( LINES - SECTION + 1 )) $ISSUES >>$ISSUES.remove
        mv $ISSUES.remove $ISSUES
      fi
    else
      echo "TrackDown: ID $TID not found in issues collection"
    fi
  done

  writeRoadmap

  AUTOCOMMIT=$(grep autocommit=true $TDCONFIG)
  # echo "AUTOCOMMIT: $AUTOCOMMIT"
  if [ ! -z "$AUTOCOMMIT" ] ; then
    WD=$(pwd)
    TRACKDOWN=$(dirname $ISSUES)
    # TODO: Why do we re-discover the VCS here?
    VCS=$(test -d $TRACKDOWN/.hg && echo hg || echo git)
    echo "TrackDown: committing with $VCS in $TRACKDOWN"
    ( cd $TRACKDOWN ; ${VCS} commit -m "Committed for issue(s) #$ID" issues.md roadmap.md > /dev/null)
    AUTOPUSH=$(grep autopush=true $TDCONFIG)
    # echo "AUTOPUSH: $AUTOPUSH"
    if [ ! -z "$AUTOPUSH" ] ; then
      echo "TrackDown: pushing"
      ( cd $TRACKDOWN ; ${VCS} pull ; ${VCS} push > /dev/null )
    fi
  fi
else 
  writeRoadmap
fi
