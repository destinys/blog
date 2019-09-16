#!/bin/bash

pre_dir=$1

if [ ${#pre_dir} -ne 0 ];then
  cd $pre_dir
fi

for i in `ls *.md`
do 

  echo "the filename is: "$i"."

  flag=`grep -l "(media/" $i`

  if [ ${#flag} -ne 0 ];then
    src=`grep "(media/" $i|cut -d"/" -f2|uniq`
    echo $src
    dest=${i%%\.*}
  
    if [ ! -d $dest ];then
      echo "create  img dir:"$dest"."
      mkdir $dest
    else
      echo "img dir "$dest"already exists."
    fi
    
    echo "copy img to"$dest"dir."
    \cp  ./media/$src/*.jpg $dest/

    echo "modify post img dir."
    sed -i "s#media/${src}#$dest#g" $i
  
  else
    echo "the post does not have local img."
  fi

done







