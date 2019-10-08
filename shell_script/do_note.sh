#!/bin/bash
#此脚本用来给BYD仓库添加注释


readonly SECRET_LEVEL_ARRAY=('Transsion Top Secret' 'Transsion Confidential' 'Transsion Internal Use')
readonly path=$(pwd)
creat_repositoryFile_auto=0 #非自动生成repository.txt文件,手动带入文件参数的时候这个值为0
exec 1> >(tee "log.txt") 2>&1 #收集log


function do_note_for_one_file(){
	local -r file="$1" #文件路径和文件名称
	local -r secretGrade="$2" #保密等级
	local -r file_Type="$3" #文件类型 java c xml 之类的东西

#根据文件类型，依次加注释
	case $file_Type in
		c|h|cpp|java) echo ".$file_Type file" #这几种类型的时候
		local -r firstLine=$(sed -n "1p" "$file" | sed -n "/\/*Transsion /"p) #取出文件第一行
		if [ "$firstLine" == "" ] || [ -z "$firstLine" ];then #第一行没有搜到Transsion关键字，说明以前没有加过注释
			sed -i "1i /*$secretGrade*/" "$file" #插入注释
		else
			sed -i "1d" "$file" #如果搜索到关键字,把第一行删了，相当于update操作，下面插入
			sed -i "1i /*$secretGrade*/" "$file" #插入注释
		fi
		;;
		xml) echo ".xml file" #如果是xml类型
		local -r xml_encoding=$(sed -n "1,20p" "$file" | sed -n "/ version=".*" encoding=".*"/p") #前20行搜索一下有没有这种东西在第一行 <?xml version="1.0" encoding="UTF-8"?> 这玩意必须在第一行，不然编译报错
		if [ "$xml_encoding" == "" ] || [ -z "$xml_encoding" ];then #如果没有，就删了带Transsion关键字的行，再插入注释
			sed -i '/<!--Transsion /d' "$file"
			sed -i "1i <!--$secretGrade-->" "$file"
		else #如果第一行是 <?xml version="1.0" encoding="UTF-8"?>
			sed -i '/<!--Transsion /d' "$file" #就删了带Transsion关键字的行
			sed -i "2i <!--$secretGrade-->" "$file" #在第二行插入注释
		fi
		;;
		*) echo "unknow file type!!!";;
	esac
}


function get_fileName(){
	local -r logLine=$(git log --oneline | wc -l) #log个数
#即使git log 报错。logLine 也会等于0
	if [ "$1" == "" ] || [ -z "$1" ];then #如果没有起始commit-id
		local -r MT_HIOS_XOS=$(git remote -v | grep -e "MT[0-9]" -e "MTK[0-9]" | sed -n "1p" | awk '{print $2}') #在git remote -v结果中查找有没有MT或者MTK关键字，没有的话就当做是传音自己的仓库
		if [ "$MT_HIOS_XOS" == "" ] || [ -z "$MT_HIOS_XOS" ];then #
			echo "TRANSSION repository"
			if [ "$logLine" -eq 1 ];then #只有一条log没有办法做git diff commit-id1 commit-id2操作，报错吧
				echo -e "\e[31monly one line of log!!!\e[0m"
				return
			elif [ "$logLine" -ge 2 ];then #大于等于两条log，起始commit-id是倒数第一条
				local -r startCommit=$(git log --format="%H" | tac | sed -n '1p') #tac是倒叙的意思
			else
				echo -e "\e[31mlog error or no log!!!\e[0m" #log不对或者没有log,报错吧
				return
			fi
		else
			echo "MTK repository" #在git remote -v结果中查找有没有MT或者MTK关键字，有的话就当做是MTK的仓库
			if [ "$logLine" -eq 1 ] || [ "$logLine" -eq 2 ];then #一条log或者两条log都报错。基线实在第二条log才加入代码的。只有一条无法git diff，两条git diff出来的文件是MTK自带的，没意义。
				echo -e "\e[31monly one or two line of log!!!\e[0m" #报错吧
				return
			elif [ "$logLine" -ge 3 ];then #log大于等于三条就正常了
				local -r startCommit=$(git log --format="%H" | tac | sed -n '2p') #倒数第二条是起始commit-id
			else
				echo -e "\e[31mlog error or no log!!!\e[0m"
				return
			fi
		fi
	else
		local -r startCommit="$1" #如果$1 有指定 那就用指定的commit-id当做起始commit-id
	fi

	if [ "$2" == "" ] || [ -z "$2" ];then
		local -r endCommit="HEAD" #如果$2 没有传入就用HEAD当做终止commit-id
	else
		local -r endCommit="$2" #如果指定了$2 那就用指定的值喽
	fi

#第一次文件过滤。
	fileNameArray=($(git diff --name-status "$startCommit" "$endCommit" | sed "/^D/d" | awk '{print $2}' | grep -e "\.c\>" -e "\.cpp\>" -e "\.h\>" -e "\.java\>" -e "\.xml\>" )) #git diff比较两个commit-id之间的差异文件,过滤掉被删除的文件
	for filePathAndName in "${fileNameArray[@]}" #
	do
		if [ -f "$filePathAndName" ];then
			fileType=$(echo "$filePathAndName" | awk -F "." '{print $NF}') #从文件名称中取出后缀名称,NF是最后一个域
		else
			echo "$filePathAndName do not exist!!!"
			continue
		fi

#第二次文件过滤,只处理以下几种文件
		case "$fileType" in #根据文件类型调用最底层 加注释函数
			c|h|cpp|java|xml)  do_note_for_one_file "$filePathAndName" "${SECRET_LEVEL_ARRAY[0]}" "$fileType" ;; #参数是文件路径和文件名 保密等级 文件类型
			*) echo "$fileType other type of file!!!";;
		esac
	done
	unset fileNameArray
}


function process_repositories(){
	local -r repositoryfile="$1" #repository.txt文件
	if [ -f "${repositoryfile}" ];then #文件存在的时候
		readarray -t repositoryArray < "${repositoryfile}" #将文件内容导入到数组中,可能会有3列哦
		if [ -d  ".git" ] && [ "$creat_repositoryFile_auto" -eq 1 ];then #如果当前是git仓，并且repository.txt文件是自动生成的，就删除这个文件
			rm -rf ./"$repositoryfile"
		fi
		for repositoryNameAndCommitId in "${repositoryArray[@]}" #读取出文件的每一行
		do
			countRaw=$(echo "$repositoryNameAndCommitId" | awk '{print NF}') #检测文件有多少列
			if [ "$countRaw" -eq 1 ];then #如果是一列
				repositoryName="$repositoryNameAndCommitId" #仓库名称
			elif [ "$countRaw" -eq 2 ];then #如果是两列
				repositoryName=$(echo "$repositoryNameAndCommitId" | awk '{print $1}') #仓库名称
				startCommId=$(echo "$repositoryNameAndCommitId" | awk '{print $2}') #这个仓库的起始commit-id
			elif [ "$countRaw" -eq 3 ];then #如果是三列
				repositoryName=$(echo "$repositoryNameAndCommitId" | awk '{print $1}') #仓库名称
				startCommId=$(echo "$repositoryNameAndCommitId" | awk '{print $2}') #这个仓库的起始commit-id
				endCommitId=$(echo "$repositoryNameAndCommitId" | awk '{print $3}') #这个仓库的终止commit-id
			else
				echo "wrong repositories!!!"
			fi

			if [ -d "$repositoryName" ];then #判断仓库名称是一个文件夹
				pushd ./"$repositoryName" 
					gitDir=$(git rev-parse --git-dir) #如果是当前是在git仓库下,会输出.git
					if [ "$gitDir" == ".git" ];then #如果是在git仓库下
						case "$countRaw" in #根据文件列数，带入不同参数
							1) get_fileName ;; #不带参数
							2) get_fileName "$startCommId" ;; #带一个
							3) get_fileName "$startCommId" "$endCommitId" ;; #带两个
						esac
					else
						echo -e "\e[31m $repositoryName is not a git repository!!!\e[0m" #当前不是git仓库，无法使用git命令,报错。
						echo "$repositoryName" >> "$path"/wrong_repositoryName.txt ##输出路径名称到当前路径下的这个文件
					fi
				popd
			else
				echo -e "\e[31m $repositoryName is not a directory!!!\e[0m" #当前没有repository.txt文件,报错
				echo "$repositoryName" >> "$path"/wrong_path.txt #输出路径名称到当前路径下的这个文件
			fi
		done
	else
		echo -e "\e[31m 仓库名称文件不存在！！！\e[0m"
		exit 1
	fi
}


function get_repository_file(){
	local -r repositoryFile="$1" #repository.txt文件
	if [ -f "$repositoryFile" ];then #文件存在打印一下提示信息
		echo "$repositoryFile exist,start to do note !!!!"
	else #如果文件不存在就要生成这个文件
		if [ -d ".repo" ];then #如果当前是repo多仓库代码环境
			repo list -p > "$repositoryFile" #自动生成repository.txt文件
		elif [ -d ".git" ];then #如果当前是单库.git仓库代码环境
			echo "." > "$repositoryFile" #自动生成repository.txt文件
			creat_repositoryFile_auto=1 #当前是自动生成repository.txt文件标识
		else
			echo -e "\e[31m 仓库名称文件不存在！！！ 请将脚本在repo代码环境或者单库下执行！！！\e[0m" #没有提供repository.txt文件，也不是repo环境，也不是单个git仓库就报错
			exit 1
		fi
	fi
}


#########################
######### main ##########
#########################
get_repository_file "repository.txt" #可以本地指定一个repository.txt 文件 文件每行可以写最多三列(可以不写) 依次是 本地仓库路径 起始commit-id 终止commit-id
process_repositories "repository.txt" #同上
