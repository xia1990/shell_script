#!/bin/bash
name_array=('cenxingcan' 'xiongshigui' 'yangjieqiong' 'sunhuihui' 'qiancheng' 'youxiaoyan' 'mohongwu' 'liyong01' 'dingyisheng' 'zhuyujing' 'wangjie01' 'yaoyuanchun' 'wangjinlong')
ip_array=('10.0.30.68' '10.0.30.35' '10.0.30.32' '10.0.30.31' '10.0.30.58' '10.0.30.20' '10.0.30.36' '10.0.30.38' '10.0.30.13' '10.0.30.28' '10.0.30.78' '10.0.30.48' '10.0.30.18')
if [ "${#name_array[@]}" == "${#ip_array[@]}" ]
then
    echo "equel"
else
    echo "${#name_array[@]}" "${#ip_array[@]}"
fi
array_len="${#name_array[@]}"
for i in `seq 0 $(($array_len -1))`
do
    ssh -p  22 "${name_array[$i]}"@"${ip_array[$i]}" 'cd mirror&& ./mirror_update.sh'
done
