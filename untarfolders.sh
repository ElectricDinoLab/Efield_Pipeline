#!/bin/bash



#tar -zcvf archive-name.tar.gz directory-name


for i in *tar.gz
	do
		echo tar -zxvf "${i}"
		tar -zxvf "${i}"
	done	