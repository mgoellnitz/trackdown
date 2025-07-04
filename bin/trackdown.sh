#!/bin/bash
#
# Copyright 2015-2024 Martin Goellnitz
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
DIR=$(dirname $(readlink -f $0))
CWD=`pwd`

. $DIR/trackdown-lib.sh

# usage command
if [ -z "$CMD" ] ; then

  # see encodeMessage task in build script
  MYNAME=`basename $0`
MSG=$(echo -e H4sIAAAAAAACA6WVTW/aQBCG7/yKuRWklNxzqxKpStVIlZr0gjis7QFvbO+6+wGiv77v7K4JNERV \
lAsGz8c+887s8OTVlm9ms9uHO3JWNYMaaVXbvuc6aGtoo3tez4h+OG3C5JHde0+7i77ftQ+kvY/s \
aWMd7dh5se9yXG3HwxuRt2IKLZOxoQSrvr+Yi4IllQLJqIFptxyanH/Qhmk18Pq/cPtW1y0pxzQo \
13EjOStOCXKq4vdmHoEbgWqCVhNmjoyeL4b95BBHqnsLRqknxVBwqu602dLcjuKOvAfa69BCCPO5 \
4Y2KfUg5FiX92KjAyPeUvpDj0XodrDuU3KhEdOxhBOdWB8g+DHi01nalOKMDMtzj8S+GHK0Nfb1/ \
JDA+sKujkworp0zdTjI7Z52UdDB1hh0d77SNHvA+1XlMOCgf2BG852DpVXUlTG3Es9KhinXHYWnd \
9gqVNKI/7HbrkxerK8A3XLHb0mcyzI2n599FCccDGkA1aRqlmlTI9BIlK9PAiA7kEnUhVQ5DI0ij \
2Ip/Lkl4vY2uZvIHYA/5oMxLHa1wQ+z6pZnF8BI8OvuMtkvqDdm9wSk2H7vVOzakRt3xgbqlyHEs \
B6X9Ur2M29Rv9DA1szlmPNj4CdOqzfLIBC3BBKR4RiSvLxFdwCCRqIRUCnMbXU/x43DHxtJqFa7X \
gri6qdcnyp21/iLuHFOIARgoLDK63BncLXwk7LkaRzTT+7116PPiw9DP2imcGylQPHJ+gTbea2Xo \
m5hfgc79YpL2El+wHeRGBShGGx9whzh7J6XPmI99ZVVGLSbB/NRYvJ/jDLkdi/d2mNX1dJGuJcFJ \
uz8sXLm3aRbjEXh6+x7QKeatWcznQcYQvbSotXssJs0bwED+QaWFqyobQ9qBr7aYhLLcTbHmtXCy \
qfOOk4hGO7zDTi0nYs+Vddc6a/QfTgnK7jjZwKkwMT3K+rvDBpj+SFJ55V92c8aEH+Cc/QUyPzzU \
jwcAAA==)
  echo $MSG|sed -e 's/\ /\n/g'|base64 -d|gunzip -c|sed -e s/CMD/$MYNAME/g
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
if [ "$TDBASE" = "/" ] ; then
  TDBASE=$CWD
fi
VCS=`test -d .hg && echo hg || ( test -d .git && echo git || echo plain )`
TDCONFIG=$TDBASE/.trackdown/config
echo "TrackDown-$VCS: base directory $TDBASE"
cd $CWD
if [ "$VCS" = "git" ] ; then
  if [ $(git remote | grep origin | wc -l) -eq 1 ] ; then
    REMOTE=`git remote get-url origin|cut -d '@' -f 2|sed -e 's/[a-z]+:\/\///g'|sed -e 's/.git$//g'|sed -e 's/:/\//g'`
  fi
fi
if [ "$VCS" = "hg" ] ; then
  if [ $(hg paths | grep defaut | wc -l) -eq 1 ] ; then
    REMOTE=`hg paths default|cut -d '@' -f 2`
  fi
fi
if [ ! -z "$REMOTE" ] ; then
  CASE=`echo $REMOTE|cut -d '/' -f 1`
  REMOTEUSER=`echo $REMOTE|cut -d '/' -f 2`
  REMOTEPROJECT=`echo $REMOTE|cut -d '/' -f 3`
  test ! -z "$REMOTE" && echo "Remote system is $CASE with project \"$REMOTEPROJECT\" and user $REMOTEUSER"
fi

# ls command to list potential issues in the collection for a certain release
if [ "$CMD" = ls ] ; then

  # Location of the issues file
  ISSUES=$3
  discoverIssues
  grep -B2 "^\*$2\*" $ISSUES|grep "^##\s"|sed -e 's/^\#\#\ /* /g'

fi


# command to list my issues in the collection
if [ "$CMD" = mine ] ; then

  discoverIssues
  if [ -z "$ME" ] ; then
    ME=`grep me= $TDCONFIG|cut -d '=' -f 2`
  fi
  if [ -z "$ME" ] ; then
    ME="$USER"
  fi
  grep -B2 "Currently.assigned.to...$ME" $ISSUES|grep "^##\s"|sed -e 's/^\#\#\ /* /g'

fi


# roadmap command to pretty print a roadmap
if [ "$CMD" = roadmap ] ; then

  # Location of the issues file
  discoverIssues
  roadmap

fi


# issues command to list all potential issues in the collection
if [ "$CMD" = issues ] ; then

  discoverIssues
  grep "^##\s" $ISSUES | sed -e "s/^##\ /- /g"

fi


# copy all issues for a given milestore to a separate file
if [ "$CMD" = copy ] ; then

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
    SIZE=`tail -$REST $COPY|grep -n "^##\s"|head -2|tail -1|cut -d ':' -f 1`
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
    if [ $SIZE != 1 ] ; then
      tail -$[ $REST - $SIZE + 1 ] $COPY >>$CUT  
    fi
    mv $CUT $COPY
    TOTALSIZE=$[ $TOTALSIZE + $SIZE - 1 ]
  done

fi


# use command
if [ "$CMD" = use ] ; then

  if [ -f $TDCONFIG ] ; then
    echo "Project already initialized for trackdown use."
    exit
  fi
  if [ -d $TDBASE/.git ] ; then
    rm -f $TDBASE/.git/hooks/post-commit
    ln -s $DIR/trackdown-hook.sh $TDBASE/.git/hooks/post-commit
    rm -f $TDBASE/.git/hooks/trackdown-lib.sh
    ln -s $DIR/trackdown-lib.sh $TDBASE/.git/hooks/
    test ! -d $TDBASE/.trackdown && mkdir $TDBASE/.trackdown
    if [ -z "$ISSUES" ] ; then
      if [ `(git branch -r;git branch -l)|grep trackdown|wc -l` = 0 ] ; then
        echo "GIT repository doesn't contain a trackdown branch. Did you issue the init command? Exiting."
        exit
      fi
      ISSUES=".git/trackdown/issues.md"
      cd $TDBASE
      if [ $(git remote | grep origin | wc -l) -eq 1 ] ; then
        git fetch origin trackdown:trackdown
      fi
      NAME=`git config -l|grep user.name|cut -d '=' -f 2`
      MAIL=`git config -l|grep user.email|cut -d '=' -f 2`
      echo "prepare local"
      test -z `git branch|grep trackdown|sed -e 's/\ /_/g'` && git branch trackdown
      AUTOPUSH=true
      if [ $(git remote | grep origin | wc -l) -eq 1 ] ; then
        git branch --set-upstream-to=origin/trackdown trackdown
      else
        AUTOPUSH=false
      fi
      REMOTE=".."
      cd .git
      git clone --branch trackdown $REMOTE trackdown
      cd trackdown
      rm -f .git/hooks/*.sample
      git config --local push.default simple
      git config --local user.email "$MAIL"
      git config --local user.name "$NAME"
      cd $TDBASE
      echo "autocommit=true" > $TDCONFIG
      echo "autopush=$AUTOPUSH" >> $TDCONFIG
    else
      echo "autocommit=false" > $TDCONFIG
      echo "autopush=false" >> $TDCONFIG
    fi

    if [ $(git remote | grep origin | wc -l) -eq 1 ] ; then
      REMOTE=`git remote get-url origin|cut -d '@' -f 2|sed -e 's/[a-z]+:\/\///g'|sed -e 's/.git$//g'|sed -e 's/:/\//g'`
      CASE=`echo $REMOTE|cut -d '/' -f 1`
      test ! -z "$REMOTE" && echo "Remote system host is $CASE."
      if [ "$CASE" = "gitlab.com" ] ; then
        echo "Discovered gitlab remote"
        echo "prefix=https://$REMOTE/commit/" >> $TDCONFIG
      fi
      if [ "$CASE" = "github.com" ] ; then
        echo "Discovered github remote"
        echo "prefix=https://$REMOTE/commit/" >> $TDCONFIG
      fi
      if [ "$CASE" = "bitbucket.org" ] ; then
        echo "Discovered bitbucket.org remote"
        echo "prefix=https://$REMOTE/commits/" >> $TDCONFIG
      fi
      if [ "$CASE" = "codeberg.org" ] ; then
        echo "Discovered codeberg gitea remote"
        echo "prefix=https://$REMOTE/commit/" >> $TDCONFIG
      fi
    fi
  fi
  if [ -d $TDBASE/.hg ] ; then
    test ! -d .trackdown && mkdir .trackdown
    if [ -z "$ISSUES" ] ; then
      if [ `hg branches|grep trackdown|wc -l` = 0 ] ; then
        echo "Mercurial repository missing trackdown branch. Did you issue the init command? Exiting."
        exit
      fi
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

    if [ $(hg paths | grep defaut | wc -l) -eq 1 ] ; then
      REMOTE=`hg paths default|cut -d '@' -f 2`
      CASE=`echo $REMOTE|cut -d '/' -f 1`
      echo "Remote system is $CASE."
      if [ "$CASE" = "bitbucket.org" ] ; then
        echo "Discovered bitbucket.org remote"
        echo "prefix=https://$REMOTE/commits/" >> $TDCONFIG
      fi
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
if [ "$CMD" = update ] ; then

  checkTrackdown
  if [ -d $TDBASE/.git ] ; then
    TYPE=`grep mirror.type= $TDCONFIG|cut -d '=' -f 2`
    if [ -z $TYPE ] ; then
      rm -f $TDBASE/.git/hooks/post-commit
      rm -f $TDBASE/.git/hooks/trackdown-lib.sh
      ln -s $DIR/trackdown-hook.sh $TDBASE/.git/hooks/post-commit
      ln -s $DIR/trackdown-lib.sh $TDBASE/.git/hooks/
      chmod 755 $TDBASE/.git/hooks/post-commit
    else
      echo "This repository is set up as a mirror - no hoook update needed."
    fi
  else
    echo "This is no GIT repository. Exiting."
  fi

fi


#  issue collection and roadmap status command
if [ "$CMD" = status ] ; then

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


#  remote vcs sync command
if [ "$CMD" = sync ] ; then

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
    roadmap >$DIR/roadmap.md
    echo "commit"
    (cd $DIR ; git commit -m "Issue collection and roadmap update" $ISSUES roadmap.md)
    echo "push"
    (cd $DIR ; git gc ; git push)
  fi
  if [ -d $DIR/.hg ] ; then
    if [ `cd $DIR ; hg branch` != "trackdown" ] ; then
      echo "Not working on a special trackdown branch. Exiting."
      exit
    fi
    (cd $DIR ; hg pull)
    (cd $DIR ; hg update trackdown)
    roadmap >$DIR/roadmap.md
    (cd $DIR ; hg commit -m "Issue collection and roadmap update" $ISSUES roadmap.md)
    (cd $DIR ; hg push)
  fi

fi


# init command
if [ "$CMD" = init ] ; then

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


# command to mirror the issue collection file from a remote system and calculate roadmap accordingly
if [ "$CMD" = mirror ] ; then
 
  checkTrackdown
  TYPE=`grep mirror.type= $TDCONFIG|cut -d '=' -f 2`
  bailOnZero "No mirror setup done for this repository." $TYPE
  unset ISSUES
  discoverIssues
  checkJq
  EXPORT=${2:-"/tmp/issues.json"}
  COMMENTS_EXPORT=${3:-"/tmp/issue-comments.json"}
  ITEM=${4:-"/tmp/issue.json"}
  Q="Did you setup $TYPE mirroring?";
  if [ $TYPE = "gitlab" ] ; then
    URL=`grep gitlab.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab source url configured. $Q" $URL
    TOKEN=`grep gitlab.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab api token configured. $Q" $TOKEN
    TOKEN="PRIVATE-TOKEN: $TOKEN"
    PROJECT=`grep gitlab.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab project. $Q" $PROJECT
    URL="${URL}/api/v4/projects/$PROJECT/issues"
    PAGES=`curl -D - -X HEAD -H "$TOKEN" "$URL?per_page=100" 2> /dev/null|grep X-Total-Pages|sed -e 's/X.Total.Pages..\([0-9]*\).*/\1/g'`
    echo "$PAGES chunks of issues"
    issueCollectionHeader "Issues"
    PAGE="1"
    while [ "$PAGE" -le "$PAGES" ] ; do
      echo "Chunk $PAGE"
      curl -H "$TOKEN" "$URL?per_page=100&page=$PAGE" 2> /dev/null >$EXPORT
      checkExport $EXPORT
      for id in `jq  -c '.[]|.id' $EXPORT` ; do
        echo "" >>$ISSUES
        echo "" >>$ISSUES
        JQ='.[]|select(.id == '$id')|'
        TITLE=`jq  -c "${JQ}.title" $EXPORT|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        IID=`jq  -c "${JQ}.iid" $EXPORT|sed -e 's/"//g'`
        STATE=`jq  -c "${JQ}.state" $EXPORT|sed -e 's/"//g'`
        s=`echo $STATE|sed -e 's/opened/in progress/g'|sed -e 's/closed/resolved/g'`
        MILESTONE=`jq  -c "${JQ}.milestone|.title" $EXPORT|sed -e 's/"//g'|sed -e 's/null/No Milestone/g'`
        ASSIGNEE=`jq  -c "${JQ}.assignee.username" $EXPORT|sed -e 's/"//g'`
        ASSIGNEE_NAME=`jq  -c "${JQ}.assignee.name" $EXPORT|sed -e 's/"//g'`
        echo "## $IID $TITLE ($s)"  >>$ISSUES
        echo "" >>$ISSUES
        echo -n "*${MILESTONE}*"  >>$ISSUES
        LABELS=`jq  -c "${JQ}.labels" $EXPORT|sed -e 's/"/\`/g'|sed -e 's/,/][/g'`
        if [ ! "$LABELS" = "[]" ] ; then
          echo -n " $LABELS" >>$ISSUES
        fi
        if [ "$ASSIGNEE" != "null" ] ; then
          echo -n " - Currently assigned to: \`$ASSIGNEE\` $ASSIGNEE_NAME" >>$ISSUES
        fi
        echo "" >>$ISSUES
        AUTHOR=`jq  -c "${JQ}.author.username" $EXPORT|sed -e 's/"//g'`
        AUTHOR_NAME=`jq  -c "${JQ}.author.name" $EXPORT|sed -e 's/"//g'`
        echo "" >>$ISSUES
        if [ "$AUTHOR" != "null" ] ; then
          echo -n "Author: \`$AUTHOR\` $AUTHOR_NAME " >>$ISSUES
        fi
        echo "" >>$ISSUES
        DESCRIPTION=`jq  -c "${JQ}.description" $EXPORT`
        USERCOMMENTSNO=`jq  -c "${JQ}.user_notes_count" $EXPORT`
        if [ "$DESCRIPTION" != "null" ] ; then
          echo "" >>$ISSUES
          echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\r\\n/\n&/g'|sed -e 's/\\r\\n//g'|sed -e 's/\\n/\n/g' >>$ISSUES
        fi
        COMMENTS_URL=$(echo ${URL}/${IID}/notes)
        curl -H "$TOKEN" "$COMMENTS_URL" 2> /dev/null >$COMMENTS_EXPORT
        COMMENTSNO=$(jq  -c '.|length' $COMMENTS_EXPORT)
        # echo "${USERCOMMENTSNO}/${COMMENTSNO}: $COMMENTS_URL"
        if [ "$COMMENTSNO" != "0" ] ; then
          echo "" >>$ISSUES
          echo "### Comments" >>$ISSUES
          for cid in `jq  -c '.[]|.id' $COMMENTS_EXPORT` ; do
            echo "" >>$ISSUES
            BODY=$(jq  -c '.[]|select(.id == '$cid')|.body' $COMMENTS_EXPORT|sed -e 's/"//g'|sed -e 's/\\t/    /g'|sed -e 's/\\r\\n/\n&/g'|sed -e 's/\\r\\n//g'|sed -e 's/\\n/\n/g')
            COMMENT_DATE=`jq  -c '.[]|select(.id == '$cid')|.updated_at' $COMMENTS_EXPORT|sed -e 's/"//g'`
            COMMENTER=`jq  -c '.[]|select(.id == '$cid')|.author.username' $COMMENTS_EXPORT|sed -e 's/"//g'`
            COMMENTER_NAME=`jq  -c '.[]|select(.id == '$cid')|.author.name' $COMMENTS_EXPORT|sed -e 's/"//g'`
            echo "$COMMENTER_NAME ($COMMENTER) $COMMENT_DATE" >>$ISSUES
            echo "" >>$ISSUES
            echo "$BODY" >>$ISSUES
          done
        fi
      done
      PAGE=$[ $PAGE + 1 ]
    done
  fi

  if [ $TYPE = "github" ] ; then
    OWNER=`grep github.owner= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No github repository owner configured. $Q" $OWNER
    TOKEN=`grep github.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No github api token configured. $Q" $TOKEN
    PROJECT=`grep github.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No github project. $Q" $PROJECT
    URL="https://api.github.com/repos/${OWNER}/${PROJECT}/issues?state=all"
    curl -H "Authorization: token $TOKEN" $URL 2> /dev/null >$EXPORT
    checkExport $EXPORT
    RESULT=`jq '.message?' $EXPORT`
    if [ ! -z "$RESULT" ] ; then
      echo "Cannot mirror issues for github project ${OWNER}/${PROJECT}: ${RESULT}"
      exit
    fi
    issueCollectionHeader "Issues"
    for id in `jq  -c '.[]|.id' $EXPORT` ; do
      echo "" >>$ISSUES
      echo "" >>$ISSUES
      JQ='.[]|select(.id == '$id')|'
      TITLE=`jq  -c "${JQ}.title" $EXPORT|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
      IID=`jq  -c "${JQ}.number" $EXPORT|sed -e 's/"//g'`
      STATE=`jq  -c "${JQ}.state" $EXPORT|sed -e 's/"//g'`
      s=`echo $STATE|sed -e 's/open/in progress/g'|sed -e 's/closed/resolved/g'`
      MILESTONE=`jq  -c "${JQ}.milestone.title" $EXPORT|sed -e 's/"//g'|sed -e 's/null/No Milestone/g'`
      ASSIGNEE=`jq  -c "${JQ}.assignee" $EXPORT|sed -e 's/.*"name"..\(.*\)","username.*id":\([0-9]*\).*/\1 (\2)/g'`
      LABELS=`jq  -c "${JQ}.labels" $EXPORT|sed -e 's/.*"name"..\(.*\)","color.*/[\`\1\`] /g'`
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
      AUTHOR=`jq  -c "${JQ}.user.login" $EXPORT|sed -e 's/"//g'`
      AUTHOR_URL=`jq  -c "${JQ}.user.html_url" $EXPORT|sed -e 's/"//g'`
      if [ "$AUTHOR" != "null" ] ; then
        echo "" >>$ISSUES
        echo "Author: \`$AUTHOR\`" >>$ISSUES
      fi
      DESCRIPTION=`jq  -c "${JQ}.body" $EXPORT`
      if [ "$DESCRIPTION" != "null" ] ; then
        echo "" >>$ISSUES
        echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\n/\n&/g'|sed -e 's/\\n//g'|sed -e 's/\\r//g' >>$ISSUES
      fi
      COMMENTSNO=`jq  -c "${JQ}.comments" $EXPORT`
      if [ "$COMMENTSNO" != "0" ] ; then
        COMMENTS_URL=`jq  -c "${JQ}.comments_url" $EXPORT|sed -e 's/"//g'`
        curl -H "Authorization: token $TOKEN" $COMMENTS_URL 2> /dev/null >$COMMENTS_EXPORT
        echo "" >>$ISSUES
        echo "### Comments" >>$ISSUES
        for cid in `jq  -c '.[]|.id' $COMMENTS_EXPORT` ; do
          echo "" >>$ISSUES
          BODY=$(jq  -c '.[]|select(.id == '$cid')|.body' $COMMENTS_EXPORT|sed -e 's/"//g'|sed -e 's/\\t/    /g'|sed -e 's/\\r\\n/\n&/g'|sed -e 's/\\r\\n//g'|sed -e 's/\\n/\n/g')
          COMMENT_DATE=`jq  -c '.[]|select(.id == '$cid')|.updated_at' $COMMENTS_EXPORT|sed -e 's/"//g'`
          COMMENTER=`jq  -c '.[]|select(.id == '$cid')|.user.login' $COMMENTS_EXPORT|sed -e 's/"//g'`
          echo "$COMMENTER ($COMMENT_DATE)" >>$ISSUES
          echo "" >>$ISSUES
          echo "$BODY" >>$ISSUES
        done
      fi
    done
  fi

  if [ $TYPE = "bitbucket" ] ; then
    USER=`grep bitbucket.user= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No bitbucket.org user configured. $Q" $USER
    DISPLAY=`echo $USER|cut -d ':' -f 1`
    PROJECT=`grep bitbucket.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No bitbucket.org project configured. $Q" $PROJECT
    URL="https://api.bitbucket.org/2.0/repositories/${PROJECT}/issues"
    if [ "$DISPLAY" = "$USER" ] ; then
      echo -n "Password for $DISPLAY on bitbucket.org: "
    fi
    curl --basic -u $USER $URL 2> /dev/null >$EXPORT
    checkExport $EXPORT
    RESULT=`jq '.error?|.message?' $EXPORT`
    if [ ! "$RESULT" = "null" ] ; then
      echo "Cannot mirror issues for bitbucket.org project ${PROJECT} as ${DISPLAY}: ${RESULT}"
      cd $CWD
      exit
    fi
    issueCollectionHeader "Issues"
    for id in `jq  -c '.values[].id' $EXPORT` ; do
      echo "" >>$ISSUES
      echo "" >>$ISSUES
      JQ='.values[]|select(.id == '$id')|'
      TITLE=`jq  -c "${JQ}.title" $EXPORT|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
      STATE=`jq  -c "${JQ}.state" $EXPORT|sed -e 's/"//g'`
      PRIORITY=`jq  -c "${JQ}.priority" $EXPORT|sed -e 's/"//g'`
      TYPE=`jq  -c "${JQ}.type" $EXPORT|sed -e 's/"//g'`
      s=`echo $STATE|sed -e 's/open/in progress/g'|sed -e 's/closed/resolved/g'`
      ASSIGNEE=`jq  -c "${JQ}.assignee|.username" $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      ASSIGNEE_NAME=`jq  -c "${JQ}.assignee|.display_name" $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      echo "## $id $TITLE ($s)"  >>$ISSUES
      echo "" >>$ISSUES
      # Priority used as milestone
      echo -n "*${PRIORITY}* ${TYPE}"  >>$ISSUES
      if [ "$ASSIGNEE" != "null" ] ; then
        echo -n " - Currently assigned to: \`$ASSIGNEE\` $ASSIGNEE_NAME" >>$ISSUES
      fi
      echo "" >>$ISSUES
      AUTHOR=`jq  -c "${JQ}.reporter|.username" $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      AUTHOR_NAME=`jq  -c "${JQ}.reporter|.display_name" $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      echo "" >>$ISSUES
      if [ "$AUTHOR" != "null" ] ; then
        echo "Author: \`$AUTHOR\` $AUTHOR_NAME" >>$ISSUES
      fi
      DESCRIPTION=`jq  -c "${JQ}.content.raw" $EXPORT`
      if [ "$DESCRIPTION" != "null" ] ; then
        echo "" >>$ISSUES
        echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\n/\n&/g'|sed -e 's/\\n//g'|sed -e 's/\\r//g' >>$ISSUES
      fi
      COMMENTS_URL=`jq  -c "${JQ}.links.comments.href" $EXPORT|sed -e 's/"//g'`
      if [ "$DISPLAY" = "$USER" ] ; then
        echo -n "Password for $DISPLAY on bitbucket.org: "
      fi
      curl --basic -u $USER $COMMENTS_URL 2> /dev/null >$COMMENTS_EXPORT
      COMMENTSNO=$(jq  -c '.values|length' $COMMENTS_EXPORT)
      if [ "$COMMENTSNO" != "0" ] ; then
        echo "" >>$ISSUES
        echo "### Comments" >>$ISSUES
        for cid in `jq  -c '.values[]|.id' $COMMENTS_EXPORT` ; do
          BODY=$(jq  -c '.values[]|select(.id == '$cid')|.content.raw' $COMMENTS_EXPORT|sed -e 's/"//g'|sed -e 's/\\t/    /g'|sed -e 's/\\r\\n/\n&/g'|sed -e 's/\\r\\n//g'|sed -e 's/\\n/\n/g')
          if [ "$BODY" != "null" ] ; then
            COMMENT_DATE=`jq  -c '.values[]|select(.id == '$cid')|.created_on' $COMMENTS_EXPORT|sed -e 's/"//g'`
            COMMENTER=`jq  -c '.values[]|select(.id == '$cid')|.user.username' $COMMENTS_EXPORT|sed -e 's/"//g'`
            COMMENTER_NAME=`jq  -c '.values[]|select(.id == '$cid')|.user.display_name' $COMMENTS_EXPORT|sed -e 's/"//g'`
            echo "" >>$ISSUES
            echo "$COMMENTER_NAME ($COMMENTER) $COMMENT_DATE" >>$ISSUES
            echo "" >>$ISSUES
            echo "$BODY" >>$ISSUES
          fi
        done
      fi
    done
  fi

  if [ $TYPE = "jira" ] ; then
    BASEURL=`grep jira.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No jira source url configured. $Q" $BASEURL
    USER=`grep atlassian.user= $TDCONFIG|cut -d '=' -f 2`
    JQL_SUFFIX=`grep ^jql.suffix= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No atlassian user configured. $Q" $USER
    DISPLAY=`echo $USER|cut -d ':' -f 1`
    if [ "$DISPLAY" != "$USER" ] ; then
      COOKIEFILE=$(echo $USER|cut -d ':' -f 2)
    fi
    PROJECT=`grep jira.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No jira project configured. $Q" $PROJECT
    issueCollectionHeader "Issues"
    PAGES="1"
    PAGE="1"
    START="0"
    while [ "$PAGE" -le "$PAGES" ] ; do
      echo "Chunk $PAGE / $PAGES"
      URL="${BASEURL}/rest/api/latest/search?startAt=${START}&maxResults=200&jql=project%3D${PROJECT}${JQL_SUFFIX}"
      # echo "URL: $URL"
      if [ -f "$COOKIEFILE" ] ; then
        curl -b $COOKIEFILE $URL 2> /dev/null >$EXPORT
      else
        curl --basic -u $USER $URL 2> /dev/null >$EXPORT
      fi
      checkExport $EXPORT
      RESULT=`jq '.error?|.message?' $EXPORT`
      if [ ! "$RESULT" = "null" ] ; then
        echo "Cannot mirror issues for jira project ${PROJECT} as ${DISPLAY}: ${RESULT}"
        cd $CWD
        exit
      fi
      if [ -z "$ISSUENUMBER" ] ; then
        ISSUENUMBER=$(jq '.total' $EXPORT)
        PAGES=$[ $ISSUENUMBER / 200 + 1 ]
        echo "$ISSUENUMBER total issues"
      fi
      for id in $(jq  -c '.issues[]|.id' $EXPORT|sed -e 's/"//g') ; do
        echo $id
        echo "" >>$ISSUES
        echo "" >>$ISSUES
        jq '.issues[]|select(.id == "'$id'")|{key: .key, title: .fields.summary, state: .fields.status.statusCategory.key, priority: .fields.priority.name, milestone: .fields.fixVersions[0].name, labels: .fields.labels, author: .fields.creator.displayName, assignee: .fields.assignee.displayName, description: .fields.description, versions: .fields.versions}' $EXPORT > $ITEM
        KEY=`jq  -c ".key" $ITEM|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        TITLE=`jq  -c ".title" $ITEM|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        STATE=`jq  -c ".state" $ITEM|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        s=`echo $STATE|sed -e 's/opened/in progress/g'|sed -e 's/indeterminate/in progress/g'|sed -e 's/closed/resolved/g'|sed -e 's/done/resolved/g'`
        PRIORITY=`jq  -c ".priority" $ITEM|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        MILESTONE=`jq  -c ".milestone" $ITEM|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        VERSIONS=`jq  -c ".versions[]|.name" $ITEM|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        LABELS=`jq  -c ".labels" $ITEM|sed -e 's/"/\`/g'|sed -e 's/,/][/g'`
        AUTHOR=`jq  -c ".author" $ITEM|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        ASSIGNEE=`jq  -c ".assignee" $ITEM|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        DESCRIPTION=`jq  -c ".description" $ITEM|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
        COMMENTS=""

        echo "## $KEY $TITLE ($s)"  >>$ISSUES
        echo "" >>$ISSUES
        LINEBREAK=
        if [ "$MILESTONE" != "" ] ; then
          echo -n "*${MILESTONE}*"  >>$ISSUES
          LINEBREAK="true"
        fi
        if [ ! "$LABELS" = "[]" ] ; then
          echo -n " $LABELS" >>$ISSUES
          LINEBREAK="true"
        fi
        if [ "$ASSIGNEE" != "null" ] ; then
          if [ ! -z $LINEBREAK ] ; then
            echo -n " - " >>$ISSUES
          fi
          echo -n "Currently assigned to: \`$ASSIGNEE\`" >>$ISSUES
          LINEBREAK="true"
        fi
        if [ ! -z $LINEBREAK ] ; then
          echo "" >>$ISSUES
        fi
        if [ "$AUTHOR" != "" ] ; then
          echo "" >>$ISSUES
          echo "Author: \`$AUTHOR\`" >>$ISSUES
        fi
        ## severity / priority
        echo "" >>$ISSUES
        echo "### Priority: $PRIORITY" >>$ISSUES
        if [ "$VERSIONS" != "" ] ; then
          echo "" >>$ISSUES
          echo "affected versions: $VERSIONS" >>$ISSUES
        fi
        if [ "$DESCRIPTION" != "" ] ; then
          echo "" >>$ISSUES
          echo "### Description" >>$ISSUES
          echo "" >>$ISSUES
          echo "$DESCRIPTION"|sed -e 's/\\r//g'|sed -e 's/\\n/\n/g' >>$ISSUES
        fi
        ## comments
        if [ "$COMMENTS" != "" ] ; then
          echo "" >>$ISSUES
          echo "### Comments" >>$ISSUES
          echo "" >>$ISSUES
          echo "$COMMENTS" >>$ISSUES
        fi

        # jq  '.issues[]|select(.id == "'$id'")' $EXPORT
      done
      PAGE=$[ $PAGE + 1 ]
      START=$[ $START + 200 ]
    done
  fi

  if [ $TYPE = "redmine" ] ; then
    BASEURL=`grep redmine.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No redmine source url configured. $Q" $BASEURL
    KEY=`grep redmine.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No redmine api key configured. $Q" $KEY
    PROJECTS=`grep redmine.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No redmine project. $Q" $PROJECTS
    rm $ISSUES
    for PROJECT in `echo "$PROJECTS"|sed -e 's/,/\ /g'`; do
      echo "Project: $PROJECT"
      issueCollectionHeader "$PROJECT" "append"
      COUNT=0
      OFFSET=0
      PAGE=1
      until [ $OFFSET -gt $COUNT ] ; do
        URL="${BASEURL}/projects/$PROJECT/issues.json?page=$PAGE"'&limit=100&f\[\]=status_id&op\[status_id\]=*&set_filter=1'
        curl -H "X-Redmine-API-Key: $KEY" "$URL" 2> /dev/null >$EXPORT
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
          s=`echo $STATUS|sed -e 's/In\ Bearbeitung/In Progress/g'|sed -e 's/Umgesetzt/Resolved/g'|sed -e 's/Erledigt/Resolved/g'`
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

  if [ $TYPE = "gitea" ] ; then
    URL=`grep gitea.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitea source url configured. $Q" $URL
    TOKEN=`grep gitea.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitea api token configured. $Q" $TOKEN
    PROJECT=`grep gitea.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitea (or gogs) project. $Q" $PROJECT
    URL="${URL}/api/v1/repos/${PROJECT}/issues"
    curl -H "Authorization: token $TOKEN" "${URL}?state=all" 2> /dev/null >$EXPORT
    checkExport $EXPORT
    RESULT=`jq '.message?' $EXPORT`
    if [ ! -z "$RESULT" ] ; then
      echo "Cannot mirror issues for gitea (or gogs) project ${OWNER}/${PROJECT}: ${RESULT}"
      exit
    fi
    issueCollectionHeader "Issues"
    for id in `jq  -c '.[]|.id' $EXPORT` ; do
      echo "" >>$ISSUES
      echo "" >>$ISSUES
      JQ='.[]|select(.id == '$id')|'
      TITLE=`jq  -c "${JQ}.title" $EXPORT|sed -e 's/\\\"/\`/g'|sed -e 's/"//g'`
      IID=`jq  -c "${JQ}.number" $EXPORT|sed -e 's/"//g'`
      STATE=`jq  -c "${JQ}.state" $EXPORT|sed -e 's/"//g'`
      s=`echo $STATE|sed -e 's/open/in progress/g'|sed -e 's/closed/resolved/g'`
      MILESTONE=`jq  -c "${JQ}.milestone|.title" $EXPORT|sed -e 's/"//g'|sed -e 's/null/No Milestone/g'`
      ASSIGNEE=`jq  -c "${JQ}.assignee|.login" $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      ASSIGNEE_NAME=`jq  -c "${JQ}.assignee|.full_name" $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      LABELS=`jq  -c "${JQ}.labels" $EXPORT|sed -e 's/.*"name"..\(.*\)","color.*/[\`\1\`] /g'`
      echo "## $IID $TITLE ($s)"  >>$ISSUES
      echo "" >>$ISSUES
      echo -n "*${MILESTONE}*"  >>$ISSUES
      if [ ! "$LABELS" = "[]" ] ; then
        echo -n " $LABELS" >>$ISSUES
      fi
      if [ "$ASSIGNEE" != "null" ] ; then
        echo -n " - Currently assigned to: \`$ASSIGNEE\` $ASSIGNEE_NAME" >>$ISSUES
      fi
      echo "" >>$ISSUES
      AUTHOR=`jq  -c "${JQ}.user|.login" $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      AUTHOR_NAME=`jq  -c "${JQ}.user|.full_name" $EXPORT|sed -e s/^\"//g|sed -e s/\"$//g`
      echo "" >>$ISSUES
      if [ "$AUTHOR" != "null" ] ; then
        echo -n "Author: \`$AUTHOR\` $AUTHOR_NAME  " >>$ISSUES
      fi
      echo "Remote ID $id" >>$ISSUES
      DESCRIPTION=`jq  -c "${JQ}.body" $EXPORT`
      if [ "$DESCRIPTION" != "null" ] ; then
        echo "" >>$ISSUES
        echo "$DESCRIPTION" |sed -e 's/\\"/\`/g'|sed -e 's/"//g'|sed -e 's/\\n/\n&/g'|sed -e 's/\\n//g'|sed -e 's/\\r//g' >>$ISSUES
      fi
      COMMENTSNO=`jq  -c "${JQ}.comments" $EXPORT`
      if [ "$COMMENTSNO" != "0" ] ; then
        COMMENTS_URL=$(echo ${URL}/${IID}/comments)
        curl -H "Authorization: token $TOKEN" $COMMENTS_URL 2> /dev/null >$COMMENTS_EXPORT
        echo "" >>$ISSUES
        echo "### Comments" >>$ISSUES
        for cid in `jq  -c '.[]|.id' $COMMENTS_EXPORT` ; do
          echo "" >>$ISSUES
          BODY=$(jq  -c '.[]|select(.id == '$cid')|.body' $COMMENTS_EXPORT|sed -e 's/"//g'|sed -e 's/\\t/    /g'|sed -e 's/\\r\\n/\n&/g'|sed -e 's/\\r\\n//g'|sed -e 's/\\n/\n/g')
          COMMENT_DATE=`jq  -c '.[]|select(.id == '$cid')|.updated_at' $COMMENTS_EXPORT|sed -e 's/"//g'`
          COMMENTER=`jq  -c '.[]|select(.id == '$cid')|.user.login' $COMMENTS_EXPORT|sed -e 's/"//g'`
          COMMENTER_NAME=`jq  -c '.[]|select(.id == '$cid')|.user.full_name' $COMMENTS_EXPORT|sed -e 's/"//g'`
          echo "$COMMENTER_NAME ($COMMENTER) $COMMENT_DATE" >>$ISSUES
          echo "" >>$ISSUES
          echo "$BODY" >>$ISSUES
        done
      fi
    done
  fi
  # rm -f $EXPORT

  writeRoadmap
  
fi


# remote command to issue commands on mirror sources
if [ "$CMD" = remote ] ; then

  checkTrackdown
  TYPE=`grep mirror.type= $TDCONFIG|cut -d '=' -f 2`
  bailOnZero "No mirror setup done for this repository." $TYPE
  REMOTE=$2
  bailOnZero "No remote command given as the second parameter" $REMOTE
  ISSUE=$3
  bailOnZero "No target issue to operate on given as the third parameter" $ISSUE
  PARAM=$4
  bailOnZero "No parameter for the remote operation given as the forth parameter" $PARAM
  # echo "Remote command: $REMOTE Target issue: $ISSUE Parameter: $PARAM"
  Q="Did you setup $TYPE mirroring?";
  if [ "$TYPE" = "gitlab" ] ; then
    URL=`grep gitlab.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab source url configured. $Q" $URL
    URL=$URL/api/v4/
    TOKEN=`grep gitlab.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab api token configured. $Q" $TOKEN
    TOKEN="PRIVATE-TOKEN:  $TOKEN"
    PROJECT=`grep gitlab.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitlab project. $Q" $PROJECT
    if [ "$REMOTE" = "comment" ] ; then
      echo "Adding comment \"$PARAM\" to issue $ISSUE"
      curl -X POST -H "$TOKEN" --data "body=${PARAM}" \
           ${URL}projects/${PROJECT}/issues/${ISSUE}/notes  2> /dev/null > /dev/null
      exit
    fi
    if [ "$REMOTE" = "assign" ] ; then
      USERID=0
      if [ "$PARAM" != "none" ] ; then
        USERID=$(curl -H "$TOKEN" ${URL}users?username=${PARAM} 2> /dev/null|jq .[0].id)
      fi
      ISSUEID=$(curl -H "$TOKEN" ${URL}projects/${PROJECT}/issues?iid=${ISSUE} 2> /dev/null|jq .[0].id)
      if [ "$USERID" != "null" ] ; then
        if [ "$ISSUEID" != "null" ] ; then
          echo "Assigning issue $ISSUE to user $PARAM"
          RESULT=$(curl -X PUT -H "$TOKEN" \
                   ${URL}projects/${PROJECT}/issues/${ISSUE}?assignee_id=${USERID} 2> /dev/null|jq .message)
          if [ "$RESULT" != "null" ] ; then
            echo "Could not assign issue $ISSUE to $PARAM: $RESULT"
          fi
        else
          echo "No issue $ISSUE known."
        fi
      else
        echo "No user $PARAM known."
      fi
      exit
    fi
    if [ "$REMOTE" = "milestone" ] ; then
      echo "Creating milestone $ISSUE ($PARAM)"
      curl -H "$TOKEN" -d "title=${ISSUE}&description=${PARAM}" \
           ${URL}projects/${PROJECT}/milestones 2> /dev/null | jq .
      exit
    fi
    if [ "$REMOTE" = "issue" ] ; then
      echo "Creating issue $ISSUE with label $PARAM"
      curl -H "$TOKEN" -d "title=${ISSUE}&description=${ISSUE}&labels=${PARAM}" \
           "${URL}projects/${PROJECT}/issues?title=${ISSUE}&labels=${PARAM}" 2> /dev/null | jq .
      exit
    fi
  fi
  if [ "$TYPE" = "github" ] ; then
    OWNER=`grep github.owner= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No github owner configured. $Q" $OWNER
    TOKEN=`grep github.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No github api token configured. $Q" $TOKEN
    PROJECT=`grep github.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No github project. $Q" $PROJECT
    URL="https://api.github.com/repos/${OWNER}/${PROJECT}/issues/${ISSUE}"
    if [ "$REMOTE" = "comment" ] ; then
      RESULT=$(curl -X POST -H "Authorization: token $TOKEN" -d "{\"body\":\"${PARAM}\"}"\
           ${URL}/comments 2> /dev/null | jq .message)
      echo "Adding comment \"$PARAM\" to issue $ISSUE: $RESULT"
      exit
    fi
    if [ "$REMOTE" = "assign" ] ; then
      NU=$(curl https://api.github.com/users/$PARAM 2> /dev/null | jq -c .id | sed -e s/\"$//g)
      if [ "$NU" = "null" ] ; then
        echo "Unknown user $PARAM"
      else 
        DATA="{\"assignees\": [ \"${PARAM}\" ]}\""
        # echo $DATA
        RESULT=$(curl -X POST -H "Authorization: token $TOKEN" -d "$DATA"\
             ${URL}/assignees 2> /dev/null | jq .message)
        echo "Assigning issue $ISSUE to user $PARAM: $RESULT"
      fi
      exit
    fi
  fi
  if [ "$TYPE" = "bitbucket" ] ; then
    USER=`grep bitbucket.user= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No bitbucket.org user configured. $Q" $USER
    PROJECT=`grep bitbucket.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No bitbucket.org project configured. $Q" $PROJECT
    URL="https://api.bitbucket.org/2.0/repositories/${PROJECT}/issues/${ISSUE}"
    DISPLAY=`echo $USER|cut -d ':' -f 1`
    if [ "$DISPLAY" = "$USER" ] ; then
      echo -n "Password for $DISPLAY on bitbucket.org: "
    fi
    if [ "$REMOTE" = "comment" ] ; then
      DATA="{\"content\": { \"raw\": \"${PARAM}\" } }"
      RESULT=$(curl -X POST -u $USER -H 'Content-Type: application/json' -d "$DATA" ${URL}/comments/ 2> /dev/null | jq .type)
      echo "Adding comment \"$PARAM\" to issue $ISSUE"
      if [ "$RESULT" = "\"error\"" ] ; then
        echo "Error"
      fi
      exit
    fi
    if [ "$REMOTE" = "assign" ] ; then
      echo "Assigning issue $ISSUE to user $PARAM"
      DATA="{\"assignee\": null }"
      if [ "$PARAM" != "none" ] ; then
        DATA="{\"assignee\": { \"username\": \"${PARAM}\" } }"
      fi
      RESULT=$(curl -X PUT -u $USER -H 'Content-Type: application/json' -d "$DATA" ${URL} 2> /dev/null | jq .type)
      if [ "$RESULT" = "\"error\"" ] ; then
        echo "Error"
      fi
      exit
    fi
  fi
  if [ "$TYPE" = "jira" ] ; then
    USER=`grep atlassian.user= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No atlassian user configured. $Q" $USER
    PROJECT=`grep jira.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No jira project configured. $Q" $PROJECT

    URL="https://api.bitbucket.org/2.0/repositories/${PROJECT}/issues/${ISSUE}"
    if [ "$REMOTE" = "comment" ] ; then
      echo "Adding comment NYI."
      exit
    fi
    if [ "$REMOTE" = "assign" ] ; then
      echo "Assigning issue $ISSUE to user $PARAM. NYI"
      exit
    fi
  fi
  if [ "$TYPE" = "redmine" ] ; then
    URL=`grep redmine.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No redmine source url configured. $Q" $URL
    KEY=`grep redmine.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No redmine api key configured. $Q" $KEY
    if [ "$REMOTE" = "comment" ] ; then
      echo "Adding comment \"$PARAM\" to issue $ISSUE"
      curl -X PUT -H 'Content-Type: application/json' -H "X-Redmine-API-Key: $KEY" \
           -d "{\"issue\":{\"notes\":\"$PARAM\"}}" ${URL}/issues/${ISSUE}.json 2> /dev/null
      exit
    fi
    if [ "$REMOTE" = "assign" ] ; then
      echo "Assigning issue $ISSUE to user $PARAM"
      curl -X PUT -H 'Content-Type: application/json' -H "X-Redmine-API-Key: $KEY" \
           -d "{\"issue\":{\"assigned_to_id\":\"$PARAM\"}}" ${URL}/issues/${ISSUE}.json 2> /dev/null
      exit
    fi
  fi
  if [ "$TYPE" = "gitea" ] ; then
    URL=`grep gitea.url= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitea (or gogs) source url configured. $Q" $URL
    TOKEN=`grep gitea.key= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitea (or gogs) api token configured. $Q" $TOKEN
    PROJECT=`grep gitea.project= $TDCONFIG|cut -d '=' -f 2`
    bailOnZero "No gitea (or gogs) project. $Q" $PROJECT
    if [ "$REMOTE" = "comment" ] ; then
      RESULT=$(curl -X POST -H "Authorization: token $TOKEN" --data "body=${PARAM}" \
           ${URL}/api/v1/repos/${PROJECT}/issues/${ISSUE}/comments 2> /dev/null | jq .id)
      if [ "$RESULT" = "null" ] ; then
        echo "Error"
      else 
        echo "Added comment \"$PARAM\" to issue $ISSUE"
      fi
      exit
    fi
    # Not working right now - cannot find documentation
    if [ "$REMOTE" = "assign" ] ; then
      echo "Assigning issue $ISSUE to user $PARAM"
      curl -X PATCH -H "Authorization: token $TOKEN" -F "assignee=${PARAM}"  \
           ${URL}/api/v1/repos/${PROJECT}/issues/${ISSUE} 2> /dev/null | jq .
      exit
    fi
  fi
  echo "Unknown remote command \"$REMOTE\" for mirror source of type \"$TYPE\""

fi


# gitlab command to setup a gitlab system as a remote mirror source
if [ "$CMD" = gitlab ] ; then

  checkJq
  bailOnZero "No api token given as the first parameter" $2
  if [ -z $REMOTEUSER ] ; then
    P=$3
  else
    P=${3:-$REMOTEUSER/$REMOTEPROJECT}
  fi
  bailOnZero "No project name given as the second parameter" $P
  preventRepeatedMirrorInit
  HOST=${CASE:-gitlab.com}
  URL=${4:-https://$HOST}
  N=$(echo $P|sed -e 's/\(.*\)\/\(.*\)/\2/g')
  PL=$(curl -L -H "PRIVATE-TOKEN: $2" ${URL}'/api/v4/projects?per_page=100&search='$N 2> /dev/null)
  CHECK=`echo $PL|jq '.message'`
  if [ -z "$CHECK" ] ; then
    PID=`echo $PL|jq '.[]|select(.name=="'$P'")|.id'`
    if [ -z "$PID" ] ; then
      PID=`echo $PL|jq '.[]|select(.path_with_namespace=="'$P'")|.id'`
    fi
    if [ -z "$PID" ] ; then
      echo "No project $P on $URL"
      exit
    fi
  else
    echo "Cannot fetch project ID for $P on $URL"
    exit
  fi
  echo "Setting up TrackDown to mirror from $P ($PID) on $URL"
  setupCollectionReference gitlab
  echo "gitlab.url=$URL" >> $TDCONFIG
  echo "gitlab.project=$PID" >> $TDCONFIG
  echo "gitlab.key=$2" >> $TDCONFIG
  ME=$(curl -H "PRIVATE-TOKEN: $2" ${URL}/api/v4/user 2> /dev/null|jq .username|sed -e 's/"//g')
  if [ "$ME" != "null" ] ; then
    echo "me=$ME" >> $TDCONFIG
  fi

fi


# github command to setup a github system as a remote mirror source
if [ "$CMD" = github ] ; then

  checkJq
  TOKEN=${2:-$GITHUB_COM_TOKEN}
  bailOnZero "No api token given as the first parameter" $TOKEN
  P=${3:-$REMOTEPROJECT}
  bailOnZero "No project name given as the second parameter" $P
  U=${4:-$REMOTEUSER}
  bailOnZero "No username given as the third parameter" $U
  preventRepeatedMirrorInit
  echo "Setting up TrackDown to mirror $P owned by $U from github.com"
  setupCollectionReference github
  echo "prefix=https://github.com/$U/$P/commit/" >> $TDCONFIG
  echo "github.owner=$U" >> $TDCONFIG
  echo "github.project=$P" >> $TDCONFIG
  echo "github.key=$TOKEN" >> $TDCONFIG

fi


# bitbucket command to setup bitbucket.org as a remote mirror source
if [ "$CMD" = bitbucket ] ; then

  checkJq
  P=${2:-$REMOTEPROJECT}
  bailOnZero "No project name given as the first parameter" $P
  U=${3:-$REMOTEUSER}
  bailOnZero "No username given as the second parameter" $U
  C=${4:-$BITBUCKET_APP_PASSWORD}
  preventRepeatedMirrorInit
  echo "Setting up TrackDown to mirror $P as $U from bitbucket.org"
  setupCollectionReference bitbucket
  echo "prefix=https://bitbucket.org/$U/$P/commits/" >> $TDCONFIG
  if [ -z "$C" ] ; then
    echo "bitbucket.user=$U" >> $TDCONFIG
  else
    echo "bitbucket.user=$U:$C" >> $TDCONFIG
  fi
  if [ -z $(echo $P|grep /) ] ; then
    P=${U}/$P
  fi
  echo "bitbucket.project=$P" >> $TDCONFIG
  echo "me=$REMOTEUSER" >> $TDCONFIG

fi


# jira command to setup jira as a remote mirror source
if [ "$CMD" = jira ] ; then

  checkJq
  P=$2
  bailOnZero "No project name given as the first parameter" $P
  U=$3
  bailOnZero "No username given as the second parameter" $U
  T=${4:-$ATLASSIAN_TOKEN}
  bailOnZero "No token given as the third parameter" $T
  B=${5:-$ATLASSIAN_URL}
  bailOnZero "No jira base url given as the forth parameter" $B
  preventRepeatedMirrorInit
  echo "Setting up TrackDown to mirror $P as $U from $B"
  setupCollectionReference jira
  echo "atlassian.user=$U:$T" >> $TDCONFIG
  if [ ! -z "$(echo "$T"|grep '\.')" ] ; then
    echo "jira.project=$P" >> $TDCONFIG
  else
    URL="$B/rest/api/latest/project?key=$P"
    # echo "URL: $URL"
    PID=$(curl --basic -u "$U:$T" $URL 2> /dev/null|jq '.[]|.id'|sed -e 's/"//g')
    echo "jira.project=$PID" >> $TDCONFIG
  fi
  echo "jira.url=$B" >> $TDCONFIG
  ## TODO: Which string to take for user recognition
  #echo "me=$U" >> $TDCONFIG

fi


# redmine command to setup a redmine system as a remote mirror source
if [ "$CMD" = redmine ] ; then

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


# gitea command to setup a gitea system like codeberg or a gogs backend as a remote mirror source
if [ "$CMD" = gitea ] ; then

  checkJq
  bailOnZero "No api token given as the first parameter" $2
  if [ -z $REMOTEUSER ] ; then
    P=$3
  else
    P=${3:-$REMOTEUSER/$REMOTEPROJECT}
  fi
  bailOnZero "No project name given as the second parameter" $P
  HOST=${CASE:-codeberg.org}
  URL=${4:-https://$HOST}
  preventRepeatedMirrorInit
  echo "Setting up TrackDown to mirror from $P on $URL"
  setupCollectionReference gitea
  echo "prefix=$URL/$P/commit/" >> $TDCONFIG
  echo "gitea.url=$URL" >> $TDCONFIG
  echo "gitea.project=$P" >> $TDCONFIG
  echo "gitea.key=$2" >> $TDCONFIG
  ME=$(curl -H "Authorization: token $2" ${URL}/api/v1/user 2> /dev/null|jq .login|sed -e 's/"//g')
  if [ ! -z "$ME" ] ; then
    if [ "$ME" != "null" ] ; then
      echo "me=$ME" >> $TDCONFIG
    fi
  fi

fi
