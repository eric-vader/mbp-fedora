#!/bin/bash
unzip $1.zip -d $1
openssl rsautl -decrypt -inkey id_rsa.pem -in $1/$1.bin.enc -out $1/$1.bin
openssl enc -d -aes-256-cbc -in $1/$1.tar.gz.enc -out $1/$1.tar.gz -pass file:$1/$1.bin
for mp4encpath in $1/*.mp4.enc; do
    mp4encfile="${mp4encpath##*/}"
    mp4file=${mp4encfile%.enc}
    openssl enc -d -aes-256-cbc -in $1/$mp4encfile -out $1/$mp4file -pass file:$1/$1.bin
done
# Del all enc files
rm $1/*.enc
