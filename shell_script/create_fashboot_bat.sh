#!/bin/bash
xml_file="$1"
type="$2"
if [ -f "$xml_file" ]
then
	echo "$xml_file" ok
else
	echo "$xml_file" do not exsit
fi

rm filelist.txt
rm "$type".bat

filelists=$(ls)
if [ "$type" == '8917' ]
then
	echo "$filelists" | grep -v '8937' | tee -a "filelist.txt"
elif [ "$type" == '8937'  ]
then
	echo "$filelists" | grep -v '8917' | tee -a 'filelist.txt'
fi
touch "$type".bat
echo 'fastboot oem enable-unlock-once' >> "$type".bat
clear
while read line
do
    a=`grep "$line" "$xml_file" | grep -aoe "label=[0-9a-zA-Z\"]*" | awk -F '"|"' '{print $2}'`
    if [ "$a" != "" ]
    then
	    grep "$line" "$xml_file" | grep -aoe "label=[0-9a-zA-Z\"]*" | awk -F '"|"' '{print $2}' > result.txt
	    for i in `cat result.txt`
	    do
		    echo "fastboot flash $i $line" >> "$type".bat
	    done
    else
	    echo '::'$line >> "$type".bat
    fi
done < "filelist.txt"
rm result.txt
echo "fastboot oem enable-debug-once" >> "$type".bat
echo "fastboot continue" >> "$type".bat
echo "adb devices" >> "$type".bat
#echo "fastboot reboot" >> "$type".bat
chmod u+x "$type".bat
