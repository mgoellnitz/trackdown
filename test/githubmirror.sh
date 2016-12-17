#!/bin/bash
#
# Copyright 2016 Martin Goellnitz
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
