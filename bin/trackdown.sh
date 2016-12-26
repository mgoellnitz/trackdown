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
CWD=`pwd`

# wind up the directory tree until we find a hidden folder of the given name $1
function windUp {
  while [ `pwd` != "/"  -a `ls -d .$1 2>&1|head -1|cut -d ' ' -f 1` != ".$1" ] ; do
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
    ESCAPEDBASE=`echo $TDBASE|sed -e 's/\//\\\xxxxxx\//g'|sed -e 's/\xxxxxx//g'`
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
  CHECK=`grep -s .trackdown $IGNOREFILE|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "${IFBEGIN}.trackdown${IFEND}" >> $IGNOREFILE
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
  CHECK=`grep -s $COLLECTION $IGNOREFILE|wc -l`
  if [ $CHECK = 0 ] ; then
    echo "${IFBEGIN}$COLLECTION${IFEND}" >> $IGNOREFILE
  fi
  CHECK=`grep -s roadmap.md $IGNOREFILE|wc -l`
  if [ $CHECK = 0 ] ; then
   echo "${IFBEGIN}roadmap.md${IFEND}" >> $IGNOREFILE
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
  echo "# $1" >$ISSUES
  echo "" >>$ISSUES
  echo "" >>$ISSUES
  echo "[Roadmap](roadmap)" >>$ISSUES
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
  echo "$MYNAME copy v [collection file]"
  echo "  copy the notes for all issues for version v to a file name v.md"
  echo ""
  echo "$MYNAME mine [me] [collection file]"
  echo "  list issues which are marked to be mine"
  echo ""
  echo "$MYNAME issues [collection file]"
  echo "  list all potential issues"
  echo ""
  echo "$MYNAME use [collection file]"
  echo "  setup clone for issue tracking (optionally with non default file)"
  echo ""
  echo "$MYNAME update"
  echo "  just update repository clone to the latest git commit hook"
  echo ""
  echo "$MYNAME init"
  echo "  init issue tracking within GIT or Mercurial branch"
  echo ""
  echo "$MYNAME mirror"
  echo "  sync with reviously setup tracking master (gitlab, redmine, github, gogs, gitea, pikacode - needs jq)"
  echo ""
  echo "$MYNAME remote c i p"
  echo "  issue remote command c on issue i with parameter p on remote mirroring source system"
  echo ""
  echo "$MYNAME github k p o"
  echo "  setup github mirroring project p of owner o with given apikey k (needs jq)"
  echo ""
  echo "$MYNAME gitlab k p [u]"
  echo "  setup gitlab mirroring project p with given apikey k and gitlab base url u (needs jq) - u defaults to gitlab.com"
  echo ""
  echo "$MYNAME bitbucket p u"
  echo "  setup bitbucket mirroring project p with for user u (needs jq)"
  echo ""
  echo "$MYNAME gogs k p [u]"
  echo "  setup gogs, gitea or pikacode mirroring project p with given apikey k and gitlab base url u (needs jq) - u defaults to pikacode"
  echo ""
  echo "$MYNAME redmine k p u"
  echo "  setup redmine mirroring project p with given apikey k and redmine base url u (needs jq)"
  echo ""
  echo "$MYNAME status"
  echo "  Show brief information about the GIT or Mercurial state of the issue collection Branch or Directory"
  echo ""
  echo "$MYNAME sync"
  echo "  Synchronize the remote repository with the TrackDown issues and roadmap for Mercurial and GIT"
  exit

fi


windUp trackdown
TDBASE=`pwd`
# At least try to find a reference base directory from DVCS
if [ ! -f .trackdown/config ] ; then
  cd $CWD
  windUp hg
  if [ ! -d .hg ] ; then
    cd $CWD
    windUp git
  fi
fi
TDBASE=`pwd`
cd $CWD
TDCONFIG=$TDBASE/.trackdown/config
if [ "$CMD" != "roadmap" ] ; then 
  echo "TrackDown base directory $TDBASE"
fi

# ls command to list potential issues in the collection for a certain release
if [ "$CMD" = "ls" ] ; then

  # Location of the issues file
  ISSUES=$3
  discoverIssues
  grep -B2 "^\*$2\*" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /* /g'

fi


# command to list my issues in the collection
if [ "$CMD" = "mine" ] ; then

  discoverIssues
  if [ -z "$ME" ] ; then
    ME=`grep me= $TDCONFIG|cut -d '=' -f 2`
  fi
  if [ -z "$ME" ] ; then
    ME="$USER"
  fi
  grep -B2 "Currently.assigned.to...$ME" $ISSUES|grep "^\#\#\ "|sed -e 's/^\#\#\ /* /g'

fi


# ls command to list potential issues in the collection for a certain release
if [ "$CMD" = "roadmap" ] ; then

  # Location of the issues file
  discoverIssues
  echo "# Roadmap"
  echo ""
  IC=`basename $ISSUES .md`
  echo "[Issue Collection]($IC)"
  echo ""
  for rr in `grep -A2 "^\#\#\ " $ISSUES|grep "^\*[A-Za-z0-9][A-Za-z0-9\._\ ]*\*"|cut -d '*' -f 2|sort|uniq|sed -e 's/\ /__/g'` ; do
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

  discoverIssues
  grep "^\#\#\ " $ISSUES | sed -e "s/^##\ /- /g"

fi


# copy all issues for a given milestore to a separate file
if [ "$CMD" = "copy" ] ; then

  # Location of the issues file
  ISSUES=$3
  discoverIssues
  ISSUEDIR=`dirname $ISSUES`
  LINES=`cat $ISSUES|wc -l`
  MILESTONE=$ISSUEDIR/$2
  echo "# Issues resolved in $2" > "$MILESTONE.md"
  echo "" >> "$MILESTONE.md"
  TOTALSIZE=0
  COPY=$ISSUEDIR/$2-issues.md
  cp $ISSUES $COPY
  for START in `grep -n -B2 "^\*$2\*" $ISSUES|grep -e-\#\#\ |cut -d '-' -f 1` ; do 
    REST=$[ $LINES - $START + 1 ]
    SIZE=`tail -$REST $COPY|grep -n ^\#\#\ |head -2|tail -1|cut -d ':' -f 1`
    # tail -$REST $ISSUES|head -1
    # echo "Starting at line $START with $SIZE lines."
    if [ $SIZE = 1 ] ; then
      tail -$REST $COPY >> "$MILESTONE.md"
    else 
      tail -$REST $COPY | head -$[ $SIZE - 1 ] >> "$MILESTONE.md"
    fi
    CSTART=$[ $START - $TOTALSIZE ]
    # tail -$REST $COPY|head -1
    # echo "Starting at line $CSTART with $SIZE lines."
    CUT=`date +%s%N`.md
    head -$[ $CSTART - 1 ] $COPY >$CUT
    tail -$[ $REST - $SIZE + 1 ] $COPY >>$CUT
    mv $CUT $COPY
    TOTALSIZE=$[ $TOTALSIZE + $SIZE - 1 ]
  done

fi


# use command
if [ "$CMD" = "use" ] ; then

  if [ -f $TDCONFIG ] ; then
    echo "Project already initialized for trackdown use."
    exit
  fi
  if [ -d $TDBASE/.git ] ; then
    if [ `(git branch -r;git branch -l)|grep trackdown|wc -l` = 0 ] ; then
      echo "GIT repository doesn't contain a trackdown branch. Did you issue the init command? Exiting."
      exit
    fi
    rm -f $TDBASE/.git/hooks/post-commit
    ln -s $DIR/trackdown-hook.sh $TDBASE/.git/hooks/post-commit
    chmod 755 $TDBASE/.git/hooks/post-commit
    test ! -d $TDBASE/.trackdown && mkdir $TDBASE/.trackdown
    if [ -z "$ISSUES" ] ; then
      ISSUES=".git/trackdown/issues.md"
      NAME=`git config -l|grep user.name|cut -d '=' -f 2`
      MAIL=`git config -l|grep user.email|cut -d '=' -f 2`
      cd $TDBASE
      echo "prepare local"
      test -z `git branch |grep trackdown|sed -e 's/\ /_/g'` && git branch trackdown
      git branch --set-upstream-to=origin/trackdown trackdown
      REMOTE=`git remote get-url origin`
      if [ -z "$REMOTE" ] ; then
        REMOTE=".."
      fi
      cd .git
      # git clone --single-branch --branch trackdown .. trackdown
      # git clone --branch trackdown .. trackdown
      git clone --branch trackdown $REMOTE trackdown
      cd trackdown
      git config --local push.default simple
      git config --local user.email "$MAIL"
      git config --local user.name "$NAME"
      # git remote remove origin
      # git remote add origin $REMOTE
      # git fetch
      # git branch --set-upstream-to=origin/trackdown trackdown
      # git rebase
      cd ../..
      echo "autocommit=true" > $TDCONFIG
      echo "autopush=false" >> $TDCONFIG
    else
      echo "autocommit=false" > $TDCONFIG
      echo "autopush=false" >> $TDCONFIG
    fi

    REMOTE=`git remote get-url origin|cut -d '@' -f 2|sed -e 's/[a-z]+:\/\///g'|sed -e 's/.git$//g'|sed -e 's/:/\//g'`
    CASE=`echo $REMOTE|cut -d '/' -f 1`
    test ! -z "$REMOTE" && echo "Remote system is $REMOTE."
    if [ "$CASE" = "github.com" ] ; then
      echo "Discovered github remote"
      echo "prefix=https://$REMOTE/commit/" >> $TDCONFIG
    fi
    if [ "$CASE" = "v2.pikacode.com" ] ; then
      echo "Discovered pikacode gogs remote"
      echo "prefix=https://$REMOTE/commit/" >> $TDCONFIG
    fi
    if [ "$CASE" = "bitbucket.org" ] ; then
      echo "Discovered bitbucket.org remote"
      echo "prefix=https://$REMOTE/commits/" >> $TDCONFIG
    fi
  fi
  if [ -d $TDBASE/.hg ] ; then
    if [ `hg branches|grep trackdown|wc -l` = 0 ] ; then
      echo "Mercurial repository missing trackdown branch. Did you issue the init command? Exiting."
      exit
    fi
    test ! -d .trackdown && mkdir .trackdown
    if [ -z "$ISSUES" ] ; then
      ISSUES=".hg/trackdown/issues.md"
      cd $TDBASE/.hg
      hg clone --branch trackdown .. trackdown
      test -f hgrc && grep username hgrc >>trackdown/.hg/hgrc
      cd ..
      echo "autocommit=true" > $TDCONFIG
      echo "autopush=true" >> $TDCONFIG
    else
      echo "autocommit=false" > $TDCONFIG
      echo "autopush=false" >> $TDCONFIG
    fi
    echo "[hooks]" >> .hg/hgrc
    echo "commit=$DIR/trackdown-hook.sh" >> .hg/hgrc
    cd $CWD

    REMOTE=`hg paths|grep "default ="|cut -d '=' -f 2|cut -d ' ' -f 2-100|cut -d '@' -f 2|sed -e 's/[a-z]+:\/\///g'`
    CASE=`echo $REMOTE|cut -d '/' -f 1`
    echo "Remote system is $REMOTE."
    if [ "$CASE" = "bitbucket.org" ] ; then
      echo "Discovered bitbucket.org remote"
      echo "prefix=https://$REMOTE/commits/" >> $TDCONFIG
    fi

  fi
  if [ -f $TDCONFIG ] ; then
    echo "location=$ISSUES" >> $TDCONFIG
    ID=`dirname $TDBASE/$ISSUES`
    cd $TDBASE
    ignoreFileHelper
    if [ "$TDBASE" != "$ID" ] ; then
      ln -sf $ISSUES issues.md
      ln -sf `dirname $ISSUES`/roadmap.md roadmap.md
      CHECK=`grep -s roadmap.md $IGNOREFILE|wc -l`
      if [ $CHECK = 0 ] ; then
       echo "${IFBEGIN}roadmap.md${IFEND}" >> $IGNOREFILE
      fi
    fi
    if [ -h issues.md ] ; then
      CHECK=`grep issues.md $IGNOREFILE|wc -l`
      if [ $CHECK = 0 ] ; then
        echo "${IFBEGIN}issues.md${IFEND}" >> $IGNOREFILE
      fi
    fi
    cd $CWD
  else
    echo "Could not use trackdown in this repository due to missing DCVS (git/hg)."
  fi

fi


# update command to use the latest git post commit hook
if [ "$CMD" = "update" ] ; then

  checkTrackdown
  if [ -d $TDBASE/.git ] ; then
    TYPE=`grep mirror.type= $TDCONFIG|cut -d '=' -f 2`
    if [ -z $TYPE ] ; then
      rm -f $TDBASE/.git/hooks/post-commit
      ln -s $DIR/trackdown-hook.sh $TDBASE/.git/hooks/post-commit
      chmod 755 $TDBASE/.git/hooks/post-commit
    else
      echo "This repository is set up as a mirror - no hoook update needed."
    fi
  else
    echo "This is no GIT repository. Exiting."
  fi

fi


#  git remote sync command
if [ "$CMD" = "status" ] ; then

  discoverIssues
  DIR=`dirname $ISSUES`
  if [ -d $DIR/.git ] ; then
    (cd $DIR ; git diff)
  else
    if [ -d $DIR/.hg ] ; then
      (cd $DIR ; hg status)
    else
      (cd $DIR ; ls -l *.md)
    fi
  fi

fi


#  git remote sync command
if [ "$CMD" = "sync" ] ; then

  discoverIssues
  DIR=`dirname $ISSUES`
  if [ -d $DIR/.git ] ; then
    if [ `cd $DIR ; git branch -l|grep ^*|cut -d ' ' -f 2` != "trackdown" ] ; then
      echo "Not working on a special trackdown branch. Exiting."
      exit
    fi
    echo "fetch"
    (cd $DIR ; git fetch)
    echo "stash"
    (cd $DIR ; git stash)
    echo "rebase"
    (cd $DIR ; git rebase)
    echo "apply"
    (cd $DIR ; git stash apply)
    $0 roadmap >$DIR/roadmap.md
    echo "commit"
    (cd $DIR ; git commit -m "Issue collection and roadmap update" $ISSUES roadmap.md)
    echo "push"
    (cd $DIR ; git push)
  fi
  if [ -d $DIR/.hg ] ; then
    if [ `cd $DIR ; hg branch` != "trackdown" ] ; then
      echo "Not working on a special trackdown branch. Exiting."
      exit
    fi
    (cd $DIR ; hg pull)
    (cd $DIR ; hg update trackdown)
    $0 roadmap >$DIR/roadmap.md
    (cd $DIR ; hg commit -m "Issue collection and roadmap update" $ISSUES roadmap.md)
    (cd $DIR ; hg push)
  fi

fi


# init command
if [ "$CMD" = "init" ] ; then

  if [ -d $TDBASE/.git ] ; then
    cd $TDBASE
    if [ `git log|wc -l` = 0 ] ; then
      echo "GIT repository missing commits. Exiting."
      exit
    fi
    if [ `(git branch -r;git branch -l)|sed -e s/^.\ //g|grep trackdown|wc -l` != 0 ] ; then
      echo "TrackDown branch already present. Exiting."
      exit
    fi
    git stash
    BRANCH=`git branch|grep '*'|cut -d ' ' -f 2`
    git checkout --orphan trackdown
    git rm -rf .
    echo "# Issues" > issues.md
    echo "# Roadmap" > roadmap.md
    git add -f issues.md roadmap.md
    git commit -m "Empty issues collection" issues.md roadmap.md
    git checkout issues.md roadmap.md
    git checkout $BRANCH
    git stash apply
    cd $CWD
    exit
  fi
  if [ -d .hg ] ; then
    cd $TDBASE
    if [ `hg log|wc -l` = 0 ] ; then
      echo "Mercurial repository missing commits. Exiting."
      exit
    fi
    if [ `hg branches|grep trackdown|wc -l` != 0 ] ; then
      echo "TrackDown branch already present. Exiting."
      exit
    fi
    BRANCH=`hg branch`
    hg update -r 0
    hg branch trackdown
    hg rm -f .
    echo "# Issues" > issues.md
    echo "# Roadmap" > roadmap.md
    hg add issues.md roadmap.md
    hg commit -m "Empty issues collection"
    hg push --new-branch
    hg update $BRANCH
    cd $CWD
    exit
  fi

  echo "Coud not initialize DVCS based tooling. No DCVS (git/hg) repository found."

fi


# command for redmine to mirror the issue collection file from a json source to this tool
if [ "$CMD" = "mirror" ] ; then
 
  checkTrackdown
  TYPE=`grep mirror.type= $TDCONFIG|cut -d '=' -f 2`
  bailOnZero "No mirror setup done for this repository." $TYPE
  unset ISSUES
  discoverIssues
  checkJq
  EXPORT=${2:-"/tmp/issues.json"}
  if [ $TYPE = "gitlab" ] ; then
    URL=`grep gitlab.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab source url configured. Did you setup gitlab mirroring?" $URL
    TOKEN=`grep gitlab.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab api token configured. Did you setup gitlab mirroring?" $TOKEN
    PROJECT=`grep gitlab.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab project. Did you setup gitlab mirroring?" $PROJECT
    URL="${URL}/api/v3/projects/$PROJECT/issues?per_page=100"
    curl -H "PRIVATE-TOKEN: $TOKEN" $URL >$EXPORT
    checkExport $EXPORT
    issueCollectionHeader  "Issues"
    for id in `jq  -c '.[]|.id' $EXPORT` ; do
      echo "" >>$ISSUES
      echo "" >>$ISSUES
      TITLE=`jq  -c '.[]|select(.id == '$id')|.title' $EXPORT|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
      IID=`jq  -c '.[]|select(.id == '$id')|.iid' $EXPORT|sed -e 's/"//g'`
      STATE=`jq  -c '.[]|select(.id == '$id')|.state' $EXPORT|sed -e 's/"//g'`
      s=`echo $STATE|sed -e 's/opened/in progress/g'|sed -e 's/closed/resolved/g'`
      MILESTONE=`jq  -c '.[]|select(.id == '$id')|.milestone' $EXPORT|sed -e 's/null/No Milestone/g'|sed -e 's/.*title...\([a-zA-Z0-9\ _]*\).*"./\1/g'`
      ASSIGNEE=`jq  -c '.[]|select(.id == '$id')|.assignee' $EXPORT|sed -e 's/.*"name"..\(.*\)","username.*id":\([0-9]*\).*/\1 (\2)/g'`
      echo "## $IID $TITLE ($s)"  >>$ISSUES
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
      echo "" >>$ISSUES
      if [ "$AUTHOR" != "null" ] ; then
        echo -n "Author: \`$AUTHOR\` " >>$ISSUES
      fi
      echo "GitLab ID $id" >>$ISSUES
      DESCRIPTION=`jq  -c '.[]|select(.id == '$id')|.description' $EXPORT`
      if [ "$DESCRIPTION" != "null" ] ; then
        echo "" >>$ISSUES
        echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\r\\n/\n&/g'|sed -e 's/\\r\\n//g' >>$ISSUES
      fi
    done
  fi

  if [ $TYPE = "github" ] ; then
    OWNER=`grep github.owner= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No github repository owner configured. Did you setup github mirroring?" $OWNER
    TOKEN=`grep github.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No github api token configured. Did you setup github mirroring?" $TOKEN
    PROJECT=`grep github.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No github project. Did you setup github mirroring?" $PROJECT
    URL="https://api.github.com/repos/${OWNER}/${PROJECT}/issues?state=all"
    curl -H "Authorization: token $TOKEN" $URL >$EXPORT
    checkExport $EXPORT
    RESULT=`jq '.message?' $EXPORT`
    if [ ! -z "$RESULT" ] ; then
      echo "Cannot mirror issues for github project ${OWNER}/${PROJECT}: ${RESULT}"
      exit
    fi
    issueCollectionHeader  "Issues"
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
      echo "## $IID $TITLE ($s)"  >>$ISSUES
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
      echo "" >>$ISSUES
      if [ "$AUTHOR" != "null" ] ; then
        echo -n "Author: \`$AUTHOR\` " >>$ISSUES
      fi
      echo "GitHub ID $id" >>$ISSUES
      DESCRIPTION=`jq  -c '.[]|select(.id == '$id')|.body' $EXPORT`
      if [ "$DESCRIPTION" != "null" ] ; then
        echo "" >>$ISSUES
        echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\n/\n&/g'|sed -e 's/\\n//g' >>$ISSUES
      fi
    done
  fi

  if [ $TYPE = "redmine" ] ; then
    BASEURL=`grep redmine.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No redmine source url configured. Did you setup redmine mirroring?" $BASEURL
    KEY=`grep redmine.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No redmine api key configured. Did you setup redmine mirroring?" $KEY
    PROJECTS=`grep redmine.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No redmine project. Did you setup redmine mirroring?" $PROJECTS
    rm $ISSUES
    for PROJECT in `echo "$PROJECTS"|sed -e 's/,/\ /g'`; do
      echo "Project: $PROJECT"
      issueCollectionHeader  "$PROJECT"
      COUNT=0
      OFFSET=0
      PAGE=1
      until [ $OFFSET -gt $COUNT ] ; do
        URL="${BASEURL}/projects/$PROJECT/issues.json?page=$PAGE"'&limit=100&f\[\]=status_id&op\[status_id\]=*&set_filter=1'
        curl -H "X-Redmine-API-Key: $KEY" "$URL" >$EXPORT
        checkExport $EXPORT
        PAGE=$[ $PAGE + 1 ]
        COUNT=`jq  -c '.total_count' $EXPORT`
        OFFSET=`jq  -c '.offset' $EXPORT`
        test $OFFSET -lt $COUNT && echo "continue $OFFSET - $COUNT"
        for id in `jq  -c '.issues[]|.id' $EXPORT` ; do
           echo "" >>$ISSUES
          echo "" >>$ISSUES
          SUBJECT=`jq  -c '.issues[]|select(.id == '$id')|.subject' $EXPORT|sed -e 's/"//g'`
          STATUS=`jq  -c '.issues[]|select(.id == '$id')|.status' $EXPORT|sed -e 's/.*name...\(.*\)"./\1/g'`
          s=`echo $STATUS|sed -e 's/In\ Bearbeitung/In Progress/g'|sed -e 's/Umgesetzt/Resolved/g'`
          echo "## $id $SUBJECT ($s)" >>$ISSUES
          echo "" >>$ISSUES
          VERSION=`jq  -c '.issues[]|select(.id == '$id')|.fixed_version' $EXPORT|sed -e 's/null/*No Milestone*/g'|sed -e 's/.*name...\(.*\)"./*\1*/g'`
          ASSIGNEE=`jq  -c '.issues[]|select(.id == '$id')|.assigned_to' $EXPORT|sed -e 's/.*id..\([0-9]*\).*name...\(.*\)"./\2 (\1)/g'`
          PRIORITY=`jq  -c '.issues[]|select(.id == '$id')|.priority' $EXPORT|sed -e 's/.*id..\([0-9]*\).*name...\(.*\)"./\2 (\1)/g'`
          echo -n "${VERSION}"  >>$ISSUES
          if [ "$ASSIGNEE" != "null" ] ; then
            echo -n " - Currently assigned to: \`$ASSIGNEE\`" >>$ISSUES
          fi
          echo "" >>$ISSUES
          echo "" >>$ISSUES
          echo "### Priority: $PRIORITY" >>$ISSUES
          echo "" >>$ISSUES
          echo "### Description" >>$ISSUES
          echo "" >>$ISSUES
          AUTHOR=`jq  -c '.issues[]|select(.id == '$id')|.author' $EXPORT|sed -e 's/.*name...\(.*\)"./\1/g'`
          if [ "$AUTHOR" != "null" ] ; then
            echo "Author: \`$AUTHOR\`" >>$ISSUES
            echo "" >>$ISSUES
          fi
          jq  -c '.issues[]|select(.id == '$id')|.description' $EXPORT \
            |sed -e 's/\\r\\n/\n&/g'|sed -e 's/\\r\\n//g' \
            |sed -e 's/\&ouml;/ö/g'|sed -e 's/\&Ouml;/Ö/g' \
            |sed -e 's/\&auml;/ä/g'|sed -e 's/\&Auml;/Ä/g' \
            |sed -e 's/\&uuml;/ü/g'|sed -e 's/\&Uuml;/Ü/g' \
            |sed -e 's/\&quot;/"/g'|sed -e 's/\&szlig;/ß/g' \
            |sed -e 's/<strong>//g'|sed -e 's/<\/strong>//g' \
            |sed -e 's/<a href=\\"\(.*\)\\">\(.*\)<\/a>/[\2](\1)/g' \
            |sed -e 's/<h3>/\`/g'|sed -e 's/<\/h3>/\`/g' \
            |sed -e 's/<em>/\`/g'|sed -e 's/<\/em>/\`/g' \
            |sed -e 's/<u>/\`/g'|sed -e 's/<\/u>/\`/g' \
            |sed -e 's/<ul>//g'|sed -e 's/<\/ul>//g' \
            |sed -e 's/<ol>//g'|sed -e 's/<\/ol>//g' \
            |sed -e 's/<span>//g'|sed -e 's/<\/span>//g' \
            |sed -e 's/<li>/* /g'|sed -e 's/<\/li>//g' \
            |sed -e 's/<p[\ =a-z0-9\\"]*>//g'|sed -e 's/<\/p>//g' \
            |sed -e 's/^"//g'|sed -e 's/\\t//g' \
            |sed -e 's/<br \/>//g' |sed -e 's/\\"/\`/g' >>$ISSUES
        done
      done
    done
  fi

  if [ $TYPE = "bitbucket" ] ; then
    USER=`grep bitbucket.user= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No bitbucket.org user configured. Did you setup bitbucket.org mirroring?" $USER
    DISPLAY=`echo $USER|cut -d ':' -f 1`
    PROJECT=`grep bitbucket.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No bitbucket.org project configured. Did you setup bitbucket.org mirroring?" $PROJECT
    URL="https://api.bitbucket.org/2.0/repositories/${PROJECT}/issues"
    curl --basic -u $USER $URL >$EXPORT
    checkExport $EXPORT
    RESULT=`jq '.error?|.message?' $EXPORT`
    if [ ! "$RESULT" = "null" ] ; then
      echo "Cannot mirror issues for bitbucket.org project ${PROJECT} as ${DISPLAY}: ${RESULT}"
      cd $CWD
      exit
    fi
    issueCollectionHeader  "Issues"
    for id in `jq  -c '.values[].id' $EXPORT` ; do
      echo "" >>$ISSUES
      echo "" >>$ISSUES
      TITLE=`jq  -c '.values[]|select(.id == '$id')|.title' $EXPORT|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
      STATE=`jq  -c '.values[]|select(.id == '$id')|.state' $EXPORT|sed -e 's/"//g'`
      s=`echo $STATE|sed -e 's/open/in progress/g'|sed -e 's/closed/resolved/g'`
      MILESTONE=`jq  -c '.values[]|select(.id == '$id')|.milestone|.title' $EXPORT|sed -e 's/"//g'|sed -e 's/null/No Milestone/g'`
      ASSIGNEE=`jq  -c '.values[]|select(.id == '$id')|.assignee|.display_name' $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      echo "## $id $TITLE ($s)"  >>$ISSUES
      echo "" >>$ISSUES
      echo -n "*${MILESTONE}*"  >>$ISSUES
      if [ "$ASSIGNEE" != "null" ] ; then
        echo -n " - Currently assigned to: \`$ASSIGNEE\`" >>$ISSUES
      fi
      echo "" >>$ISSUES
      AUTHOR=`jq  -c '.values[]|select(.id == '$id')|.reporter|.display_name' $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      echo "" >>$ISSUES
      if [ "$AUTHOR" != "null" ] ; then
        echo "Author: \`$AUTHOR\` " >>$ISSUES
      fi
      DESCRIPTION=`jq  -c '.values[]|select(.id == '$id')|.content.raw' $EXPORT`
      if [ "$DESCRIPTION" != "null" ] ; then
        echo "" >>$ISSUES
        echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\n/\n&/g'|sed -e 's/\\n//g' >>$ISSUES
      fi
    done
  fi

  if [ $TYPE = "gogs" ] ; then
    URL=`grep gogs.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gogs source url configured. Did you setup gogs mirroring?" $URL
    TOKEN=`grep gogs.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gogs api token configured. Did you setup gogs mirroring?" $TOKEN
    PROJECT=`grep gogs.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gogs/pikacode/gitea project. Did you setup gogs mirroring?" $PROJECT
    URL="${URL}/api/v1/repos/${PROJECT}/issues?state=all"
    curl -H "Authorization: token $TOKEN" $URL >$EXPORT
    checkExport $EXPORT
    RESULT=`jq '.message?' $EXPORT`
    if [ ! -z "$RESULT" ] ; then
      echo "Cannot mirror issues for gogs project ${OWNER}/${PROJECT}: ${RESULT}"
      exit
    fi
    issueCollectionHeader  "Issues"
    for id in `jq  -c '.[]|.id' $EXPORT` ; do
      echo "" >>$ISSUES
      echo "" >>$ISSUES
      TITLE=`jq  -c '.[]|select(.id == '$id')|.title' $EXPORT|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
      IID=`jq  -c '.[]|select(.id == '$id')|.number' $EXPORT|sed -e 's/"//g'`
      STATE=`jq  -c '.[]|select(.id == '$id')|.state' $EXPORT|sed -e 's/"//g'`
      s=`echo $STATE|sed -e 's/open/in progress/g'|sed -e 's/closed/resolved/g'`
      MILESTONE=`jq  -c '.[]|select(.id == '$id')|.milestone|.title' $EXPORT|sed -e 's/"//g'|sed -e 's/null/No Milestone/g'`
      ASSIGNEE=`jq  -c '.[]|select(.id == '$id')|.assignee|.full_name' $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      LABELS=`jq  -c '.[]|select(.id == '$id')|.labels' $EXPORT|sed -e 's/.*"name"..\(.*\)","color.*/[\`\1\`] /g'`
      echo "## $IID $TITLE ($s)"  >>$ISSUES
      echo "" >>$ISSUES
      echo -n "*${MILESTONE}*"  >>$ISSUES
      if [ ! "$LABELS" = "[]" ] ; then
        echo -n " $LABELS" >>$ISSUES
      fi
      if [ "$ASSIGNEE" != "null" ] ; then
        echo -n " - Currently assigned to: \`$ASSIGNEE\`" >>$ISSUES
      fi
      echo "" >>$ISSUES
      AUTHOR=`jq  -c '.[]|select(.id == '$id')|.user|.full_name' $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      echo "" >>$ISSUES
      if [ "$AUTHOR" != "null" ] ; then
        echo -n "Author: \`$AUTHOR\` " >>$ISSUES
      fi
      echo "Remote ID $id" >>$ISSUES
      DESCRIPTION=`jq  -c '.[]|select(.id == '$id')|.body' $EXPORT`
      if [ "$DESCRIPTION" != "null" ] ; then
        echo "" >>$ISSUES
        echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\n/\n&/g'|sed -e 's/\\n//g' >>$ISSUES
      fi
    done
  fi
  rm -f $EXPORT

  RMDIR=`dirname $ISSUES`
  $0 roadmap >$RMDIR/roadmap.md
  
fi


# remote command to issue commands on mirror sources
if [ "$CMD" = "remote" ] ; then

  checkTrackdown
  TYPE=`grep mirror.type= $TDCONFIG|cut -d '=' -f 2`
  bailOnZero "No mirror setup done for this repository." $TYPE
  REMOTE=$2
  bailOnZero "No remote command given as the second parameter" $REMOTE
  # echo "Remote command: $REMOTE"
  ISSUE=$3
  bailOnZero "No target issue to operate on given as the third parameter" $ISSUE
  # echo "Target issue: $ISSUE"
  PARAM=$4
  bailOnZero "No parameter for the remote operation given as the forth parameter" $PARAM
  # echo "Parameter: $PARAM"
  if [ "$TYPE" = "redmine" ] ; then
    URL=`grep redmine.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No redmine source url configured. Did you setup redmine mirroring?" $URL
    KEY=`grep redmine.key= $TDCONFIG|cut -d '=' -f 2`
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
    URL=`grep gitlab.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab source url configured. Did you setup gitlab mirroring?" $URL
    TOKEN=`grep gitlab.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab api token configured. Did you setup gitlab mirroring?" $TOKEN
    PROJECT=`grep gitlab.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab project. Did you setup gitlab mirroring?" $PROJECT
    if [ "$REMOTE" = "assign" ] ; then
      echo "Assigning $ISSUE to user $PARAM"
      curl -X PUT -H "PRIVATE-TOKEN: $TOKEN" \
           ${URL}/api/v3/projects/${PROJECT}/issues/${ISSUE}?assignee_id=${PARAM} > /dev/null
      exit
    fi
  fi
  echo "Unknown remote command \"$REMOTE\" for mirror source of type \"$TYPE\""

fi


# gitlab command to setup a gitlab system as a remote mirror source
if [ "$CMD" = "gitlab" ] ; then

  checkJq
  bailOnZero "No api token given as the first parameter" $2
  bailOnZero "No project name given as the second parameter" $3
  preventRepeatedMirrorInit
  URL=${4:-https://gitlab.com}
  PID=`curl --header "PRIVATE-TOKEN: $2" ${URL}/api/v3/projects|jq '.[]|select(.name=="'$3'")|.id'`
  echo "Setting up TrackDown to mirror from $3 ($PID) on $URL"
  setupCollectionReference gitlab
  echo "gitlab.url=$URL" >> $TDCONFIG
  echo "gitlab.project=$PID" >> $TDCONFIG
  echo "gitlab.key=$2" >> $TDCONFIG

fi


# github command to setup a github system as a remote mirror source
if [ "$CMD" = "github" ] ; then

  checkJq
  bailOnZero "No api token given as the first parameter" $2
  bailOnZero "No project name given as the second parameter" $3
  bailOnZero "No username given as the third parameter" $4
  preventRepeatedMirrorInit
  echo "Setting up TrackDown to mirror $3 owned by $4 from github.com"
  setupCollectionReference github
  echo "prefix=https://github.com/$4/$3/commit/" >> $TDCONFIG
  echo "github.owner=$4" >> $TDCONFIG
  echo "github.project=$3" >> $TDCONFIG
  echo "github.key=$2" >> $TDCONFIG

fi


# bitbucket command to setup bitbucket.org as a remote mirror source
if [ "$CMD" = "bitbucket" ] ; then

  checkJq
  bailOnZero "No project name given as the first parameter" $2
  bailOnZero "No username given as the second parameter" $3
  preventRepeatedMirrorInit
  echo "Setting up TrackDown to mirror $2 as $3 from bitbucket.org"
  setupCollectionReference bitbucket
  echo "prefix=https://bitbucket.org/$3/$2/commits/" >> $TDCONFIG
  echo "bitbucket.user=$3" >> $TDCONFIG
  echo "bitbucket.project=$2" >> $TDCONFIG

fi


# redmine command to setup a redmine system as a remote mirror source
if [ "$CMD" = "redmine" ] ; then

  checkJq
  bailOnZero "No api key given as the first parameter" $2
  bailOnZero "No project name given as the second parameter" $3
  bailOnZero "No redmine instance base url given as the third parameter" $4
  preventRepeatedMirrorInit
  echo "Setting up TrackDown to mirror from $3 on $4"
  setupCollectionReference redmine
  echo "redmine.url=$4" >> $TDCONFIG
  echo "redmine.project=$3" >> $TDCONFIG
  echo "redmine.key=$2" >> $TDCONFIG

fi


# gogs command to setup a gogs, gitea, or pikacode system as a remote mirror source
if [ "$CMD" = "gogs" ] ; then

  checkJq
  bailOnZero "No api token given as the first parameter" $2
  bailOnZero "No project name given as the second parameter" $3
  URL=${4:-https://v2.pikacode.com}
  preventRepeatedMirrorInit
  echo "Setting up TrackDown to mirror from $3 on $URL"
  setupCollectionReference gogs
  echo "prefix=$URL/$3/commit/" >> $TDCONFIG
  echo "gogs.url=$URL" >> $TDCONFIG
  echo "gogs.project=$3" >> $TDCONFIG
  echo "gogs.key=$2" >> $TDCONFIG

fi
