#!/bin/bash
wind_path=`pwd`
root_path=${wind_path%/*}
wind_commit_path=$wind_path/.commit_info
wind_commit_log=$wind_commit_path/commit.log
just_add_path=$wind_commit_path/just_add
wind_backup_path=$wind_commit_path/wind_backup
FLAG_EXIST=0          #原生代码是否存在该文件
ciProInfo=$1

function init_backupFolder(){

    cd $wind_path
    if [ ! -d .commit_info ]; then
        mkdir .commit_info
    fi
    cd  .commit_info
    if [ ! -d  commit_backup_1 ] ; then
        mkdir commit_backup_1; check_exit makedir
        backupFile=commit_backup_1
    elif [ ! -d commit_backup_2 ] ; then
        mkdir commit_backup_2; check_exit makedir
        backupFile=commit_backup_2
    elif [ ! -d commit_backup_3 ] ;then
        mkdir  commit_backup_3; check_exit makedir
        backupFile=commit_backup_3
    elif [ -d commit_backup_3 ];then
        rm -rf  commit_backup_1; check_exit makedir
        mv  commit_backup_2  commit_backup_1
        mv  commit_backup_3  commit_backup_2
        rm -rf commit_backup_3
        mkdir  commit_backup_3; check_exit makedir
        backupFile=commit_backup_3
    fi

    wind_commit_path=$wind_path/.commit_info/$backupFile
    just_add_path=$wind_commit_path/just_add
    wind_backup_path=$wind_commit_path/wind_backup
    wind_commit_log=$wind_commit_path/commit.log
    cd  -

}


function get_add_file(){

    cd $wind_path
    status_info=$wind_commit_path/git_status_info.txt
    commit_status_info=$wind_commit_path/git_ci_status_info.txt
    new_file_list=$wind_commit_path/new_file.txt
    just_add_list=$wind_commit_path/just_add_list.txt
    modified_file_lsit=$wind_commit_path/modified_file.txt
    deleted_file_lsit=$wind_commit_path/deleted_file.txt
    check_file_status=$wind_commit_path/checkFile_status.txt
    git status .  >> $status_info; check_exit status


    grep "new file:" $status_info | cut -d ":" -f 2 > $new_file_list
    if [ `ls -l $new_file_list | awk '{print $5}'` -gt 0 ];  then
        FLAG_ADD=1
        echo "Have new file" >> $wind_commit_log
    else
        echo "No new file,just do git commit" >> $wind_commit_log
        git commit;check_exit commit
        #rm -rf .commit_info
        exit 0
    fi
    if [ "`grep "Changes not staged for commit" $status_info`" ]; then
        lineNo=`grep -n "Changes not staged for commit" $status_info`
        sed -i '/Changes not staged for commit/,$d' $status_info

    fi

    grep "deleted:" $status_info | cut -d ":" -f 2 > $deleted_file_lsit
    if [ `ls -l $deleted_file_lsit | awk '{print $5}'` -gt 0 ];  then
        echo "have deleted file" >> $wind_commit_log
    fi

    grep "modified:" $status_info | cut -d ":" -f 2 > $modified_file_lsit
    if [ `ls -l $deleted_file_lsit | awk '{print $5}'` -gt 0 ];  then
        echo "have modified file" >> $wind_commit_log
    fi


    cat $status_info  >> $wind_commit_log

}

function deal_addfile(){
    echo "Start deal_addfile" >>$wind_commit_log
    rm -rf  $just_add_list
    cat $new_file_list | while read LINE
    do
        filepath=${LINE%/*} ##即删除从右边开始到第一个"/"及其右边所有字符
        echo "flie path:$filepath" >>$wind_commit_log
        if [ x"$filepath" != x"" ] && [[ $filepath = A515* ]] ; then ##目前只有D615，以后新增项目这里可能要改！！！！shenfurong
            #filename=${LINE##*/}
            #custom_files_dir=${LINE%%/*} ##一部原始的设计，即删除从右边开始到最后一个"/"及其右边所有字符
			custom_files_dir=`echo "$LINE"  | gawk 'BEGIN{FS="/"}{print $1"/"$2}'` ##这里改为类似D615/master/custom_files这样的路径！！！shenfurong
			custom_files_dir_project=${LINE%%/*}
            if [ x$custom_files_dir_project != x"A515" ] ;then ##新增项目这里要改！！！！shenfurong
                echo "new file path is not correct! git commit fail!!!"
                exit 1
            fi
            echo "custom_file path is: $custom_files_dir" >>$wind_commit_log
            #checkfileName=${LINE#*/}  ##一部原始的设计，即删除从左边开始到第一个"/"及其左边所有字符
			checkfileName=${LINE#*/*/}  ##这里路径和一部的不一样！！！！！！！shenfurong
            echo "checkfileName :$checkfileName" >>$wind_commit_log
            Check_addFile $checkfileName $custom_files_dir
        fi
    done

    if [ -f $just_add_list ] && [ `ls -l $just_add_list | awk '{print $5}'` -gt 0 ] && [ -d $just_add_path ] ;then
        do_justadd $custom_files_dir
        recoveryModify
    else
        echo "Have new file,but not mtk file,just commit" >>$wind_commit_log
        git commit; check_exit commit
        exit 0
    fi

}

function smartCP() {
    srcfile=$1
    destpath=$2

    if [ ! -d $destpath ];then
        mkdir  -p $destpath
    fi
    cp -a $srcfile $destpath; check_exit copy $srcfile

}


function recoveryModify() {
    cp -a $wind_backup_path/* $wind_path; check_exit copy $wind_backup_path

    cat $new_file_list | while read LINE
    do
        git add  $LINE; check_exit add
    done

    if [ -f $modified_file_lsit ] && [ `ls -l $modified_file_lsit | awk '{print $5}'` -gt 0 ]; then
        cat $modified_file_lsit | while read LINE
        do
            git add  $LINE;check_exit add
        done
    fi
    if [ -f $deleted_file_lsit ] && [ `ls -l $deleted_file_lsit | awk '{print $5}'` -gt 0 ]; then
        cat $deleted_file_lsit | while read LINE
        do
            git rm  $LINE;check_exit gitrm
        done
    fi
    git commit;check_exit commit
}

function do_justadd() {

    wind_custom_path=$1
    cd $wind_path

    cat $just_add_list | while read LINE
    do
        filepath=${LINE%/*}
        smartCP $LINE $wind_backup_path/$filepath/; result=$?
        if [ $result -ne 0 ] ;then
            echo "Backup data failed ,please git commit manually!"
            exit 0
        fi
    done
    git reset 1>/dev/null 2>&1;check_exit reset  ###取消暂存状态
    cp -a $just_add_path/*  $wind_path/$wind_custom_path;check_exit copy $just_add_path ##把修改前的文件拷贝过来
    echo "cp -a $just_add_path/*  $wind_path/$wind_custom_path" >> $wind_commit_log

    cat $just_add_list | while read LINE
    do
        git add $LINE;check_exit add
    done

    tmeplate=$wind_commit_path/.commit_temp_info

    echo "
[Subject]
[$ciProInfo] [JUST ADD] Add native mtk files
[Bug Number/CSP Number/Enhancement/New Feature]
N/A
[Ripple Effect]
N/A
[Solution]
N/A
[Project]
[$ciProInfo] [JUST ADD]
    " > $tmeplate
    echo "JUST ADD:" >>$tmeplate
    cat $just_add_list>>$tmeplate

    cat $tmeplate

       listinfo=`cat $tmeplate`; git commit  -m  "$listinfo"; result=$?
        if [ $result -ne 0 ] ;then
            echo "git commit  failed ,please git commit manually!"
            exit 0
        fi

}

function Check_addFile() {
    checkFile=$1
    wind_custom_path=$2
    echo "Check_addFile start $checkFile" >>$wind_commit_log
    cd $root_path
    FLAG_EXIST=0
    if [ -f $checkFile ]; then
        FLAG_EXIST=1
        echo "$checkFile is in Code,need to add  to just add" >>$wind_commit_log
    fi

    if [ $FLAG_EXIST -eq 1 ];then
        gitFilepath=${checkFile%/*}   ##干净的文件路径（不包含文件名）
        gitFileName=${checkFile##*/}  ##文件名字
        cd $gitFilepath
        git status $gitFileName > $check_file_status ##进到alps/路径/下查看该文件是否被修改
        echo "cd $gitFilepath   git status $gitFileName" >>$wind_commit_log
        if [ "`grep modified: $check_file_status`" ]; then
            if [ ! -d .backup_git_add ] ; then
                mkdir .backup_git_add
            fi

            cp $gitFileName .backup_git_add/; result=$?  ##如果该文件被修改了，将其copy到当前目录下的.backup_git_add/
            if [ $result -eq 0 ]; then
                git checkout $gitFileName ; result=$?    ##copy完成后将其checkout
                if [ $result -eq 0 ]; then
                    smartCP $gitFileName $just_add_path/$wind_custom_path/$gitFilepath; result=$?  ##然后再将其拷贝到$just_add_path/XXX/.../下面备份
                    echo "result is $result">>$wind_commit_log
                     if [ $result -eq 0 ]; then
                        cp .backup_git_add/$gitFileName  . ; check_exit copy $gitFilepath/.backup_git_add  ##将.backup_git_add/下的文件重新拷贝回去
                        echo "$wind_custom_path/$checkFile" >>$just_add_list
                        rm -rf .backup_git_add;check_exit rmove  $gitFilepath/.backup_git_add  ##删除.backup_git_add/
                     fi
                fi
            fi
        elif [ "`grep 'nothing to commit' $check_file_status`" ] ;then
            smartCP $gitFileName $just_add_path/$wind_custom_path/$gitFilepath  ##如果该文件没有被修改，直接将其拷贝到$just_add_path/XXX/.../下面备份
            echo "$wind_custom_path/$checkFile" >>$just_add_list
            echo "nothing to commit" >>$wind_commit_log
        fi
    fi
    echo "Check_addFile end  $checkFile" >>$wind_commit_log
}


function check_exit()
{
    result=${PIPESTATUS[0]}
    action=$1
    backpath=$2
    if [ ! $result ]; then
    result=0
    fi
    if [ $result -ne 0 ];then
        if [ x$action == x"commit" ] || [ x$action == x"reset" ] || [ x$action == x"status" ] || [ x$action == x"checkout" ] || [ x$action == x"add" ] || [ x$action == x"gitrm" ]; then
           echo -n -e "\033[31mgit $action failed.\033[0m"
        else
           echo -n -e "\033[31m$action failed.\033[0m"
        fi
        if [ x$backpath != x"" ];then
            echo -n -e "\033[31m Please find back you code from $backpath\033[0m"
        fi
        echo
        exit 1
    fi

}




function main(){
    init_backupFolder
    echo "start git_ci.sh `date +"%Y-%m-%d %H:%M:%S"`" >> $wind_commit_log
    if [ x$1 != x"" ];then
        ciProInfo=$1
    fi
    get_add_file
    deal_addfile
}


main $1
