%% merge_nii_all_batch.m
% Just a simple script to merge the NIfTI files of each parameter
% arrangement into one file.

folderinfo = dir('*config*');

for k = 1:numel(folderinfo);
    cd(strcat(folderinfo(k).name,'/NIfTI'))
    merge_nii_all(folderinfo(k).name(8:end));
    cd('../../')
end
