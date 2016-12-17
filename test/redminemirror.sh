#!/bin/bash

# include test "framework"
MYDIR=`dirname $0`
source $MYDIR/shelltest.sh

# setup test
before

mkdir -p .git

# test setup variants
OUTPUT=`$CWD/bin/trackdown.sh redmine|tail -1`
# echo "$OUTPUT"
assertEquals "Unexpected redmine setup output" "$OUTPUT" "No api key given as the first parameter"

OUTPUT=`$CWD/bin/trackdown.sh redmine k|tail -1`
assertEquals "Unexpected redmine setup output" "$OUTPUT" "No project name given as the second parameter"

OUTPUT=`$CWD/bin/trackdown.sh redmine k markdown-demo|tail -1`
assertEquals "Unexpected redmine setup output" "$OUTPUT" "No redmine instance base url given as the third parameter"

OUTPUT=`$CWD/bin/trackdown.sh redmine k markdown-demo https://redmine.org|tail -1`
assertEquals "Unexpected redmine setup output" "$OUTPUT" "Setting up TrackDown to mirror from markdown-demo on https://redmine.org"

assertExists "Config file missing" .trackdown/config
assertExists "Issue collection file missing" redmine-issues.md

DIFF=`diff -u $MYDIR/redminemirror.config .trackdown/config`
assertEquals "Unexpected redmine mirror configuration" "$DIFF" ""

DIFF=`diff -u $MYDIR/redminemirror.ignore .gitignore`
assertEquals "Unexpected redmine ignore file" "$DIFF" ""

OUTPUT=`$CWD/bin/trackdown.sh redmine k markdown-demo https://redmine.org|tail -1`
assertEquals "Unexpected redmine setup output" "$OUTPUT" "Mirror setup already done in this repository with type redmine."

# cleanup test
after
