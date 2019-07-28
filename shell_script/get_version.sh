#!/bin/bash
read -t 60 -p "输入 exchange 账户名: " USER
[ "$USER" == "" ] && echo "账户名为空" && exit 1
read -t 60 -p "输入 exchange 账密码: " -s PASS
[ "$USER" == "" ] && echo "密码为空" && exit 1

[ -f "checklist.md5" ] && rm checklist.md5
smbclient -c "cd ${USER};get checklist.md5" //10.0.30.12/exchange_sw -U ${USER}%${PASS}
[ "$?" != 0 ] && echo "get checklist.md5 failed" && exit 1
DATA=`date "+%Y-%m-%d %H:%M:%S"`
record_msg="$USER  backup  at $DATA"
echo $record_msg >> record.txt
sed -n '4,$p' checklist.md5 > file_list.txt
readarray -t filearray < file_list.txt
rm -rf file_list.txt
for line in "${filearray[@]}"
do
    [ "$line" == "" ] && continue
    file_name=$(echo "$line" | awk -F "*" '{print $2}')
    md5_id=$(echo "$line" | awk '{print $1}')
    echo "$line"
    [ -f "$file_name" ] && rm "$file_name"
    smbclient -c "cd ${USER};get $file_name" //10.0.30.12/exchange_sw -U ${USER}%${PASS}
    if [ "$?" == 0 ]
    then
        real_md5_id=$(md5sum $file_name | awk '{print $1}')
        if [ "$real_md5_id" == "$md5_id" ]
        then
            echo $md5_id $real_md5_id
            echo -e "\e[32mmd5 check ok $file_name\e[0m"
        else
            echo -e "\e[31mmd5 check failed\e[0m"
            exit 1
        fi
    else
        echo -e "\e[31mget $file_name error\e[0m" && exit 1
    fi
done
