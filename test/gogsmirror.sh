#!/bin/bash

# include test "framework"
MYDIR=`dirname $0`
source $MYDIR/shelltest.sh

# setup test
before

mkdir -p .git

# test setup variants
OUTPUT=`$CWD/bin/trackdown.sh gogs|tail -1`
# echo "$OUTPUT"
assertEquals "Unexpected gogs setup output" "$OUTPUT" "No api token given as the first parameter"

OUTPUT=`$CWD/bin/trackdown.sh gogs k|tail -1`
assertEquals "Unexpected gogs setup output" "$OUTPUT" "No project name given as the second parameter"

OUTPUT=`$CWD/bin/trackdown.sh gogs k backendzeit/markdown-demo|tail -1`
assertEquals "Unexpected gogs setup output" "$OUTPUT" "Setting up TrackDown to mirror from backendzeit/markdown-demo on https://v2.pikacode.com"

assertExists "Config file missing" .trackdown/config
assertExists "Issue collection file missing" gogs-issues.md

DIFF=`diff -u $MYDIR/gogsmirror.config .trackdown/config`
assertEquals "Unexpected gogs mirror configuration" "$DIFF" ""

DIFF=`diff -u $MYDIR/gogsmirror.ignore .gitignore`
assertEquals "Unexpected gogs ignore file" "$DIFF" ""

OUTPUT=`$CWD/bin/trackdown.sh gogs markdown-demo mgoellnitz|tail -1`
assertEquals "Unexpected gogs setup output" "$OUTPUT" "Mirror setup already done in this repository with type gogs."

# cleanup test
after
