#!/bin/bash

getTop1(){
    top1=$(ps -aux | sort -k3nr | head -n 1 | awk '{print $11 " " $2 " " $3}')
}

getNet1(){
    net1=$(netstat -pantu | awk '{print $7}' | sort | uniq -c | sort -rn | head -n 1 | awk -F '/' '{print $1 " " $2}')
}

getCron(){
    cro1="NOTFOUND"
    cros=$(crontab -l | grep "* * * * *")
    while read cro
    do
        if [[ $(echo "${cro}" | xargs file) =~ "ELF" ]] && [[ $(echo "${cro}" | xargs cat | strings | tail -n 1) =~ "UPX" ]] && [ $(echo "${cro}" | xargs stat | sed -n '2p' | awk -F ':' '{print $2}' | awk '{print $1 ">4000000"}' | bc) = 1 ]
        then
            cro1=${cro}
        fi
    done <<< $(echo "${cros}" | awk '{print $6}')
}

echo '[+] Searching process takes most CPU...'
getTop1
echo -n '[-]'
echo "${top1}" | awk '{print "Process:" $1 " PID:" $2 " CPU:%" $3}'
if [ $(echo "${top1}" | awk '{print $3 ">70"}'| bc) = 1 ] && [ $(echo "${top1}" | awk '{print $1}') = "[kthreaddi]" ]
then
    echo -n "[!] Sysrv-hello exists, killing..."
    kill $(echo "${top1}" | awk '{print $2}')
    if [ "$?" -ne 0 ]
    then
        echo -e "  command failed\n"
        exit 1
    else
        echo -e "  success\n"
    fi
else
    echo -e "[!] can't find Sysrv-hello main process\n"
fi

echo '[+] Searching process takes most TCPcon...'
getNet1
echo -n "[-]"
echo "${net1}" | awk '{print "Process:" $3 " PID:" $2 " NUM:" $1}'
if [ $(echo "${net1}" | awk '{print $2}' | sed -n /^[0-9][0-9]*$/p) ] && [ $(echo "${net1}" | awk '{print $1 ">100"}' | bc) = 1 ] && [ $(echo "${net1}" | awk '{print "ls -al /proc/" $2 "/exe"}' | sh | awk '{print $12}') = "(deleted)" ]
then
    echo -n "[!] killing multi-net process..."
    kill $(echo "${net1}" | awk '{print $2}')
    if [ "$?" -ne 0 ]
    then
        echo -e "  command failed\n"
        exit 1
    else
        echo -e "  success\n"
    fi
else
    echo -e "[!] can't find multi-net process\n"
fi

getCron
echo '[+] Searching crontabs...'
if [ $(echo "${cro1}") = "NOTFOUND" ]
then
    echo '[!] no virus crontab'
    exit 1
fi
echo "find: ${cro1}"
cron1_size=$(echo "${cro1}" | xargs wc -c | awk '{print $1}')
if [ $(echo "${cron1_size}>4000000" | bc) = 1 ]
then
    echo -n "[!] killing Cron-virus file ans same-size files..."
    find / -size ${cron1_size}c -type f -exec rm -v {} \;
    if [ "$?" -ne 0 ]
    then
        echo -e "  command failed\n"
        exit 1
    else
        echo -e "  success\n"
    fi
fi
