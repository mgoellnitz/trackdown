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

# $0 message to issue when not given $2 parameter to check
function bailOnZero {
  if [ -z "$2" ] ; then
    echo $1
    exit
  fi
}  

# Exit if trackdown is not initialized
function checkTrackdown {
  if [ ! -f .trackdown/config ] ; then
    echo "Project not initialized for trackdown use."
    exit
  fi
}

# Exit if not in a git repository root directory
function checkGit {
  if [ ! -d .git ] ; then
    echo "Not in a GIT repository. Exiting."
    exit
  fi
}


# usage command
if [ -z "$CMD" ] ; then

  MYNAME=`basename $0`
  echo "Usage:"
  echo ""
  echo "$MYNAME roadmap [collection file]"
  echo "  print roadmap"
  echo ""
  echo "$MYNAME ls v [collection file]"
  echo "  list issues for version v"
  echo ""
  echo "$MYNAME mine [me] [collection file]"
  echo "  list issues which are marked to be mine"
  echo ""
  echo "$MYNAME issues [collection file]"
  echo "  list all potential issues"
  echo ""
  echo "$MYNAME use [collection file]"
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
  echo "$MYNAME remote c i p"
  echo "  issue remote command c on issue i with parameter p on remote mirroring source system"
  echo ""
  echo "$MYNAME github k p o"
  echo "  setup github mirroring project p of owner o with given apikey k(needs jq)"
  echo ""
  echo "$MYNAME gitlab k p u"
  echo "  setup gitlab mirroring project p with given apikey k and gitlab base url u (needs jq)"
  echo ""
  echo "$MYNAME redmine k p u"
  echo "  setup redmine mirroring project p with given apikey k and redmine base url u (needs jq)"
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


# command to list my issues in the collection
if [ "$CMD" = "mine" ] ; then

  # Location of the issues file
  if [ -z "$ISSUES" ] ; then
    ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
  fi
  if [ -z "$ISSUES" ] ; then
    ISSUES=".git/trackdown/issues.md"
  fi
  if [ -z "$ME" ] ; then
    ME=`grep me= .trackdown/config|cut -d '=' -f 2`
  fi
  if [ -z "$ME" ] ; then
    ME="$USER"
  fi
  grep -B2 "Currently.assigned.to...$ME" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /* /g'
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
    grep -B2 "^\*$r\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /* /g'|awk '{print $NF,$0}'| sort | cut -f2- -d' '
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

  checkGit
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

  checkTrackdown
  checkGit
  TYPE=`grep mirror.type= .trackdown/config|cut -d '=' -f 2`
  if [ -z $TYPE ] ; then
    cp $DIR/trackdown-hook.sh .git/hooks/post-commit
    chmod 755 .git/hooks/post-commit
  else
    echo "This repository is setup as a mirror - no hoook update needed."
  fi

fi


# sync command
if [ "$CMD" = "sync" ] ; then

  checkGit

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

  checkGit
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
 
  checkTrackdown
  TYPE=`grep mirror.type= .trackdown/config|cut -d '=' -f 2`
  bailOnZero "No mirror setup done for this repository." $TYPE
  if [ `jq 2>&1|wc -l` = 0 ] ; then
    echo "To use this functionality, jq must be installed."
    exit
  fi
  if [ $TYPE = "redmine" ] ; then
    EXPORT="/tmp/issues.json"
    URL=`grep redmine.url= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No redmine source url configured. Did you setup redmine mirroring?" $URL
    KEY=`grep redmine.key= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No redmine api key configured. Did you setup redmine mirroring?" $KEY
    PROJECT=`grep redmine.project= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No redmine project. Did you setup redmine mirroring?" $PROJECT
    URL="${URL}/projects/$PROJECT/issues.json"
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
      VERSION=`jq  -c '.issues[]|select(.id == '$id')|.fixed_version' $EXPORT|sed -e 's/null/No Milestone/g'|sed -e 's/.*name...\(.*\)"./*\1*/g'`
      ASSIGNEE=`jq  -c '.issues[]|select(.id == '$id')|.assigned_to' $EXPORT|sed -e 's/.*id..\([0-9]*\).*name...\(.*\)"./\2 (\1)/g'`
      echo -n "${VERSION}"  >>$ISSUES
      if [ "$ASSIGNEE" != "null" ] ; then
        echo -n " - Currently assigned to: \`$ASSIGNEE\`" >>$ISSUES
      fi
      echo "" >>$ISSUES
      echo "" >>$ISSUES
      echo "### Description" >>$ISSUES
      echo "" >>$ISSUES
      AUTHOR=`jq  -c '.issues[]|select(.id == '$id')|.author' $EXPORT|sed -e 's/.*name...\(.*\)"./\1/g'`
      if [ "$AUTHOR" != "null" ] ; then
        echo "Author: \`$AUTHOR\`" >>$ISSUES
        echo "" >>$ISSUES
      fi
      jq  -c '.issues[]|select(.id == '$id')|.description' $EXPORT \
        |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\r\\n/\n&/g'|sed -e 's/\\r\\n//g' \
        |sed -e 's/\&ouml;/ö/g'|sed -e 's/\&Ouml;/Ö/g' \
        |sed -e 's/\&auml;/ä/g'|sed -e 's/\&Auml;/Ä/g' \
        |sed -e 's/\&uuml;/ü/g'|sed -e 's/\&Uuml;/Ü/g' \
        |sed -e 's/\&quot;/"/g'|sed -e 's/\&szlig;/ß/g' \
        |sed -e 's/<strong>//g'|sed -e 's/<\/strong>//g' \
        |sed -e 's/<h3>/\`/g'|sed -e 's/<\/h3>/\`/g' \
        |sed -e 's/<p>//g'|sed -e 's/<\/p>//g' >>$ISSUES
    done
    rm $EXPORT
  fi

  if [ $TYPE = "gitlab" ] ; then
    EXPORT="/tmp/issues.json"
    URL=`grep gitlab.url= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No gitlab source url configured. Did you setup gitlab mirroring?" $URL
    TOKEN=`grep gitlab.key= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No gitlab api token configured. Did you setup gitlab mirroring?" $TOKEN
    PROJECT=`grep gitlab.project= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No gitlab project. Did you setup gitlab mirroring?" $PROJECT
    URL="${URL}/api/v3/projects/$PROJECT/issues?per_page=100"
    curl -H "PRIVATE-TOKEN: $TOKEN" $URL >$EXPORT
    if [ ! -f $EXPORT ] ; then
      echo "JSON export file $EXPORT not found. Export seemed to have failed..."
      exit
    fi
    if [ -z "$ISSUES" ] ; then
      ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
    fi
    echo "# Issues" >$ISSUES
    for id in `jq  -c '.[]|.id' $EXPORT` ; do
      echo "" >>$ISSUES
      echo "" >>$ISSUES
      TITLE=`jq  -c '.[]|select(.id == '$id')|.title' $EXPORT|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
      IID=`jq  -c '.[]|select(.id == '$id')|.iid' $EXPORT|sed -e 's/"//g'`
      STATE=`jq  -c '.[]|select(.id == '$id')|.state' $EXPORT|sed -e 's/"//g'`
      s=`echo $STATE|sed -e 's/opened/in progress/g'|sed -e 's/closed/resolved/g'`
      MILESTONE=`jq  -c '.[]|select(.id == '$id')|.milestone' $EXPORT|sed -e 's/null/No Milestone/g'|sed -e 's/.*title...\([a-zA-Z0-9\ _]*\).*"./\1/g'`
      ASSIGNEE=`jq  -c '.[]|select(.id == '$id')|.assignee' $EXPORT|sed -e 's/.*"name"..\(.*\)","username.*id":\([0-9]*\).*/\1 (\2)/g'`
      echo "## $IID $TITLE - $id ($s)"  >>$ISSUES
      echo "" >>$ISSUES
      echo -n "*${MILESTONE}*"  >>$ISSUES
      LABELS=`jq  -c '.[]|select(.id == '$id')|.labels' $EXPORT`
      if [ ! "$LABELS" = "[]" ] ; then
        echo -n " $LABELS"|sed -e 's/"/\`/g'|sed -e 's/,/][/g' >>$ISSUES
      fi
      if [ "$ASSIGNEE" != "null" ] ; then
        echo -n " - Currently assigned to: \`$ASSIGNEE\`" >>$ISSUES
      fi
      echo "" >>$ISSUES
      AUTHOR=`jq  -c '.[]|select(.id == '$id')|.author' $EXPORT|sed -e 's/.*name...\(.*\)","username.*/\1/g'`
      if [ "$AUTHOR" != "null" ] ; then
        echo "" >>$ISSUES
        echo "Author: \`$AUTHOR\`" >>$ISSUES
      fi
      DESCRIPTION=`jq  -c '.[]|select(.id == '$id')|.description' $EXPORT`
      if [ "$DESCRIPTION" != "null" ] ; then
        echo "" >>$ISSUES
        echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g' >>$ISSUES
      fi
    done
    rm -f $EXPORT
  fi

  if [ $TYPE = "github" ] ; then
    EXPORT="/tmp/issues.json"
    OWNER=`grep github.owner= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No github repository owner configured. Did you setup github mirroring?" $OWNER
    TOKEN=`grep github.key= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No github api token configured. Did you setup github mirroring?" $TOKEN
    PROJECT=`grep github.project= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No gihub project. Did you setup github mirroring?" $PROJECT
    URL="https://api.github.com/repos/${OWNER}/${PROJECT}/issues?state=all"
    curl -H "PRIVATE-TOKEN: $TOKEN" $URL >$EXPORT
    if [ ! -f $EXPORT ] ; then
      echo "JSON export file $EXPORT not found. Export seemed to have failed..."
      exit
    fi
    if [ -z "$ISSUES" ] ; then
      ISSUES=`grep location= .trackdown/config|cut -d '=' -f 2`
    fi
    echo "# Issues" >$ISSUES
    for id in `jq  -c '.[]|.id' $EXPORT` ; do
      echo "" >>$ISSUES
      echo "" >>$ISSUES
      TITLE=`jq  -c '.[]|select(.id == '$id')|.title' $EXPORT|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
      IID=`jq  -c '.[]|select(.id == '$id')|.number' $EXPORT|sed -e 's/"//g'`
      STATE=`jq  -c '.[]|select(.id == '$id')|.state' $EXPORT|sed -e 's/"//g'`
      s=`echo $STATE|sed -e 's/open/in progress/g'|sed -e 's/closed/resolved/g'`
      MILESTONE=`jq  -c '.[]|select(.id == '$id')|.milestone' $EXPORT|sed -e 's/"//g'|sed -e 's/null/No Milestone/g'`
      ASSIGNEE=`jq  -c '.[]|select(.id == '$id')|.assignee' $EXPORT|sed -e 's/.*"name"..\(.*\)","username.*id":\([0-9]*\).*/\1 (\2)/g'`
      LABELS=`jq  -c '.[]|select(.id == '$id')|.labels' $EXPORT|sed -e 's/.*"name"..\(.*\)","color.*/[\`\1\`] /g'`
      echo "## $IID $TITLE - $id ($s)"  >>$ISSUES
      echo "" >>$ISSUES
      echo -n "*${MILESTONE}*"  >>$ISSUES
      if [ ! "$LABELS" = "[]" ] ; then
        echo -n " $LABELS" >>$ISSUES
      fi
      if [ "$ASSIGNEE" != "null" ] ; then
        echo -n " - Currently assigned to: \`$ASSIGNEE\`" >>$ISSUES
      fi
      echo "" >>$ISSUES
      AUTHOR=`jq  -c '.[]|select(.id == '$id')|.user' $EXPORT|sed -e 's/.*login...\(.*\)","id.*/\1/g'`
      if [ "$AUTHOR" != "null" ] ; then
        echo "" >>$ISSUES
        echo "Author: \`$AUTHOR\`" >>$ISSUES
      fi
      DESCRIPTION=`jq  -c '.[]|select(.id == '$id')|.body' $EXPORT`
      if [ "$DESCRIPTION" != "null" ] ; then
        echo "" >>$ISSUES
        echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\n/\n&/g'|sed -e 's/\\n//g' >>$ISSUES
      fi
    done
    rm -f $EXPORT
  fi

  RMDIR=`dirname $ISSUES`
  $0 roadmap >$RMDIR/roadmap.md
  
fi


# remote command to issue commands on mirror sources
if [ "$CMD" = "remote" ] ; then

  checkTrackdown
  TYPE=`grep mirror.type= .trackdown/config|cut -d '=' -f 2`
  bailOnZero "No mirror setup done for this repository." $TYPE
  REMOTE=$2
  bailOnZero "No remote command given as the second parameter" $REMOTE
  echo "Remote command: $REMOTE"
  ISSUE=$3
  bailOnZero "No target issue to operate on given as the third parameter" $ISSUE
  echo "Target issue: $ISSUE"
  PARAM=$4
  bailOnZero "No parameter for the remote operation given as the forth parameter" $PARAM
  echo "Parameter: $PARAM"
  if [ "$TYPE" = "redmine" ] ; then
    URL=`grep redmine.url= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No redmine source url configured. Did you setup redmine mirroring?" $URL
    KEY=`grep redmine.key= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No redmine api key configured. Did you setup redmine mirroring?" $KEY
    if [ "$REMOTE" = "comment" ] ; then
      echo "Adding comment \"$PARAM\" to $ISSUE"
      curl -X PUT -H 'Content-Type: application/json' -H "X-Redmine-API-Key: $KEY" \
           -d "{\"issue\":{\"notes\":\"$PARAM\"}}" ${URL}/issues/${ISSUE}.json
      exit
    fi
    if [ "$REMOTE" = "assign" ] ; then
      echo "Assigning $ISSUE to user $PARAM"
      curl -X PUT -H 'Content-Type: application/json' -H "X-Redmine-API-Key: $KEY" \
           -d "{\"issue\":{\"assigned_to_id\":\"$PARAM\"}}" ${URL}/issues/${ISSUE}.json
      exit
    fi
  fi
  if [ "$TYPE" = "gitlab" ] ; then
    URL=`grep gitlab.url= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No gitlab source url configured. Did you setup gitlab mirroring?" $URL
    TOKEN=`grep gitlab.key= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No gitlab api token configured. Did you setup gitlab mirroring?" $TOKEN
    PROJECT=`grep gitlab.project= .trackdown/config|cut -d '=' -f 2`
    bailOnZero "No gitlab project. Did you setup gitlab mirroring?" $PROJECT
    if [ "$REMOTE" = "assign" ] ; then
      echo "Assigning $ISSUE to user $PARAM"
      curl -X PUT -H "PRIVATE-TOKEN: $TOKEN" \
           ${URL}/api/v3/projects/${PROJECT}/issues/${ISSUE}?assignee_id=${PARAM} > /dev/null
      exit
    fi
  fi
  echo "Unknown remote command $REMOTE for mirror source of type $MIRROR"

fi


# gitlab command to setup a gitlab system as a remote mirror source
if [ "$CMD" = "gitlab" ] ; then

  if [ `jq 2>&1|wc -l` = 0 ] ; then
    echo "To use this functionality, jq must be installed."
    exit
  fi
  bailOnZero "No api token given as the first parameter" $2
  bailOnZero "No project name given as the second parameter" $3
  bailOnZero "No gitlab instance base url given as the third parameter" $4
  PID=`curl --header "PRIVATE-TOKEN: $2" ${4}/api/v3/projects|jq '.[]|select(.name=="'$3'")|.id'`
  echo "Setting up TrackDown to mirror from $3 ($PID) on $4"
  if [ ! -d .trackdown ] ; then
    mkdir .trackdown
    touch .trackdown/config
  fi
  MIRROR=`grep mirror.type= .trackdown/config|cut -d '=' -f 2`
  if [ ! -z $MIRROR ] ; then
    echo "Mirror setup already done in this repository with type $MIRROR."
    exit
  fi
  echo "autocommit=false" > .trackdown/config
  echo "autopush=false" >>  .trackdown/config
  echo "location=gitlab-issues.md" >>  .trackdown/config
  CHECK=`grep .trackdown .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/.trackdown" >> .gitignore
  fi
  CHECK=`grep redmine-issues.md .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/gitlab-issues.md" >> .gitignore
  fi
  CHECK=`grep roadmap.md .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/roadmap.md" >> .gitignore
  fi
  echo "mirror.type=gitlab" >> .trackdown/config
  echo "gitlab.url=$4" >> .trackdown/config
  echo "gitlab.project=$PID" >> .trackdown/config
  echo "gitlab.key=$2" >> .trackdown/config

fi


# github command to setup a github system as a remote mirror source
if [ "$CMD" = "github" ] ; then

  if [ `jq 2>&1|wc -l` = 0 ] ; then
    echo "To use this functionality, jq must be installed."
    exit
  fi
  bailOnZero "No api token given as the first parameter" $2
  bailOnZero "No project name given as the second parameter" $3
  bailOnZero "No username given as the third parameter" $4
  echo "Setting up TrackDown to mirror $3 owned by $4 from github.com"
  if [ ! -d .trackdown ] ; then
    mkdir .trackdown
    touch .trackdown/config
  fi
  MIRROR=`grep mirror.type= .trackdown/config|cut -d '=' -f 2`
  if [ ! -z $MIRROR ] ; then
    echo "Mirror setup already done in this repository with type $MIRROR."
    exit
  fi
  echo "autocommit=false" > .trackdown/config
  echo "autopush=false" >>  .trackdown/config
  echo "location=github-issues.md" >>  .trackdown/config
  CHECK=`grep .trackdown .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/.trackdown" >> .gitignore
  fi
  CHECK=`grep redmine-issues.md .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/github-issues.md" >> .gitignore
  fi
  CHECK=`grep roadmap.md .gitignore|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "/roadmap.md" >> .gitignore
  fi
  echo "mirror.type=github" >> .trackdown/config
  echo "github.owner=$4" >> .trackdown/config
  echo "github.project=$3" >> .trackdown/config
  echo "github.key=$2" >> .trackdown/config

fi


# redmine command to setup a redmine system as a remote mirror source
if [ "$CMD" = "redmine" ] ; then

  if [ `jq 2>&1|wc -l` = 0 ] ; then
    echo "To use this functionality, jq must be installed."
    exit
  fi
  bailOnZero "No api key given as the first parameter" $2
  bailOnZero "No project name given as the second parameter" $3
  bailOnZero "No redmine instance base url given as the third parameter" $4
  echo "Setting up TrackDown to mirror from $3 on $4"
  if [ ! -d .trackdown ] ; then
    mkdir .trackdown
    touch .trackdown/config
  fi
  MIRROR=`grep mirror.type= .trackdown/config|cut -d '=' -f 2`
  if [ ! -z $MIRROR ] ; then
    echo "Mirror setup already done in this repository with type $MIRROR."
    exit
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
  echo "mirror.type=redmine" >> .trackdown/config
  echo "redmine.url=$4" >> .trackdown/config
  echo "redmine.project=$3" >> .trackdown/config
  echo "redmine.key=$2" >> .trackdown/config

fi
