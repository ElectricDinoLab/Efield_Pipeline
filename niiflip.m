%% Nii flip
% flips nii img.

nii = load_nii('hk.nii');
workingimg = nii.img;

workingimg = permute(workingimg,[1 3 2]);
workingimg = flip(workingimg,1);
workingimg = flip(workingimg,2);


nii.img = workingimg;
save_nii(nii,'hk_adj.nii');