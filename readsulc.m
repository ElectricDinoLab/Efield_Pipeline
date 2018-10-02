function readsulc(subid)
addpath('/Applications/freesurfer/matlab/');

cd(strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',subid,'/ROIanalysis'));
[curv, fnum] = read_curv(strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',subid,'/fs_',subid,'/surf/lh.sulc'));
[vert, face] = read_surf(strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',subid,'/fs_',subid,'/surf/lh.pial'));
Field1.node=vert';
Field1.face=face';
Field1.field=curv';

save -V6 lh_sulc.mat Field1;

