#!/bin/bash
for i in `ls`
do
    if [ -d "$i" ]
    then
       cd $i
       pwd && sleep 3s
       if [[ "$i" =~ 300 ]]
       then
           repoc sync -j8 -f
        else
           repo sync -j8 -f
       fi
       if [ "1" == `date +%w` ]
       then
           repo forall -c 'pwd && git gc'
       fi
       cd -
    fi
done
