#!/bin/bash


subid=$1
transmat=${subid}_trans.mat

flirt -in ${subid}.nii -ref ch256.nii -out ${subid}_MNI.nii -omat ${transmat} -bins 256 -cost corratio -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12  -interp trilinear
