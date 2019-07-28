#!/bin/bash
ROOT_PATH=$(pwd)

function args_parse(){
    local_be_get_code="$1"
    [ ! -d "$local_be_get_code" ] && echo "路径不正确" && exit 1
    local_be_get_code_branch="$2"
    pushd  "$local_be_get_code"
        git br | grep "$local_be_get_code_branch" 
        [ "$?" != "0" ] && echo "分支不存在" && exit 1
    popd
    local_code_branch="$3"
    git br | grep "$local_code_branch" 
    [ "$?" != "0" ] && echo "分支不存在" && exit 1
}


function get_commit_id_list(){
    current_commit=$(git log --pretty=oneline -1 | awk '{print $1}')
    pushd "$local_be_get_code"
        update_commit_array=($(git log "${current_commit}"..HEAD --pretty=oneline | awk '{print $1}'))
        git log "${current_commit}"..HEAD --pretty=oneline --format=%s > "$ROOT_PATH"/commit_message.txt
    popd
    commit_len=${#update_commit_array[@]}

    readarray -t update_commit_message_array < commit_message.txt
    message_len=${#update_commit_message_array[@]}
    message_len_1=$(($message_len - 1))
}


function cp_add_commit(){
    for i in $(seq 0 $message_len_1)
    do
        pushd "$local_be_get_code"
            echo "${update_commit_array[$(($message_len_1 - $i ))]}" "${update_commit_message_array[$(($message_len_1 - $i ))]}"
            git reset --hard "${update_commit_array[$(($message_len_1 - $i ))]}"
        popd
        cp -a "$local_be_get_code"/* .
    done
    
}


################################

args_parse "$@"
get_commit_id_list
cp_add_commit
