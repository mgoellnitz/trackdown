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

# use command
if [ "$CMD" = "use" ] ; then

  cp $DIR/trackdown-hook.sh .git/hooks/post-commit
  chmod 755 .git/hooks/post-commit
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
  echo "/.trackdown" >> .gitignore
  echo "issues.md" >> .gitignore

fi


# ls command to list potential issues in the collection
if [ "$CMD" = "ls" ] ; then

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


# init command
if [ "$CMD" = "init" ] ; then

  git stash
  BRANCH=`git branch|grep '*'|cut -d ' ' -f 2`
  git checkout --orphan trackdown
  git rm -rf .
  touch issues.md
  git add -f issues.md
  git commit -m "Empty issues collection" issues.md
  git checkout $BRANCH
  git stash apply

fi
