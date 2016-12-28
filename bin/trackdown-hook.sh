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
    RESPERC=$[$RESOLVED * 100 / $TOTAL]
    PROPERC=$[$PROGRESS * 100 / $TOTAL]
    RESTPERC=$[ 100 - $PROPERC - $RESPERC ]
    echo "## ${r}:" >> $ROADMAP
    echo "" >> $ROADMAP
    if [ $RESPERC -gt 0 ] ; then
      echo -n "[![$RESPERC%](https://dummyimage.com/$[ $RESPERC * 7 ]x30/000000/FFFFFF.png&text=$RESPERC%25)]()" >> $ROADMAP
    fi
    if [ $PROPERC -gt 0 ] ; then
      echo -n "[![$PROPERC%](https://dummyimage.com/$[ $PROPERC * 7 ]x30/606060/FFFFFF.png&text=$PROPERC%25)]()" >> $ROADMAP
    fi
    if [ $RESTPERC -gt 0 ] ; then
      echo -n "[![$RESTPERC%](https://dummyimage.com/$[ $RESTPERC * 7 ]x30/eeeeee/808080.png&text=$RESTPERC%25)]()" >> $ROADMAP
    fi
    echo "" >> $ROADMAP
    echo "" >> $ROADMAP
    echo "$RESPERC% ($RESOLVED / $TOTAL) completed " >> $ROADMAP
    echo "$PROPERC% ($PROGRESS / $TOTAL) in progress" >> $ROADMAP
    echo "" >> $ROADMAP
    grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /* /g'|awk '{print $NF,$0}'| sort | cut -f2- -d' ' >> $ROADMAP
    echo "" >> $ROADMAP
  done
}

CWD=`pwd`
while [ `pwd` != "/"  -a ! -d .trackdown ] ; do
  cd ..
done
TDBASE=`pwd`
VCS=`test -d .hg && echo hg || echo git`
TDCONFIG=$TDBASE/.trackdown/config
echo "TrackDown-$VCS: Base directory $TDBASE"
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
if [ $VCS = "hg" ] ; then
  AUTHOR=`hg log -l 1 --template "{author}\n"`
  DATE=`hg log -l 1 --template "{localdate(date)|date}\n"`
  LINE=`hg log -l 1 --template "{desc}\n"|grep \#`
  HASH=`hg log -l 1 --template "{node}\n"`
fi
if [ $VCS = "git" ] ; then
  AUTHOR=`git log -n 1 --format=%an`
  DATE=`git log -n 1 --format=%aD|cut -d '+' -f 1|sed -e 's/\ $//g'`
  LINE=`git log -n 1 --format=%s|grep \#`
  HASH=`git log -n 1 --format="%H"`
fi
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
        FILE=$ISSUES.remove
      else
        echo "" >>$ISSUES
        echo $AUTHOR $DATE >>$ISSUES
        FILE=$ISSUES
      fi
      echo "" >>$FILE
      if [ $VCS = "hg" ] ; then
        hg log -l 1 --template "{desc}\n" >>$FILE
      fi
      if [ $VCS = "git" ] ; then
        git log -n 1 --format="%s" >>$FILE
        BODY=`git log -n 1 --format="%b"`
        if [ ! -z "$BODY" ] ; then
          git log -n 1 --format="%b" >>$FILE
        fi
      fi
      if [ -z "$ISLAST" ] ; then
        echo "" >>$ISSUES.remove
        tail -$[ $LINES - $SECTION + 1 ] $ISSUES >>$ISSUES.remove
        mv $ISSUES.remove $ISSUES
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
