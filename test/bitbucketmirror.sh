#!/bin/bash

# include test "framework"
MYDIR=`dirname $0`
source $MYDIR/shelltest.sh

# setup test
before

mkdir -p .git

# test setup variants
OUTPUT=`$CWD/bin/trackdown.sh bitbucket|tail -1`
# echo "$OUTPUT"
assertEquals "Unexpected bitbucket setup output" "$OUTPUT" "No project name given as the first parameter"

OUTPUT=`$CWD/bin/trackdown.sh bitbucket markdown-demo|tail -1`
assertEquals "Unexpected bitbucket setup output" "$OUTPUT" "No username given as the second parameter"

OUTPUT=`$CWD/bin/trackdown.sh bitbucket markdown-demo backendzeit|tail -1`
assertEquals "Unexpected bitbucket setup output" "$OUTPUT" "Setting up TrackDown to mirror markdown-demo as backendzeit from bitbucket.org"

assertExists "Config file missing" .trackdown/config
assertExists "Issue collection file missing" bitbucket-issues.md

DIFF=`diff -u $MYDIR/bitbucketmirror.config .trackdown/config`
assertEquals "Unexpected bitbucket mirror configuration" "$DIFF" ""

DIFF=`diff -u $MYDIR/bitbucketmirror.ignore .gitignore`
assertEquals "Unexpected bitbucket ignore file" "$DIFF" ""

OUTPUT=`$CWD/bin/trackdown.sh bitbucket markdown-demo mgoellnitz|tail -1`
assertEquals "Unexpected bitbucket setup output" "$OUTPUT" "Mirror setup already done in this repository with type bitbucket."

# cleanup test
after
