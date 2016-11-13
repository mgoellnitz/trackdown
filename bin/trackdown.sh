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

CMD=$1
ISSUES=$2
DIR=`dirname $0`

# usage command
if [ -z "$CMD" ] ; then

  MYNAME=`basename $0`
  echo "Usage:"
  echo ""
  echo "$MYNAME roadmap [collections file]"
  echo "  print roadmap"
  echo ""
  echo "$MYNAME ls v [collections file]"
  echo "  list issues for version v"
  echo ""
  echo "$MYNAME issues [collections file]"
  echo "  list all potential issues"
  echo ""
  echo "$MYNAME use [collections file]"
  echo "  setup clone for issue tracking (optional with non default file)"
  echo ""
  echo "$MYNAME update"
  echo "  just update the commit hook"
  echo ""
  echo "$MYNAME init"
  echo "  init issue tracking within GIT branch"
  echo ""
  echo "$MYNAME mirror"
  echo "  sync with reviously setup tracking master (redmine - needs jq)"
  echo ""
  echo "$MYNAME redmine k u"
  echo "  setup redmine mirroring with given apikey k and issues json url u (needs jq)"
  echo ""
  echo "$MYNAME sync"
  echo "  directly push issues GIT to upstream (rarely usefull)"

fi


# ls command to list potential issues in the collection for a certain release
if [ "$CMD" = "ls" ] ; then

  # Location of the issues file
  ISSUES=$3
  if [ -z "$ISSUES" ] ; then
    ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
  fi
  if [ -z "$ISSUES" ] ; then
    ISSUES=".git/trackdown/issues.md"
  fi
  grep -B2 "^\*$2\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /* /g'

fi


# ls command to list potential issues in the collection for a certain release
if [ "$CMD" = "roadmap" ] ; then

  # Location of the issues file
  if [ -z "$ISSUES" ] ; then
    ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
  fi
  if [ -z "$ISSUES" ] ; then
    ISSUES=".git/trackdown/issues.md"
  fi
  echo "# Roadmap"
  echo ""
  for rr in `grep "^\*[A-Za-z0-9][A-Za-z0-9\._\ ]*\*" $ISSUES|cut -d '*' -f 2|sort|uniq|sed -e 's/\ /__/g'` ; do
    r=`echo $rr|sed -e 's/__/ /g'`
    TOTAL=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|wc -l`
    RESOLVED=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|grep -i '(resolved)'|wc -l`
    PROGRESS=`grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /\#\#\# /g'|grep -i '(in progress)'|wc -l`
    echo "## ${r}:"
    echo ""
    echo "$[$RESOLVED * 100 / $TOTAL]% ($RESOLVED / $TOTAL) completed"
    echo "$[$PROGRESS * 100 / $TOTAL]% ($PROGRESS / $TOTAL) in progress"
    echo ""
    grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /* /g'
    echo ""
  done

fi


# issues command to list all potential issues in the collection
if [ "$CMD" = "issues" ] ; then

  # Location of the issues file
  ISSUES="$2"
  if [ -z "$ISSUES" ] ; then
    ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
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
  if [ -f .trackdown/config ] ; then
    echo "Project already initialized for trackdown use."
    exit
  fi
  cp $DIR/trackdown-hook.sh .git/hooks/post-commit
  chmod 755 .git/hooks/post-commit
  if [ ! -d .trackdown ] ; then
    mkdir .trackdown
  fi
  if [ -z "$ISSUES" ] ; then
    ISSUES=".git/trackdown/issues.md"
    NAME=`git config -l|grep user.email|cut -d '=' -f 2`
    MAIL=`git config -l|grep user.name|cut -d '=' -f 2`
    cd .git
    # git clone --single-branch --branch trackdown .. trackdown
    git clone --branch trackdown .. trackdown
    cd trackdown
    git config --local push.default simple
    git config --local user.email "$MAIL"
    git config --local user.name "$NAME"
    cd ../..
    echo "autocommit=true" > .trackdown/config
    echo "autopush=true" >>  .trackdown/config
    echo "location=.git/trackdown/issues.md" >>  .trackdown/config
  else
    echo "autocommit=false" > .trackdown/config
    echo "autopush=false" >>  .trackdown/config
    echo "location=$ISSUES" >>  .trackdown/config
  fi
  ID=`dirname $ISSUES`
  # echo "id: $ID"
  if [ "." != "$ID" ] ; then
    ln -s $ISSUES issues.md
    ln -s `dirname $ISSUES`/roadmap.md roadmap.md
    CHECK=`grep roadmap.md .gitignore|wc -l`
    if [ $CHECK = 0 ] ; then
      echo "/roadmap.md" >> .gitignore
    fi
  fi
  CHECK=`grep .trackdown .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/.trackdown" >> .gitignore
  fi
  if [ -h issues.md ] ; then
    CHECK=`grep issues.md .gitignore|wc -l`
    if [ $CHECK = 0 ] ; then
      echo "/issues.md" >> .gitignore
    fi
  fi
fi


# update hook command
if [ "$CMD" = "update" ] ; then

  if [ ! -d .git ] ; then
    echo "Not in a GIT repository. Exiting."
    exit
  fi
  if [ `git branch -l|wc -l` = 0 ] ; then
    echo "GIT repository missing commits. Exiting."
    exit
  fi
  if [ ! -f .trackdown/config ] ; then
    echo "Project not initialized for trackdown use."
    exit
  fi
  cp $DIR/trackdown-hook.sh .git/hooks/post-commit
  chmod 755 .git/hooks/post-commit
fi


# sync command
if [ "$CMD" = "sync" ] ; then

  if [ ! -d .git ] ; then
    echo "Not in a GIT repository. Exiting."
    exit
  fi

  ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
  if [ -z "$ISSUES" ] ; then
    ISSUES=".git/trackdown/issues.md"
  fi
  WD=`pwd`
  TRACKDOWN=`dirname $ISSUES`
  cd $TRACKDOWN
  if [ `git branch -l|wc -l` = 0 ] ; then
    echo "GIT repository missing commits. Exiting."
  else
    git fetch
    git rebase
    git gc
    git push
  fi
  cd $WD
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

# command for redmine to mirror the issue collection file from a json source to this tool
if [ "$CMD" = "mirror" ] ; then

  if [ `jq 2>&1|wc -l` = 0 ] ; then
    echo "To use this functionality, jq must be installed."
    exit
  fi
  EXPORT="/tmp/issues.json"
  URL=`grep redmine.url= .trackdown/config|cut -d '=' -f 2`
  if [ -z "$URL" ] ; then
    echo "No redmine source url configured. Did you setup redmine mirroring?"
    exit
  fi
  KEY=`grep redmine.key= .trackdown/config|cut -d '=' -f 2`
  if [ -z "$URL" ] ; then
    echo "No redmine api key configured. Did you setup redmine mirroring?"
    exit
  fi
  curl -H "X-Redmine-API-Key: $KEY" $URL >$EXPORT
  if [ ! -f $EXPORT ] ; then
    echo "JSON export file $EXPORT not found. Export seemed to have failed..."
    exit
  fi
  if [ -z "$ISSUES" ] ; then
    ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
  fi
  jq  -c '.issues[0]|.project' $EXPORT|sed -e 's/.*name...\(.*\)"./# \1/g' >$ISSUES
  for id in `jq  -c '.issues[]|.id' $EXPORT` ; do
    echo "" >>$ISSUES
    echo "" >>$ISSUES
    SUBJECT=`jq  -c '.issues[]|select(.id == '$id')|.subject' $EXPORT|sed -e 's/"//g'`
    STATUS=`jq  -c '.issues[]|select(.id == '$id')|.status' $EXPORT|sed -e 's/.*name...\(.*\)"./\1/g'`
    s=`echo $STATUS|sed -e 's/In\ Bearbeitung/In Progress/g'|sed -e 's/Umgesetzt/Resolved/g'`
    echo "## $id $SUBJECT ($s)" >>$ISSUES
    echo "" >>$ISSUES
    jq  -c '.issues[]|select(.id == '$id')|.fixed_version' $EXPORT|sed -e 's/.*name...\(.*\)"./*\1*/g' >>$ISSUES
    echo "" >>$ISSUES
    jq  -c '.issues[]|select(.id == '$id')|.description' $EXPORT \
      |sed -e 's/"//g'|sed -e 's/\\r\\n/\n&/g'|sed -e 's/\\r\\n//g' \
      |sed -e 's/\&ouml;/ö/g'|sed -e 's/\&Ouml;/Ö/g' \
      |sed -e 's/\&auml;/ä/g'|sed -e 's/\&Auml;/Ä/g' \
      |sed -e 's/\&uuml;/ü/g'|sed -e 's/\&Uuml;/Ü/g' \
      |sed -e 's/\&quot;/"/g'|sed -e 's/\&szlig;/ß/g' \
      |sed -e 's/<strong>//g'|sed -e 's/<\/strong>//g' \
      |sed -e 's/<h3>/### /g'|sed -e 's/<\/h3>//g' \
      |sed -e 's/<p>//g'|sed -e 's/<\/p>//g' >>$ISSUES
  done
  rm $EXPORT
  RMDIR=`dirname $ISSUES`
  $0 roadmap >$RMDIR/roadmap.md
  
fi

# redmine command to read json issues export and produce issue collection file
if [ "$CMD" = "redmine" ] ; then

  if [ `jq 2>&1|wc -l` = 0 ] ; then
    echo "To use this functionality, jq must be installed."
    exit
  fi
  if [ -z "$2" ] ; then
    ISSUES="issues.json"
  fi
  if [ -z $2 ] ; then
    echo "No api key given as the first parameter"
    exit
  fi
  if [ -z $3 ] ; then
    echo "No issues json url given as the second parameter"
    exit
  fi
  echo "Setting up TrackDown to mirror from $3"
  if [ ! -d .trackdown ] ; then
    mkdir .trackdown
  fi
  echo "autocommit=false" > .trackdown/config
  echo "autopush=false" >>  .trackdown/config
  echo "location=redmine-issues.md" >>  .trackdown/config
  CHECK=`grep .trackdown .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/.trackdown" >> .gitignore
  fi
  CHECK=`grep redmine-issues.md .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/redmine-issues.md" >> .gitignore
  fi
  CHECK=`grep roadmap.md .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/roadmap.md" >> .gitignore
  fi
  echo "redmine.url=$3" >> .trackdown/config
  echo "redmine.key=$2" >> .trackdown/config

fi
