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

git init 2> /dev/null
git config --local user.name "Mr Tester"
git config --local user.email "test@provocon.eu"
cp -r $CWD/README.md .
cp -r $CWD/bin/t*sh .

# test trackdown init
OUTPUT=`$CWD/bin/trackdown.sh init|tail -1`
# echo "$OUTPUT"
assertEquals "Unexpected init output" "$OUTPUT" "GIT repository missing commits. Exiting."

git add README.md
git commit -m "First commit" README.md
OUTPUT=`$CWD/bin/trackdown.sh init|tail -1`
assertEquals "Unexpected init output" "$OUTPUT" " create mode 100644 roadmap.md"

OUTPUT=`$CWD/bin/trackdown.sh use|tail -1`
assertEquals "Unexpected use output" "$OUTPUT" "prepare local"

echo "" >> issues.md
echo "## FIRST issue" >> issues.md
echo "" >> issues.md
echo "*1.0*" >> issues.md
echo "" >> issues.md
echo "## LAST issue" >> issues.md
echo "" >> issues.md
echo "*1.0*" >> issues.md
echo "" >> issues.md

OUTPUT=`cat issues.md|wc -l|sed -e 's/\ //g'`
assertEquals "Unexpected issue collection size" "$OUTPUT" "10"

git add trackdown.sh

OUTPUT=`git commit -m "refs #FIRST" trackdown.sh|tail -3|head -1`
# assertEquals "Unexpected commit hook output" "$OUTPUT" "prepare local"

OUTPUT=`grep "## FIRST" issues.md`
assertEquals "Unexpected issue collection content" "$OUTPUT" "## FIRST issue (in progress)"

OUTPUT=`cat issues.md|wc -l|sed -e 's/\ //g'`
assertEquals "Unexpected issue collection size" "$OUTPUT" "14"

OUTPUT=`$CWD/bin/trackdown.sh copy 1.0|wc -l|sed -e 's/\ //g'`
assertEquals "Unexpected output" "$OUTPUT" "1"
assertExists "Generated milestone file missing" .git/trackdown/1.0.md
assertExists "Generated remainder file missing" .git/trackdown/1.0-issues.md
OUTPUT=`cat .git/trackdown/1.0.md|wc -l|sed -e 's/\ //g'`
assertEquals "Unexpected milestone file size" "$OUTPUT" "14"
OUTPUT=`cat .git/trackdown/1.0-issues.md|wc -l|sed -e 's/\ //g'`
assertEquals "Unexpected remainder file size" "$OUTPUT" "2"

# cleanup test
after
