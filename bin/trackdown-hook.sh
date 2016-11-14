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
  for r in `grep "^\*[A-Za-z0-9\._]*\*" $ISSUES|cut -d '*' -f 2|sort|uniq` ; do
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

# Create config file if none exists
if [ ! -f .trackdown/config ] ; then
  if [ ! -d .trackdown ] ; then
    mkdir .trackdown
  fi
  echo "autocommit=true" > .trackdown/config
  echo "autopush=true" >>  .trackdown/config
  echo "location=.git/trackdown/issues.md" >>  .trackdown/config
  echo "/.trackdown" >> .gitignore
fi
# Location of the issues file
ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
if [ -z "$ISSUES" ] ; then
  ISSUES=".git/trackdown/issues.md"
fi
# Prefix for links to online commit descriptions
PREFIX=`grep prefix= .trackdown/config|cut -d '=' -f 2`
# echo "ISSUES $ISSUES"
MSGLINES=`git log -n 1|wc -l`
AUTHOR=`git log -n 1|grep Author|cut -d ':' -f 2-10|sed -e s/\<.*\>//g`
DATE=`git log -n 1|grep Date|cut -d ':' -f 2-10|cut -d '+' -f 1|cut -d '-' -f 1|sed -e s'/^\  //g'`
LINE=`git log -n 1|tail -$[ $MSGLINES - 4 ]|grep \#`
STATUS=""
if [ ! -z "$LINE" ] ; then
  ID=`echo $LINE|sed -e 's/.*#\([0-9a-zA-Z]*\).*/\1/g'`
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
HASH=`git log|head -1|cut -d ' ' -f 2`
HASID=`grep "^\#\#\ ${ID}" $ISSUES`
if [ -z "$HASID" ] ; then
  echo "ID $ID not found in issues collection"
  roadmap
  exit
fi
echo "$ID $STATUS"
if [ ! -z "$STATUS" ] ; then
  sed -i.remove -e "s/##\ $ID\ \(.*\)\ (.*)/## $ID \1/g" $ISSUES
  sed -i.remove -e "s/##\ $ID\ \(.*\)/## $ID \1 ($STATUS)/g" $ISSUES
  rm $ISSUES.remove
  # grep -n "^\#\#\ " $ISSUES
  # echo ""
  # grep -n "^\#\#\ " $ISSUES|grep -A1 "${ID}.*$STATUS"
  # echo ""
  # grep -n "^\#\#\ " $ISSUES|grep -A1 "${ID}.*$STATUS|tail -1"
  ISLAST=`grep -n "^\#\#\ " $ISSUES|grep -A1 "${ID}.*$STATUS" |tail -1|grep $ID`
  # echo "last: $ISLAST"
  if [ -z "$ISLAST" ] ; then
    SECTION=`grep -n "^\#\#\ " $ISSUES|grep -A1 "${ID}.*$STATUS"|tail -1|cut -d ':' -f 1`
    LINES=`cat $ISSUES|wc -l`
    # echo "SECTION $SECTION - LINES $LINES"
    head -$[ $SECTION - 1 ] $ISSUES >>$ISSUES.remove
    if [ -z "$PREFIX" ] ; then
      echo "$AUTHOR /${DATE}(${HASH})" >>$ISSUES.remove
    else
      echo "$AUTHOR /${DATE}[${HASH}](${PREFIX}${HASH})" >>$ISSUES.remove
    fi
    git log -n 1|tail -$[ $MSGLINES - 3 ] >>$ISSUES.remove
    echo "" >>$ISSUES.remove
    tail -$[ $LINES - $SECTION + 1 ] $ISSUES >>$ISSUES.remove
    mv $ISSUES.remove $ISSUES
  else
    echo "" >>$ISSUES
    echo $AUTHOR $DATE >>$ISSUES
    git log -n 1|tail -$[ $MSGLINES - 3 ] >>$ISSUES
  fi

  roadmap

  AUTOCOMMIT=`grep autocommit=true .trackdown/config`
  # echo "AUTOCOMMIT: $AUTOCOMMIT"
  if [ ! -z "$AUTOCOMMIT" ] ; then
    WD=`pwd`
    TRACKDOWN=`dirname $ISSUES`
    cd $TRACKDOWN
    echo "TrackDown: committing"
    git commit -m "Committed for issue #$ID" issues.md > /dev/null
    git commit -m "Committed for issue #$ID" roadmap.md > /dev/null
    cd $WD
    AUTOPUSH=`grep autopush=true .trackdown/config`
    # echo "AUTOPUSH: $AUTOPUSH"
    if [ ! -z "$AUTOPUSH" ] ; then
      cd $TRACKDOWN
      echo "TrackDown: pushing"
      git push > /dev/null
      cd $WD
    fi
  fi
else 
  roadmap
fi
