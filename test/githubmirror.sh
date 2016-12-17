#!/bin/bash

# include test "framework"
MYDIR=`dirname $0`
source $MYDIR/shelltest.sh

# setup test
before

mkdir -p .git

OUTPUT=`$CWD/bin/trackdown.sh mirror|tail -1`
assertEquals "Unexpected uninitialized mirror output" "$OUTPUT" "Project not initialized for trackdown use."

# test setup variants
OUTPUT=`$CWD/bin/trackdown.sh github|tail -1`
# echo "$OUTPUT"
assertEquals "Unexpected github setup output" "$OUTPUT" "No api token given as the first parameter"

OUTPUT=`$CWD/bin/trackdown.sh github k|tail -1`
assertEquals "Unexpected github setup output" "$OUTPUT" "No project name given as the second parameter"

OUTPUT=`$CWD/bin/trackdown.sh github k markdown-demo|tail -1`
assertEquals "Unexpected github setup output" "$OUTPUT" "No username given as the third parameter"

OUTPUT=`$CWD/bin/trackdown.sh github k markdown-demo mgoellnitz|tail -1`
assertEquals "Unexpected github setup output" "$OUTPUT" "Setting up TrackDown to mirror markdown-demo owned by mgoellnitz from github.com"

assertExists "Config file missing" .trackdown/config
assertExists "Issue collection file missing" github-issues.md

DIFF=`diff -u $MYDIR/githubmirror.config .trackdown/config`
assertEquals "Unexpected github mirror configuration" "$DIFF" ""

DIFF=`diff -u $MYDIR/githubmirror.ignore .gitignore`
assertEquals "Unexpected github ignore file" "$DIFF" ""

OUTPUT=`$CWD/bin/trackdown.sh github k markdown-demo mgoellnitz|tail -1`
assertEquals "Unexpected github setup output" "$OUTPUT" "Mirror setup already done in this repository with type github."

# cleanup test
after
