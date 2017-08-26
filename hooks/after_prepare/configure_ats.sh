#!/bin/bash
PLIST=platforms/ios/*/*-Info.plist
 
# Bypass ATS for test servers
cat << EOF |
Add :NSAppTransportSecurity:NSAllowsArbitraryLoads bool true
Add :NSTemporaryExceptionAllowsInsecureHTTPLoads bool true
EOF
while read line
do
/usr/libexec/PlistBuddy -c "$line" $PLIST
done
 
true