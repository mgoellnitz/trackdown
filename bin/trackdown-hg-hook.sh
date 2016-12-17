#!/bin/bash
#
# Copyright 2015-2016 Martin Goellnitz
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

function roadmap {
  ROADMAP=`dirname $ISSUES`
  ROADMAP=${ROADMAP}/roadmap.md
  echo "# Roadmap" >$ROADMAP
  echo "" >>$ROADMAP
  IC=`basename $ISSUES .md`
  echo "[Issue Collection]($IC)" >>$ROADMAP
  echo "" >>$ROADMAP
  for rr in `grep -A2 "^\#\#\ " $ISSUES|grep "^\*[A-Za-z0-9][A-Za-z0-9\._\ ]*\*"|cut -d '*' -f 2|sort|uniq|sed -e 's/\ /__/g'` ; do
    r=`echo $rr|sed -e 's/__/ /g'`
    TOTAL=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|wc -l`
    RESOLVED=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|grep '(resolved)'|wc -l`
    PROGRESS=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|grep '(in progress)'|wc -l`
    echo "## ${r}:" >> $ROADMAP
    echo "" >> $ROADMAP
    echo "$[$RESOLVED * 100 / $TOTAL]% ($RESOLVED / $TOTAL) completed" >> $ROADMAP
    echo "$[$PROGRESS * 100 / $TOTAL]% ($PROGRESS / $TOTAL) in progress" >> $ROADMAP
    echo "" >> $ROADMAP
    grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /* /g'|awk '{print $NF,$0}'| sort | cut -f2- -d' ' >> $ROADMAP
    echo "" >> $ROADMAP
  done
}

VCS=hg
CWD=`pwd`
while [ `pwd` != "/"  -a `ls -d .$VCS 2>&1|head -1|cut -d ' ' -f 1` != ".$VCS" ] ; do
  cd ..
done
TDBASE=`pwd`
TDCONFIG=$TDBASE/.trackdown/config
echo "TrackDown: Base directory $TDBASE"
cd $CWD
if [ ! -f $TDCONFIG ] ; then
  echo "TrackDown: Not in a TrackDown context - ignoring commit"
fi
# Location of the issues file
ISSUES=`grep location= $TDCONFIG|cut -d '=' -f 2`
if [ -z "$ISSUES" ] ; then
  echo "TrackDown: Issue colletion file not configured - ignoring commit"
fi
# Prefix for links to online commit descriptions
PREFIX=`grep prefix= $TDCONFIG|cut -d '=' -f 2`
# echo "ISSUES $ISSUES"
AUTHOR=`hg log -l 1 --template "{author}\n"`
DATE=`hg log -l 1 --template "{localdate(date)|date}\n"`
LINE=`hg log -l 1 --template "{desc}\n"|grep \#`
STATUS=""
if [ ! -z "$LINE" ] ; then
  ID=`echo $LINE|sed -e 's/.*#\([0-9a-zA-Z,]*\).*/\1/g'`
  MARKER=`echo $LINE|grep -i "refs \#$ID"`
  if [ ! -z "$MARKER" ] ; then
    STATUS="in progress"
  fi
  MARKER=`echo $LINE|grep -i "fixes \#$ID"`
  if [ ! -z "$MARKER" ] ; then
    STATUS="resolved"
  fi
  MARKER=`echo $LINE|grep -i "resolves \#$ID"`
  if [ ! -z "$MARKER" ] ; then
    STATUS="resolved"
  fi
  MARKER=`echo $LINE|grep -i "resolve \#$ID"`
  if [ ! -z "$MARKER" ] ; then
    STATUS="resolved"
  fi
fi
HASH=`hg log -l 1 --template "{node}\n"`
echo "TrackDown: $ID $STATUS"
if [ ! -z "$STATUS" ] ; then
  for TID in `echo "$ID"|sed -e 's/,/\ /g'`; do
    HASID=`grep "^\#\#\ ${TID}" $ISSUES`
    if [ ! -z "$HASID" ] ; then
      echo "TrackDown: Issue $TID"
      sed -i.remove -e "s/##\ $TID\ \(.*\)\ (.*)/## $TID \1/g" $ISSUES
      sed -i.remove -e "s/##\ $TID\ \(.*\)/## $TID \1 ($STATUS)/g" $ISSUES
      rm $ISSUES.remove
      ISLAST=`grep -n "^\#\#\ " $ISSUES|grep -A1 "${TID}.*$STATUS" |tail -1|grep $TID`
      # echo "last: $ISLAST"
      if [ -z "$ISLAST" ] ; then
        SECTION=`grep -n "^\#\#\ " $ISSUES|grep -A1 "${TID}.*$STATUS"|tail -1|cut -d ':' -f 1`
        LINES=`cat $ISSUES|wc -l`
        # echo "SECTION $SECTION - LINES $LINES"
        head -$[ $SECTION - 1 ] $ISSUES >>$ISSUES.remove
        if [ -z "$PREFIX" ] ; then
          echo "$AUTHOR / ${DATE} (${HASH})" >>$ISSUES.remove
        else
          echo "$AUTHOR / ${DATE} [${HASH}](${PREFIX}${HASH})" >>$ISSUES.remove
        fi
        hg log -l 1 --template "{desc}\n" >>$ISSUES.remove
        echo "" >>$ISSUES.remove
        tail -$[ $LINES - $SECTION + 1 ] $ISSUES >>$ISSUES.remove
        mv $ISSUES.remove $ISSUES
      else
        echo "" >>$ISSUES
        echo $AUTHOR $DATE >>$ISSUES
        hg log -l 1 --template "{desc}\n" >>$ISSUES
      fi
    else
      echo "TrackDown: ID $TID not found in issues collection"
    fi
  done

  roadmap

  AUTOCOMMIT=`grep autocommit=true $TDCONFIG`
  # echo "AUTOCOMMIT: $AUTOCOMMIT"
  if [ ! -z "$AUTOCOMMIT" ] ; then
    WD=`pwd`
    TRACKDOWN=`dirname $ISSUES`
    VCS=`test -d $TRACKDOWN/.hg && echo hg || echo git`
    echo "TrackDown: committing with $VCS in $TRACKDOWN"
    ( cd $TRACKDOWN ; ${VCS} commit -m "Committed for issue(s) #$ID" issues.md roadmap.md > /dev/null)
    AUTOPUSH=`grep autopush=true $TDCONFIG`
    # echo "AUTOPUSH: $AUTOPUSH"
    if [ ! -z "$AUTOPUSH" ] ; then
      echo "TrackDown: pushing"
      ( cd $TRACKDOWN ; ${VCS} push > /dev/null )
    fi
  fi
else 
  roadmap
fi
