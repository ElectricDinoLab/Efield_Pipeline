#!/bin/bash

## Preparation
EXPER=WMTMS.01

subjectID=$1
target=$2
simDir=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/
subjDir=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subjectID}
subsimDir=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subjectID}/simulations
subsimOut=/Volumes/Cabeza/WMTMS.01/Analysis/Efield_Sims/${subjectID}/E-field
meshlabLoc=/Applications/meshlab.app/Contents/MacOS/meshlabserver

## Checking if directories exist, making them if not
if [ ! -d $subjDir ]; then
  echo Making Subject Directory.......
  mkdir $subjDir
  echo Complete
fi

if [ ! -d $subsimDir ]; then
  echo Making Subjects Simulation Directory.......
  mkdir $subsimDir
  echo Complete
fi

if [ ! -d $subsimOut ]; then
  echo Making Subjects Output Directory.......
  mkdir $subsimOut
  echo Complete
fi

echo Preparing Simulation
echo Subject is ${subjectID}


