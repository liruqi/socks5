#!/bin/sh
LOG=/var/log/validate_socks5.log

echo "$0" >> $LOG
date >> $LOG
mkdir -p data/s
SPJSON=data/s/sp.net.socks5-t.json
rm data/s/sp.net.socks5-t.json
scrapy runspider socks-proxy-net-spider.py -o $SPJSON 

cp data/socks.output1.txt data/socks.input.txt
if [ -f $SPJSON ]; then
    cp data/s/sp.net.socks5-t.json data/s/sp.net.socks5.json
else 
    echo "use previous output"
fi
cat data/s/sp.net.socks5.json | grep -v 'Socks4' | jq '.[].r' | jq '"\(.[0]):\(.[1])"' | awk -F'"' '{print $2}' >> data/socks.input.txt

cat data/socks.input.txt | sort -n | uniq > data/socks.uin.txt 
target="https://www.bing.com/robots.txt"
rm data/google.r.txt
curl -o data/google.r.txt $target 
target_size=$(wc -c < "data/google.r.txt")
rm data/socks.output1.txt

while read p; do
    echo $p
    dlfile="data/${p}.txt"
    rm $dlfile
    curl --connect-timeout 10 -o $dlfile --socks5 $p $target
    dlsize=$(wc -c < "$dlfile")
    if [ $dlsize -eq $target_size ]; then 
        echo "$p " >> data/socks.output1.txt
    #else 
    #    publicip=$(curl -s --connect-timeout 10 --socks5 $p "https://api.ipify.org")
    #    proxyip=$(echo $p | cut -d ':' -f1)
    #    if [ $publicip -eq $proxyip ]; then
    #        echo "$p" >> data/socks.direct1.txt
    #    fi
    fi 
done < data/socks.uin.txt

cat data/socks.output1.txt | sort -n | uniq > data/socks.output.txt
wc data/socks.output.txt >> $LOG

#scrapy runspider gatherproxy-com-socks5-spider.py -o data/gatherproxy.com.socks5.new.json
#cp data/gatherproxy.com.socks5.new.json data/gatherproxy.com.socks5.json
