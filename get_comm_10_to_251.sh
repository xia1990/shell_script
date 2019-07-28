#!/bin/bash
commit_id="$1"
git log $commit_id > /dev/null
[ $? != 0 ] && echo "commit id error" && exit 1

git diff "$commit_id"^ "$commit_id" --name-status > modified_files.list
git reset --hard "$commit_id"
readarray -t file_array < modified_files.list
for line in "${file_array[@]}"
do
    a_type=$(echo $line | awk '{print $1}')
    file=$(echo $line | awk '{print $2}')
    echo $file
    exit
#    if [ -f "$file" ]
#    then
        if [[ "$a_type" == "M" || "$a_type" == "A" ]]
        then
            :
            echo "fugai"
        elif [ "$a_type" == "D" ]
        then
            :
            echo "shanchu"
        fi

#    fi
done
