%% Niiflip_hoa


nii = load_nii('hoa_brain.nii.gz');
workingimg = nii.img;

workingimg = permute(workingimg,[1 3 2]);
workingimg = flip(workingimg,1);
workingimg = flip(workingimg,2);


nii.img = workingimg;
save_nii(nii,'hoa_brain_flipped.nii.gz');