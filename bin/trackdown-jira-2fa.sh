#!/bin/bash
#
# Copyright 2020-2024 Martin Goellnitz
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
DIR=$(dirname $(readlink $0))
CWD=`pwd`

. $DIR/trackdown-lib.sh

windUp trackdown
TDBASE=`pwd`
if [ ! -f .trackdown/config ] ; then
  echo "TrackDown not configured."
  exit 1
fi
if [ "$TDBASE" = "/" ] ; then
  TDBASE=$CWD
fi
TDCONFIG=$TDBASE/.trackdown/config
echo "TrackDown-plain: base directory $TDBASE"
cd $CWD

TMPFILE=/tmp/trackdown-login-result
URL=`grep jira.url= $TDCONFIG|cut -d '=' -f 2`
USER=`grep atlassian.user= $TDCONFIG|cut -d '=' -f 2|cut -d ':' -f 1`
COOKIEFILE=`grep atlassian.user= $TDCONFIG|cut -d '=' -f 2|cut -d ':' -f 2`
echo -n "Password for $USER @ $URL: "
read -s PASSWORD
echo ""

COOKIE=$(curl -I "$URL/login.jsp?user_role=USER" 2> /dev/null|grep set-cookie:.atlassian.xsrf.token|cut -d ' ' -f 2-20|cut -d ';' -f 1)
# echo $COOKIE
LOGIN=$(curl -c $COOKIEFILE -H "Cookies: $COOKIE"-X POST -d "os_username=$USER&os_password=$PASSWORD" "$URL/rest/gadget/1.0/login" 2> /dev/null|jq .loginSucceeded)
echo "Login Succeeded: $LOGIN"
curl -b $COOKIEFILE -c $COOKIEFILE "$URL/plugins/servlet/login2f?targetUrl=$URL/" 2> /dev/null > $TMPFILE
ATL_TOKEN=$(cat $TMPFILE|grep atl_token..value|sed -e 's/^.*value="\([a-zA-Z0-9]*\)".*$/\1/')
# echo -n "$ATL_TOKEN: "
# cat $TMPFILE|grep atl_token..value
# echo ""
echo -n "OTP: "
read -s OTP
echo ""
# echo "OTP: $OTP"
curl -b $COOKIEFILE -c $COOKIEFILE -L -X POST -D - -d "otp=$OTP&atl_token=$ATL_TOKEN&enterOtp=" "$URL/plugins/servlet/login2f?targetUrl=$URL/" 2> /dev/null > $TMPFILE
