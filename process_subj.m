%% Efield processing
function process_subj(SubjectID, ROI_list)
% Instructions: 
%   1. Navigate to the subject directory within the file browser
%   2. Make a folder named ROIanalysis
%   3. In GMSH:
%       a. Open the simnibs_sim folder for the subject and open the file 
%          ending in "_merge.msh" in gmsh and go to the field and select 
%          the arrow to the right of the fields and download the files as 
%          the mesh-based .pos file.
%       b. Name the files "normE" and "E" for their respective fields
%       c. Obtain the normE-field and E-field files from the gmsh and place
%          them in this folder.
%   4. In ImageJ: 
%       a. Convert the aparc+aseg.mgz to aparcaseg.nii with terminal:
%           i. mri_convert aparc+aseg.mgz aparcaseg.nii
%       b. Open up the aparcaseg.nii in the S#/fs_S#/mri folder in ImageJ
%       c. Select Analyze>tools>save xy coord
%           i. Use the invert y-axis and process all 256 images options
%           ii. Save as aparcaseg.txt
%   5. Navigate to the subject directory within MATLAB then to the
%      ROIanalysis folder
%   6. Run this function 
 
if nargin < 2;
    ROI_list = 0;
end
Time1 = tic;
%% extracting the E-field:
disp('Extracting E-field..............')
efieldextractor('E');
% disp('Extracting NormE..............')
% normEextractor('normE');

%% Converting Voxels to TKreg_RAS space 
disp('Converting Voxels.............')
aparcaseg = voxel2TK('aparcaseg.txt');
save('aparcaseg_TKlist.mat','aparcaseg');

%% Looking up E-field regions
% normE
% disp('Searching normE for ROI.............')
% efieldlookup_auto('normE.mat','aparcaseg_TKlist.mat',ROI_list,'aparcaseg_normE.mat');
% E-field
disp('Searching E-field for ROI................')
efieldlookup_auto('E.mat','aparcaseg_TKlist.mat',ROI_list,'aparcaseg_E.mat');
E2normE('aparcaseg_E.mat','aparcaseg_normE.mat');

%% Conversion to NIfTI format
mkdir('NIfTI');
cd('NIfTI');
disp('Creating NIfTI files................')
TK2nii('../aparcaseg_normE.mat',strcat('../../fs_',SubjectID,'/mri/aparcaseg.nii'));
disp('Done.')
tend = toc(Time1);
fprintf('Total Elapsed time is %d hours %d minutes and %f seconds\n',floor(tend/3600),floor(rem(tend,3600)/60),rem(rem(tend,3600),60));
