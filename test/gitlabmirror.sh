#!/bin/bash

# include test "framework"
MYDIR=`dirname $0`
source $MYDIR/shelltest.sh

# setup test
before

mkdir -p .git

# test setup variants
OUTPUT=`$CWD/bin/trackdown.sh gitlab|tail -1`
# echo "$OUTPUT"
assertEquals "Unexpected gitlab setup output" "$OUTPUT" "No api token given as the first parameter"

OUTPUT=`$CWD/bin/trackdown.sh gitlab k|tail -1`
assertEquals "Unexpected gitlab setup output" "$OUTPUT" "No project name given as the second parameter"

OUTPUT=`$CWD/bin/trackdown.sh gitlab k backendzeit/markdown-demo|tail -1`
assertEquals "Unexpected gitlab setup output" "$OUTPUT" "Setting up TrackDown to mirror from backendzeit/markdown-demo () on https://gitlab.com"

assertExists "Config file missing" .trackdown/config
assertExists "Issue collection file missing" gitlab-issues.md

DIFF=`diff -u $MYDIR/gitlabmirror.config .trackdown/config`
assertEquals "Unexpected gitlab mirror configuration" "$DIFF" ""

# test setup variants
OUTPUT=`$CWD/bin/trackdown.sh gitlab markdown-demo mgoellnitz|tail -1`
assertEquals "Unexpected gitlab setup output" "$OUTPUT" "Mirror setup already done in this repository with type gitlab."

# cleanup test
after
