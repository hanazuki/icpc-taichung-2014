#!/bin/sh
cd "$(dirname "$0")"
./score.rb > /tmp/icpc-taichung.html && s3cmd -c .s3cfg put -P -rr /tmp/icpc-taichung.html s3://static.rollingapple.net/
