#!/bin/bash
#
# Copyright 2016-2019 Martin Goellnitz
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

hg init
cp -r $CWD/README.md .
cp -r $CWD/bin/t*sh .

# test trackdown init
OUTPUT=`$CWD/bin/trackdown.sh init|tail -1`
# echo "$OUTPUT"
assertEquals "Unexpected init output" "$OUTPUT" "Mercurial repository missing commits. Exiting."

hg add README.md
hg commit -m "First commit" README.md
OUTPUT=`$CWD/bin/trackdown.sh init|tail -1`
assertEquals "Unexpected init output" "$OUTPUT" "1 files updated, 0 files merged, 2 files removed, 0 files unresolved"

OUTPUT=`$CWD/bin/trackdown.sh use|tail -1`
assertEquals "Unexpected use output" "$OUTPUT" "2 files updated, 0 files merged, 0 files removed, 0 files unresolved"

echo "" >> issues.md
echo "## FIRST issue" >> issues.md
echo "" >> issues.md
echo "*1.0*" >> issues.md
echo "" >> issues.md
echo "## LAST issue" >> issues.md
echo "" >> issues.md
echo "*1.0*" >> issues.md
echo "" >> issues.md

hg add trackdown.sh

echo "COMMIT"
hg commit -m "refs #FIRST" trackdown.sh
# OUTPUT=`hg commit -m "refs #FIRST" trackdown.sh|tail -3|head -1`
# OUTPUT=$(echo $OUTPUT|tail -3|head -1)
assertEquals "Unexpected commit hook output" "$OUTPUT" "adding file changes"

OUTPUT=`grep "## FIRST" issues.md`
assertEquals "Unexpected issue collection content" "$OUTPUT" "## FIRST issue (in progress)"

OUTPUT=`cat issues.md|wc -l`
assertEquals "Unexpected issue collection size" "$OUTPUT" "14"

# cleanup test
after
