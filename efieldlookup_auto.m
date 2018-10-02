%% efieldlookup_auto.m
function sample = efieldlookup_auto(field,aseg,ROIlist,savetype)

% The prompt asks if a matrix containing the voxel position lists for the
% brain is present within the .mat file containing the ROIs needing to be
% sampled. Answer 1 (yes) or 0 (no) to the prompt.

% This function assumes the field .mat file has variables VS1 and VS2
% corresponding to the white and gray matter respectively.
% The segment .mat file should contain any ROIs in tkreg_RAS space.
% The function output is a .mat file containing two structures: a structure

% containing efield values sampled at the tkreg_RAS space, and a structure
% containing the distances of each of those points from the efield
% tetrahedron.

% prompt = 'Enter a matrix of ROIs based on the Freesurfer Lookup Table or 0 for the whole brain:  ';
% answer = input(prompt);
answer = ROIlist;
tStart = tic;
load(field);
load(aseg);
load('lookuptable.mat');
if find(field == 'p');
    VT2 = [VT2 ones(size(VT2,1),1).*2];
    VS = [VT2];
else
    VS1 = [VS1 ones(size(VS1,1),1)];
    VS2 = [VS2 ones(size(VS2,1),1).*2];
    VS = [VS1; VS2];
end
    
for k = 1:numel(answer);
    
   if answer(k) ~= 0;
       mask = (aparcaseg(:,4) == answer(k));
       mask = [mask mask mask mask];
       dummyvar = aparcaseg.*mask;
       dummyvar(~any(dummyvar,2),:) = [];
       [index.(tablestr{find(tableindex==answer(k))}), d.(tablestr{find(tableindex==answer(k))})] = knnsearch(VS(:,1:3), dummyvar(:,1:3));
       e_dummyvar = VS(index.(tablestr{find(tableindex==answer(k))}),:);
       e_dummyvar(:,1:3) = [];
       efield.(tablestr{find(tableindex==answer(k))}) = [dummyvar(:,1:3) e_dummyvar];
   end
   if answer(k) == 0;
       [index.aseg, d.aseg] = knnsearch(VS(:,1:3), aparcaseg(:,1:3));
       e_dummyvar = VS(index.aseg,:);
       e_dummyvar(:,1:3) = [];
       efield.aseg = [aparcaseg e_dummyvar];
   end
   
end 

% Distance processing for perpE
if find(field == 'p');
    names = fieldnames(d);
    for k = 1:numel(names);
        mask = (d.(names{k})<=1.3);
        mask2 = [mask mask mask mask mask mask mask];
        d.(names{k}) = d.(names{k}).*mask;
        d.(names{k})(~any(d.(names{k}),2)) = [];
        efield.(names{k}) = efield.(names{k}).*mask2;
        efield.(names{k})(~any(efield.(names{k}),2),:) = [];
    end
end
    

save(savetype,'efield','d');
tEnd = toc(tStart);
fprintf('Elapsed time is %d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));