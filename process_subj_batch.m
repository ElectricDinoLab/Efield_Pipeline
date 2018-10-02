%% Efield processing
function process_subj_batch(SubjectID, ROI_list)
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
if exist('config_E-1-1','dir')~=7;
    fileinfo = dir('*E-*');
    for k = 1:size(fileinfo,1);
        mkdir(strcat('config_',fileinfo(k).name));
        movefile(fileinfo(k).name,strcat('config_',fileinfo(k).name,'/',fileinfo(k).name));
        copyfile('aparcaseg.txt',strcat('config_',fileinfo(k).name,'/','aparcaseg.txt'));
    end
end

folderinfo = dir('*config*');

for k = 1:size(folderinfo,1);
    %% Setup
    cd(folderinfo(k).name)
    fieldinfo = dir('*E-*');
    disp(['Processing: ' folderinfo(k).name])
        %% extracting the E-field: 30 sec
        if ~exist('E.mat')
            disp('Extracting E-field..............')
            efieldextractor(fieldinfo.name);
        else
            disp('E-field already extracted...')
        end
        %% Adjusting PerpE: 10 sec
        if ~exist('adjperpE.mat')
            disp('Interpolating perpE for volume elements')
            perpEfill('perpE.mat','E.mat');
        else
            disp('perpE for vol elements already calculated....')
        end
        %% Converting Voxels to TKreg_RAS space: 1 sec
        if ~exist('aparcaseg_TKlist.mat')
            disp('Converting Voxels.............')
            aparcaseg = voxel2TK('aparcaseg.txt');
            save('aparcaseg_TKlist.mat','aparcaseg');
        else
            disp('Voxels already converted...')
        end
        %% Looking up E-field regions
        % Efield: 5 min
        if ~exist('aparcaseg_E.mat')
            disp('Searching E-field for ROI................')
            efieldlookup_auto('E.mat','aparcaseg_TKlist.mat',ROI_list,'aparcaseg_E.mat');
        else
            disp('E-field already searched...')
        end
        % Perpendicular Efield: 3 min
        if ~exist('aparcaseg_perpE.mat')
            disp('Searching perpE-field for ROI................')
            efieldlookup_auto('adjperpE.mat','aparcaseg_TKlist.mat',ROI_list,'aparcaseg_perpE.mat');
        else
            disp('perpE-field already searched...')
        end
        % Converting E-fields to magnitudes
        % Efield
        if ~exist('aparcaseg_normE.mat')
            disp('Converting E to normE')
            E2normE('aparcaseg_E.mat','aparcaseg_normE.mat');
        else
            disp('E-field converted previously...')
        end
        % Perpendicular Efield
        if ~exist('aparcaseg_magperpE.mat')
            disp('Converting perpE to magperpE')
            E2normE('aparcaseg_perpE.mat','aparcaseg_magperpE.mat');
        else
            disp('perpE-field converted previously...')
        end
        %% Conversion to NIfTI format
        if ~exist('NIfTI')
            mkdir('NIfTI');
        end
        cd('NIfTI');
        if ~exist('Edone.mat')
            disp('Creating NIfTI files for E-field ............')
            TK2nii_batch('../aparcaseg_normE.mat',strcat('../../../fs_',SubjectID,'/mri/aparcaseg.nii'),strcat(folderinfo(k).name(8:end),'.nii'),'Edone');
            %disp('Consolidating NIfTI files for E-field.............')
            %merge_nii_all(folderinfo(k).name(8:end),'Edone');
        end
        if ~exist('perpEdone.mat')
            disp('Creating NIfTI files for perpE-field ........')
            TK2nii_batch('../aparcaseg_magperpE.mat',strcat('../../../fs_',SubjectID,'/mri/aparcaseg.nii'),strcat('perp',folderinfo(k).name(8:end),'.nii'),'perpEdone');
            %disp('Consolidating NIfTI files for perpE-field.........')
            %merge_nii_all(strcat('perp',folderinfo(k).name(8:end)),'perpEdone');
        end
        disp([folderinfo(k).name ' Complete.'])
        tend = toc(Time1);
        fprintf('Total Elapsed time is %d hours %d minutes and %f seconds\n \n',floor(tend/3600),floor(rem(tend,3600)/60),rem(rem(tend,3600),60));
    %% Reset
    cd('../../')
end 
% disp('Merging NIfTI files')
% merge_nii_batch;
%tend = toc(Time1);
%        fprintf('Total Elapsed time is %d hours %d minutes and %f seconds\n \n',floor(tend/3600),floor(rem(tend,3600)/60),rem(rem(tend,3600),60));