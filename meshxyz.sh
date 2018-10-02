#!/bin/bash

## 1st var = subject number

skinloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/m2m_${1}
mkdir /Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/ROIanalysis
outloc=/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/${1}/ROIanalysis
echo $skinloc
echo $outloc
meshloc=/Applications/meshlab.app/Contents/MacOS/meshlabserver


${meshloc} -i ${skinloc}/skin.stl -o ${outloc}/skin.xyz -om vt vn > /dev/null 2>&1

echo Complete