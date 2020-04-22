#!/bin/bash
echo "Usage: sh $0 Filename Title Tags"
#tags=`grep -r tags: ./*.md|awk -F":" '{print $3}'|uniq`
#for i in $tags
#do 
#echo $i
#done

num=`grep -E "title|tags|date|^--" $1 |wc -l`
rq=`date +'%Y-%m-%d %H:%M'`
if [ $num -ne 5 ];then
  sed -i "1i---" $1
  sed -i "1idate: $rq" $1
  sed -i "1itags: $3" $1
  sed -i "1ititle: $2" $1
  sed -i "1i---" $1
else
  grep -E "title|tags|date|^--" $1
fi
