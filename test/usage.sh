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
. `dirname $0`/shelltest.sh

# setup test
before

# test number of lines in usage message
USAGE=`$CWD/bin/trackdown.sh|wc -l`
assertEquals "Unexpected usage output" $USAGE 62

# test if every command section in the script has a usage hint
$CWD/bin/trackdown.sh|grep ^trackdown.sh|cut -d ' ' -f 2|sort > usages.txt
grep CMD..= $CWD/bin/trackdown.sh|cut -d '"' -f 4|sort > commands.txt
DIFF=`diff -u usages.txt commands.txt`
assertEquals "Command missing or surplus usage hint" "$DIFF" ""

# cleanup test
after
