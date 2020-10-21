#!/bin/bash
ssh-keygen -t rsa -b 4096 -m PEM
openssl rsa -in id_rsa -outform pem > id_rsa.pem
openssl rsa -in id_rsa -pubout -outform pem > id_rsa.pub.pem
mkdir -p ship
cp id_rsa.pub.pem ship/id_rsa.pub.pem
