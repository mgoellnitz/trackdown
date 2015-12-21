#!/bin/bash
#
# Copyright 2015 Martin Goellnitz
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

CMD=$1
ISSUES=$2
DIR=`dirname $0`

# usage command
if [ -z "$CMD" ] ; then

  MYNAME=`basename $0`
  echo "Usage:"
  echo ""
  echo "$MYNAME roadmap"
  echo "  print roadmap"
  echo ""
  echo "$MYNAME ls v"
  echo "  list issues for version v"
  echo ""
  echo "$MYNAME issues"
  echo "  list all potential issues"
  echo ""
  echo "$MYNAME use [collections file]"
  echo "  setup clone for issue tracking (optional with non default file)"
  echo ""
  echo "$MYNAME init"
  echo "  init issue tracking within GIT branch"

fi


# ls command to list potential issues in the collection for a certain release
if [ "$CMD" = "ls" ] ; then

  # Location of the issues file
  ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
  if [ -z "$ISSUES" ] ; then
    ISSUES=".git/trackdown/issues.md"
  fi
  grep -B2 "^\*$2\*" $ISSUES|grep "^\#\#\ "

fi


# ls command to list potential issues in the collection for a certain release
if [ "$CMD" = "roadmap" ] ; then

  # Location of the issues file
  ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
  if [ -z "$ISSUES" ] ; then
    ISSUES=".git/trackdown/issues.md"
  fi
  echo "# Roadmap"
  echo ""
  for r in `grep "^\*[A-Za-z0-9\._]*\*" $ISSUES|cut -d '*' -f 2|uniq|sort` ; do
    TOTAL=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|wc -l`
    RESOLVED=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|grep '(resolved)'|wc -l`
    echo "## ${r} - $[$RESOLVED * 100 / $TOTAL]% completed - $RESOLVED / $TOTAL:"
    echo ""
    grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'
    echo ""
  done

fi


# issues command to list all potential issues in the collection
if [ "$CMD" = "issues" ] ; then

  # Location of the issues file
  ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
  if [ -z "$ISSUES" ] ; then
    ISSUES="$2"
  fi
  if [ -z "$ISSUES" ] ; then
    ISSUES=".git/trackdown/issues.md"
  fi
  grep "^\#\#\ " $ISSUES | sed -e "s/^##\ /- /g"

fi


# use command
if [ "$CMD" = "use" ] ; then

  if [ ! -d .git ] ; then
    echo "Not in a GIT repository. Exiting."
    exit
  fi
  if [ `git branch -l|wc -l` = 0 ] ; then
    echo "GIT repository missing commits. Exiting."
    exit
  fi
  cp $DIR/trackdown-hook.sh .git/hooks/post-commit
  chmod 755 .git/hooks/post-commit
  mkdir .trackdown
  if [ -z "$ISSUES" ] ; then
    ISSUES=".git/trackdown/issues.md"
    cd .git
    # git clone --single-branch --branch trackdown .. trackdown
    git clone --branch trackdown .. trackdown
    cd ..
    echo "autocommit=true" > .trackdown/config
    echo "autopush=true" >>  .trackdown/config
    echo "location=.git/trackdown/issues.md" >>  .trackdown/config
  else
    echo "autocommit=false" > .trackdown/config
    echo "autopush=false" >>  .trackdown/config
    echo "location=$ISSUES" >>  .trackdown/config
  fi
  ln -s $ISSUES issues.md
  ln -s `dirname $ISSUES`/roadmap.md roadmap.md
  echo "/.trackdown" >> .gitignore
  echo "issues.md" >> .gitignore
  echo "roadmap.md" >> .gitignore

fi


# init command
if [ "$CMD" = "init" ] ; then

  if [ ! -d .git ] ; then
    echo "Not in a GIT repository. Exiting."
    exit
  fi
  if [ `git log|wc -l` = 0 ] ; then
    echo "GIT repository missing commits. Exiting."
    exit
  fi
  git stash
  BRANCH=`git branch|grep '*'|cut -d ' ' -f 2`
  git checkout --orphan trackdown
  git rm -rf .
  touch issues.md
  touch roadmap.md
  git add -f issues.md
  git add -f roadmap.md
  git commit -m "Empty issues collection" issues.md roadmap.md
  git checkout $BRANCH
  git stash apply

fi
