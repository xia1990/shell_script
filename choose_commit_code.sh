#!/bin/bash
#从10上的MP分支合入到251上的master分支

PATHROOT=`pwd`
PROJECT="S100X"
COMMITID=$1
describe=$2

function get_file(){
    cd $PATHROOT/wind
        #得到这笔提交的文件信息
        git diff $COMMITID^..$COMMITID --name-status > files.txt
        readarray -t file_array < files.txt
        for line in "${file_array[@]}"
        do
            TYPE=$(echo $line | awk '{print $1}')
            FILES=$(echo $line | awk '{print $2}')
            #得到要复制文件的名称
            filename=$(basename $FILES)
            #得到要复制文件所在路径 
            filepath=$(echo ${FILES%/*})

            #目标文件
            copyfile=$(echo ${FILES#*/})
            echo $copyfile

            #目标文件路径 
            newfilepath=$(dirname $copyfile)  
        done
    cd -
}


function copy_file(){
	get_file
    cd $PATHROOT/wind
        #修改或新增文件则执行复制操作
        if [[ $TYPE == "M" || $TYPE == "A" ]];then
            cd $filepath
                cp -r $filename $PATHROOT/../S100X_251_Master/$newfilepath
            cd -
            #删除
        elif [ $TYPE == "D" ];then
            cd $newfilepath
                rm -rf $filename
            cd -
        else
            echo "错误" && exit 1
        fi			
    cd -
}


function commit_code(){
    get_file
    cd $PATHROOT/../S100X_251_Master/$newfilepath
        git add .
        message="[Subject]\n[$PROJECT]\n[Bug Number/CSP Number/Enhancement/New Feature]\nN/A\n[Ripple Effect]\nN/A\n[Solution]\nN/A\n[Project]\n[$PROJECT]\n\n\n"
        commit_message=$(echo -e $message | sed "0,/\[$PROJECT\]/s/\[$PROJECT\]/&$describe/")        
        git commit -m "$commit_message"

        if [[ $TYPE == "M" ]];then
            print "modified:  "$copyfile
        elif [[ $TYPE == "D" ]];then
            print "deleted:  "$copyfile
        elif [[ $TYPE == "A" ]];then
            print "new file:  "$copyfile
        else
            echo "type error" && exit 2
        fi
    cd -        
}

################MAIN##########
copy_file "$1"
commit_code "$2"
