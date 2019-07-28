#!/bin/bash
#此脚本用来做大版本升级


ROOTPATH=$(pwd)
GERRIT_IP=10.0.30.10
BRANCH=master_r3.0.1_00029.1

#得到仓库名称的数组
namearray=($(repo list | awk '{print $3}'))
#得到PATH的数组
patharray=($(repo list | awk '{print $1}'))

#得到仓库的个数
name_length=${#namearray[@]}
path_length=${#namearray[@]}


#创建新增仓库
function create_project(){
    for i in `cat project_name.txt`
    do
        ssh -p 29418 $GERRIT_IP gerrit create-project $i -t FAST_FORWARD_ONLY -p Privilege/test
        #设置头指针的指向，即切换分枝
        #ssh -p 29418 10.0.30.10 gerrit set-head $i  --new-head master
        push_new_project
    done
}


#push新增仓库
function push_new_project(){
    for i in `cat project_path.txt`
    do
    pushd $i
        git push origin2 HEAD:$BRANCH
        #git push origin2 HEAD:master
    popd
    done
}

function main(){
    #遍历仓库的总个数
    for i in $(seq 0 $(($name_length-1)))
    do
        #得到所有name和path的值
        name=${namearray[$i]} 
        path=${patharray[$i]}
        pushd $path > /dev/null
            #添加远程
            git remote add origin2 ssh://10.0.30.10:29418/NX_LA_SDM450_PSW/$name
            #查看远程是否存在这个仓库
            git ls-remote origin2
            if [ $? == 0 ]
            then 
                #如果有这个仓库，就直接执行push操作
                git push origin2 HEAD:$BRANCH
            else
                #得到新增仓库和路径
                echo LNX_LA_SDM450_PSW/$name >> $ROOTPATH/project_name.txt
                echo $path >> $ROOTPATH/project_path.txt
                #创建新增仓库
                create_project
            fi
        popd > /dev/null
    done
}


#####################MAIN##############
main "$#"
