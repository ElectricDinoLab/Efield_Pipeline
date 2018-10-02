#!/bin/bash

## 1st var = subject number
## 2nd var = dti (1 = yes, 0 = no)
## 3rd var = tkRAS x coordinates of target
## 4th var = tkRAS y coordinates of target
## 5th var = tkRAS z coordinates of target

skinloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/m2m_${1}
mkdir /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/ROIanalysis
outloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/ROIanalysis
matlab=/Applications/MATLAB_R2016a.app/bin/matlab
echo $skinloc
echo $outloc
meshloc=/Applications/meshlab.app/Contents/MacOS/meshlabserver


${meshloc} -i ${skinloc}/skin.stl -o ${outloc}/skin.xyz -om vt vn > /dev/null 2>&1

echo Finished making skin.xyz...
echo Creating position list...

${matlab} -nojvm -r "createsim([${3} ${4} ${5}],${2});quit" > /dev/null 2>&1

