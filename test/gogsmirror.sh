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
assertExists "VCS ignore file missing" .gitignore

DIFF=`diff -u $MYDIR/gogsmirror.config .trackdown/config`
assertEquals "Unexpected gogs mirror configuration" "$DIFF" ""

DIFF=`diff -u $MYDIR/gogsmirror.ignore .gitignore`
assertEquals "Unexpected gogs ignore file" "$DIFF" ""

OUTPUT=`$CWD/bin/trackdown.sh gogs markdown-demo mgoellnitz|tail -1`
assertEquals "Unexpected gogs setup output" "$OUTPUT" "Mirror setup already done in this repository with type gogs."

# cleanup test
after
