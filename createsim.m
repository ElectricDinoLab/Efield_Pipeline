%% Make simnibs struct
function createsim(SUBJID,center,DTI)
%center=[-57.7   38.3   10.3]
load('templatesim.mat') % This will be the base to create new .mats from


fnamehead = strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBJID,'/',SUBJID,'.msh');
pathfem = strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBJID,'/simnibs_sim/');
subpath = strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBJID);
subid = SUBJID;
poslist{1,1}.anisotropy_type = 'scalar';
if DTI == 1;
    fname_dir = strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBJID,'/d2c_',SUBJID,'/CTI_dir_tensor.nii.gz');
    fname_mc = strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBJID,'/d2c_',SUBJID,'/CTI_dir_mc.nii.gz');
    fname_vn = strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBJID,'/d2c_',SUBJID,'/CTI_vn_tensor.nii.gz');
    poslist{1,1}.anisotropy_type = 'vn';
end
    

formgrid(center);
simnibsvectors;

load('simulationpositions.mat')

for k = 1:size(simnibsmat,2)
    poslist{1,1}.pos(k).matsimnibs = simnibsmat{1,k};
end

clear center simnibsmat k ans SUBJID DTI
save(strcat('simulation_',subid))