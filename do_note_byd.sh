#!/bin/bash
#此脚本用来给仓库中的.c .cpp .h .xml .java添加'BYD Top Secret'注释
#此脚本共分为4个函数，他们的执行顺序如下
#1:get_repository_file
#2:process_repositories
#3:get_fileName
#4:do_note_for_one_file


readonly path=$(pwd)
readonly create_repositoryfile_auto=0 #自动创建的文件（默认值为0，表示手动创建）
readonly SECRET_LEVEL_ARRAY=('BYD Top Secret' 'BYD Confidential' 'BYD Internal Use')#文件保密等级
exec 1> >(tee "log.txt") 2>&1 #后台线程用来输出log日志




#函数一：得到仓库文件
function get_repository_file(){
	local -r repositoryFile="$1"
	if [ -f "$repositoryFile" ];then
		echo "$repositoryFile exist,start to do note"
	else
		if [ -d ".git" ];then
			echo "." > "$repositoryFile"
			create_repositoryfile_auto=1 #自动创建文件值初始化为1
		else
			echo -e "\e[31m $repositoryFile not exist!! \e[0m"
			exit 1
		fi
	fi
}


#函数二：
function process_repositories(){
	local -r repositoryfile="$1"
	if [ -f "$repositoryfile" ];then
		readarray -t repositoryArray < "${repositoryfile}" #把仓库文件读入数组中（数组的读取方式）
		if [ -d ".git" ] && [ "$create_repositoryfile_auto" -eq 1 ];then
			rm -rf ./"$repoistoryfile"
		fi
		#仓库名称和提交ID，如果在这个数组中，就统计这个文件的列数
		for repositoryNameAndCommitId in "${repositoryArray[@]}" 
		do
			countRaw=$(echo "$repositoryNameAndCommitId" | awk '{print NF}') #统计文件有多少列
			if [ "$countRaw" -eq 1 ];then
				repositoryName="$repositoryNameAndCommitId" #仓库名称
			elif [ "$countRaw" -eq 2 ];then
				repositoryName=$(echo "$repositoryNameAndCommitId" | awk '{print $1}') #仓库名称
				startCommId=$(echo "$repositoryNameAndCommitId" | awk '{print $2}') #开始提交的commitID
			elif [ "$countRaw" -eq 3 ];then
				repositoryName=$(echo "$repositorynameAndCommitId" | awk '{print $1}') #仓库名称
				startCommId=$(echo "$repositoryNameAndCommitId" | awk '{print $2}') #开始提交的commitID
				endCommId=$(echo "$repositoryNameAndCommitId" | awk '{print $3}') #结束提交的commitId
			else
				echo -e "\e[31m wrong repository!!! \e[0m"
			fi
	
		if [ -d "$repositoryName" ];then
			pushd ./"$repositoryName"  #pushd命令用来进入这个文件，和cd命令相同
			gitDir=$(git rev-parse --git-dir)  #此命令用来输出.git
			if [ "$gitDir" == ".git" ];then
				case "$countRaw" in #判断文件的列数，当列数为1，2，3时，此时进入第3个函数get_fileName
					1) get_fileName ;;
					2) get_fileName "$startCommId" ;;					
					3) get_fileName "$startCommId" "$endCommId" ;;
				esac
			else
				echo -e "\e[31m $repositoryName is not a git repository!! \e[0m"
				echo "$repositoryName" >> "$path"/wrong_path.txt
			fi
			popd #从目录中出来
		else
			echo -e "\e[32m $repositoryName is not a directory! \e[0m"
			echo "$repositoryName" >> "$path"/wrong_path.txt
		fi			
		done	
	else
		echo -e "\e[31m $repositoryfile not exist !!! \e[0m"
		exit 1
	fi
}


function do_note_for_one_file(){
	local -r file="$1" #参数1是一个文件
	local -r secretGrade="$2" #参数2为要添加的注释
	local -r file_Type="$3" #参数3是文件类型

	case $file_Type in
		c|cpp|h|java) echo ".$file_Type  file"
		local -r firstLine=$(sed -n "1p" "$file" | sed -n "/\*BYD /"p) #第一行
		if [ "$firstLine" == "" ] || [ -z "$firstLine" ];then
			sed -i "1i /*$secretGrade*/" "$file"
		else
			sed -i "1d" "$file"
			sed -i "1i /*$secretGrade*/" "$file"
		fi
		;;
		xml) echo ".xml file" 
		#xml文件的第一行为<?xml version="1.0" encoding="utf-8"?>，所以添加注释时要在此行的下面添加
		local -r xml_encoding=$(sed -n "1,20p" "$file" | sed -n "/ version=".*" encoding=".*"/p")	
		if [ "$xml_encoding" == "" ] || [ -z "$xml_encoding" ];then
			sed -i "/<!--BYD  /d" "$file"
			sed -i "1i <!--$secretGrade-->" "$file"	#在第1行之前添加注释		
		else
			sed -i "/<!--BYD /d" "$file" #删除包含BYD的行
			sed -i "2i <!--$secretGrade-->" "$file" #在第2行之前添加注释
		fi
		;;
		*) echo "unknow file type"		
	esac
}

#函数三：得到文件名称
function get_fileName(){
	local -r logLine=$(git log --oneline | wc -l) #得到仓库中log的行数
	#此处的$1表示startCommit
	if [ "$1" == "" ] || [ -z "$1" ];then
		#寻找带有MT或MTK的标志，如果存在MTK或MT,则不是BYD仓库
		local -r MT_HIOS_XOS=$(git remote -v | grep -e "MT[0-9]" -e "MTK[0-9]" | sed -n "1p" | awk '{print $2}')
		if [ "$MT_HIOS_XOS" == "" ] || [ -z "$MT_HIOS_XOS" ];then
			echo "BYD repository"
			if [ "$logLine" -eq 1 ];then
				echo -e "\e[31m one line of log!! \e[0m"
				return
			elif [ "$logLine" -ge 2 ];then
				local -r startCommit=$(git log --format="%H" | tac | sed -n '1p') #倒叙输出log,打印第一行，此时的第一行则是最后一个commitID
			else
				echo -e "\e[31m error log or no log!! \e[0m"
				return
			fi
		else
			echo "MTK repository"
			if [ "$logLine" -eq 1 ] || [ "$logLine" -eq 2 ];then
				echo -e "\e[31m one log or two log! \e[0m"
				return
			elif [ "$logLine" -ge 3 ];then #只有在log>3条时才能进行比较
				local -r startCommit=$(git log --format="%H" | tac | sed -n '2p')
			else
				echo -e "\e[31m error log or no log \e[0m"
				return
			fi
		fi
	else
		local -r startCommit="$1"
	fi

	#此处的$2表示endCommit
	if [ "$2" == "" ] || [ -z "$2" ];then
		local -r endCommit="HEAD"
	else
		local -r endCommit="$2"
	fi
	
	#得到文件名称的数组
	#git diff --name-status "$startCommit" "$endCommit":输入这段提交中的所有文件
	#sed "/^D/d"：输出已经删除的文件
	#grep -e "\.c\>" -e "\.cpp\>" -e "\.h\>" -e "\.java\>" -e "\.xml\>"：查找.c .cpp .h .java .xml文件
	fileNameArray=($(git diff --name-status "$startCommit" "$endCommit" | sed "/^D/d" | awk '{print $2}' | grep -e "\.c\>" -e "\.cpp\>" -e "\.h\>" -e "\.java\>" -e "\.xml\>"))
	for filePathAndName in "${fileNameArray[@]}"
	do
		if [ -f "$filePathAndName" ];then
			fileType=$(echo "$filePathAndName" | awk -F "." '{print $NF}') #得到文件的类型
		else
			echo "$fileType is not exists!"
			continue
		fi

		case "$fileType" in #当文件类型如下中的这些，则进行do_note_for_one_file操作
			c|h|cpp|java|xml) do_note_for_one_file "$filePathAndName" "${SECRET_LEVEL_ARRAY[0]}" "$fileType" ;;
			*) echo "$fileType unknow file type" ;;
		esac
	done
	unset fileNameArray
}

################################
############## main ############
################################
get_repository_file "repository.txt"
process_repositories "repository.txt"
