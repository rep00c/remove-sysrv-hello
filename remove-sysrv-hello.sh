#!/bin/bash

getTop1(){
    top1=$(ps -aux | sort -k3nr | head -n 1 | awk '{print $11 " " $2 " " $3}')
}

echo 'Searching process takes most CPU...'

getTop1
echo $top1 | awk '{print "Process:" $1 " PID:" $2 " CPU:%" $3}'
if [ $(echo ${top1} | awk '{print $3">1" }'| bc) = 1 ] && [ $(echo ${top1} | awk '{print $1}') = "[kthreaddi]" ]
then
    echo "Sysrv-hello exists"
else
    echo "can't find Sysrv-hello"
    exit 1
fi

echo -n "killing..."
kill $(echo ${top1} | awk '{print $2}')
if [ "$?" -ne 0 ]
then
    echo "command failed"
    exit 1
else
    echo "  success"
fi
