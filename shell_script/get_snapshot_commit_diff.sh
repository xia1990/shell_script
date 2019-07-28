#!/bin/bash
rm -rf path_commit_id1 path_commit_id2 path1 commit_id1 log_update.csv file1 file2 incre_projects.txt 
ROOT=$(pwd)

grep -aoe path.* "$1" | sort > file1
grep -aoe path.* "$2" | sort > file2
readarray -t file1_array < file1
readarray -t file2_array < file2

for i in "${file1_array[@]}"
do
    path=$(echo $i | grep -aoe "path=[.A-Z_a-z0-9\"/-]*" | awk -F '"' '{print $2}')
    commit_id=$(echo $i | grep -aoe "revision=[.A-Z_a-z0-9\"/-]*" | awk -F '"' '{print $2}')
	echo $path >> "$ROOT"/path1
	echo $commit_id >> "$ROOT"/commit_id1
done
for j in "${file2_array[@]}"
do
    path=$(echo $j | grep -aoe "path=[.A-Z_a-z0-9\"/-]*" | awk -F '"' '{print $2}')
    commit_id=$(echo $j | grep -aoe "revision=[.A-Z_a-z0-9\"/-]*" | awk -F '"' '{print $2}')
	echo $path $commit_id >> "$ROOT"/path_commit_id2
done

readarray -t path_commit_id_array2 < "$ROOT"/path_commit_id2
for k in "${path_commit_id_array2[@]}"
do
    path=$(echo "$k" | awk '{print $1}')
    new_commit_id=$(echo "$k" | awk '{print $2}')
	number=$(grep --word-regexp "^$path$" "$ROOT"/path1 | wc -l )
    if [ "$number" -gt 1 ]
	then
	    echo "$path"
	    grep --word-regexp "^$path$" "$ROOT"/path1 && exit 1
	elif [ "$number" == 1 ]
    then
	    path_in_path1_line=$(grep --word-regexp -n "^$path$" "$ROOT"/path1 | awk -F ':' '{print $1}')
        old_commit_id=$(sed -n "$path_in_path1_line"p "$ROOT"/commit_id1)
        if [ "$old_commit_id" != "$new_commit_id"  ]
        then
            pushd "$path"
	            log_line=$(git log  --oneline "$old_commit_id".."$new_commit_id" | wc -l)
#	            log_line=$(git log  --oneline "$old_commit_id"..."$new_commit_id" | wc -l)
                echo $log_line $old_commit_id $new_commit_id
        	    if [ "$log_line" != 0 ]
                then
                    echo "PATH: $path" >> "$ROOT"/log_update.csv
#                   git log  --pretty=format:"%an"\ "%ae"\ "%h"\ "%s" "$old_commit_id"..."$new_commit_id" >> "$ROOT"/log_update
	                git log  --pretty=format:"%ae"\,"%s" "$old_commit_id".."$new_commit_id" >> "$ROOT"/log_update.csv
                    echo "                  " >> "$ROOT"/log_update.csv
                fi
            popd
        fi
	else
	    echo "当前仓库为新增仓库"&& echo $path "$ROOT"/incre_projects.txt
        exit 1
	fi
done
