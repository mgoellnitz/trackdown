#!/bin/sh
#
# Copyright 2016-2025 Martin Goellnitz
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
. $MYDIR/shelltest.sh

# setup test
before

# Must be done with Mercurial as the DVCS to avoid trouble with surrounding trackdown git
mkdir -p .hg

# test setup variants
OUTPUT=`$CWD/bin/trackdown.sh gitea|tail -1`
# echo "$OUTPUT"
assertEquals "Unexpected gitea setup output" "$OUTPUT" "No api token given as the first parameter"

OUTPUT=`$CWD/bin/trackdown.sh gitea k|tail -1`
assertEquals "Unexpected gitea setup output" "$OUTPUT" "No project name given as the second parameter"

OUTPUT=`$CWD/bin/trackdown.sh gitea k backendzeit/markdown-demo|tail -1`
assertEquals "Unexpected gitea setup output" "$OUTPUT" "Setting up TrackDown to mirror from backendzeit/markdown-demo on https://codeberg.org"

assertExists "Config file missing" .trackdown/config
assertExists "Issue collection file missing" gitea-issues.md
assertExists "VCS ignore file missing" .hgignore

DIFF=`diff -u $MYDIR/giteamirror.config .trackdown/config`
assertEquals "Unexpected gitea mirror configuration" "$DIFF" ""

DIFF=`diff -u $MYDIR/giteamirror.ignore .hgignore`
assertEquals "Unexpected gitea ignore file" "$DIFF" ""

OUTPUT=`$CWD/bin/trackdown.sh gitea markdown-demo mgoellnitz|tail -1`
assertEquals "Unexpected gitea setup output" "$OUTPUT" "Mirror setup already done in this repository with type gitea."

# cleanup test
after
