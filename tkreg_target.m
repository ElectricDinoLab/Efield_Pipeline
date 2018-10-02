%% tkreg_target.m
% moves the target to the tkreg_coordinates from RAS coordinates
function tkreg_target(subid,target)
%subid = 'S200';
%target = [45.2 -31.2 15.12];

brainfile = strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',subid,'/fs_',subid,'/mri/brain.nii');

nii = load_nii(brainfile);

rascorner = [nii.hdr.hist.qoffset_x nii.hdr.hist.qoffset_y nii.hdr.hist.qoffset_z];
ras2tkreg = [128 -128 128] - rascorner;

tkregtarget = target + ras2tkreg;
save('target.mat','tkregtarget');