#!/bin/bash



#tar -zcvf archive-name.tar.gz directory-name


for i in *
	do
		echo tar -zcvf "${i}.tar.gz" "${i}"
		tar -zcvf "${i}.tar.gz" "${i}"
	done	