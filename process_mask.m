%% process_mask.m
function process_mask(SUBJID)

mask = load_nii(strcat('../m2m_',SUBJID,'/gm_only.nii.gz'));
%conform = load_nii(strcat(SUBJID,'_T1fs_conform.nii.gz'));

img = uint8(mask.img);
img = flip(img,1);
mask.img = img;
%img = permute(img,[1 2 3]);
%img = flip(img,1);
%img = flip(img,2);
%newmask.img = img;


%newmask.hdr = T1.hdr;
%newmask = make_nii(img,[],T1.hdr.hist.originator(1:3));

save_nii(mask,'mask.nii')
copyfile('mask.nii','../simnibs_sim')
copyfile('mask.nii','../MTsim')
copyfile('mask.nii','../DosingSim')