#!/bin/bash
echo 'Searching process takes most CPU...'

top1=$(ps -aux | sort -k3nr | head -n 1)
top1_much=$(echo ${top1} | awk '{print $3}')
top1_pid=$(echo ${top1} | awk '{print $2}')
top1_name=$(echo ${top1} | awk '{print $11}')
echo "Status: ${top1_name} ${top1_pid} ${top1_much}"

if [ $(echo "${top1_much}>75" | bc) = 1 ] && [ $(echo ${top1_name}) = "[kthreaddi]" ]
then
    echo "Sysrv-hello exists"
else
    echo "can't find Sysrv-hello"
    exit 1
fi

echo -n "killing..."
kill $(echo ${top1_pid})
if [ "$?" -ne 0 ]
then
    echo "command failed"
    exit 1
else
    echo "  success"
fi
