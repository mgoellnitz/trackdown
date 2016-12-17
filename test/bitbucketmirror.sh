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

mkdir -p .hg
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
assertExists "VCS ignore file missing" .hgignore

DIFF=`diff -u $MYDIR/bitbucketmirror.config .trackdown/config`
assertEquals "Unexpected bitbucket mirror configuration" "$DIFF" ""

DIFF=`diff -u $MYDIR/bitbucketmirror.ignore .hgignore`
assertEquals "Unexpected bitbucket ignore file" "$DIFF" ""

OUTPUT=`$CWD/bin/trackdown.sh bitbucket markdown-demo mgoellnitz|tail -1`
assertEquals "Unexpected bitbucket setup output" "$OUTPUT" "Mirror setup already done in this repository with type bitbucket."

# cleanup test
after
