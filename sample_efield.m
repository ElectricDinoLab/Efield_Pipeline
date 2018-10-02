%% Sample_efield.m
function sample = sample_efield(field,ROIs)

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

prompt = 'Is the brain in the ROI.mat file? (1 = yes, 0 = no)';
answer = input(prompt);
tStart = tic;
load(field);
parc = load(ROIs);
varnames = fieldnames(parc);
brainthresh = 12;

if answer == 1;
    brainmask = (parc.brain(:,4) > brainthresh);
    brainmask = [brainmask brainmask brainmask brainmask];
    parc.brain = parc.brain.*brainmask;
    parc.brain(~any(parc.brain,2),:) = [];
end
VS1 = [VS1 ones(size(VS1,1),1)];
VS2 = [VS2 ones(size(VS2,1),1).*2];
VS = [VS1; VS2];

for k = 1:numel(varnames);
    
   [index.(sprintf(varnames{k})), d.(sprintf(varnames{k}))] = knnsearch(VS(:,1:3), parc.(sprintf(varnames{k}))(:,1:3));
   dummyvar = VS(index.(sprintf(varnames{k})),:);
   dummyvar(:,1:3) = [];
   efield.(sprintf(varnames{k})) = [parc.(sprintf(varnames{k}))(:,1:3) dummyvar];
    
end 


save('efield_test.mat','efield','d');
tEnd = toc(tStart);
fprintf('%d minutes and %f seconds\n',floor(tEnd/60),rem(tEnd,60));