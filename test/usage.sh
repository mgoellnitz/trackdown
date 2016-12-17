#!/bin/bash

# include test "framework"
source `dirname $0`/shelltest.sh

# setup test
before

# test number of lines in usage message
USAGE=`$CWD/bin/trackdown.sh|wc -l`
assertEquals "Unexpected usage output" $USAGE 52

# test if every command section in the script has a usage hint
$CWD/bin/trackdown.sh|grep ^trackdown.sh|cut -d ' ' -f 2|sort > usages.txt
grep CMD..= $CWD/bin/trackdown.sh|cut -d '"' -f 4|sort > commands.txt
DIFF=`diff -u usages.txt commands.txt`
assertEquals "Command missing or surplus usage hint" "$DIFF" ""

# cleanup test
after
