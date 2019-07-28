#!/bin/bash

commit_old="$1"
commit_new="$2"

git log "$commit_old".."$commit_new" --pretty=oneline | grep -v "Merge" | grep -v "Modfiy Version" |  awk '{print $1}' > log_list.txt
echo "$commit_old" >> log_list.txt

readarray -t log_array < log_list.txt
array_lengh="${#log_array[@]}"
echo $array_lengh
real_lengh=$(($array_lengh - 1))
echo $real_length
for i in `seq 0 $real_lengh`
do
        if [ "$i" != "$real_lengh" ];then
		messag=$(git log --pretty=format:"%s" "${log_array[$i]}" -1)
		change_id=$(git log "${log_array[$i]}" -1 | grep "Change-Id" | awk -F':' '{print $2}')
		File=$(git log "${log_array[$i]}" --pretty=format:"" --name-status -1)
		#文件保存为CVS格式，使用EXCEL打开，
		echo -e "$change_id\t$messag\t$File" >> result.txt
		unset j msg change_id diff s
        fi
        echo ""
done
