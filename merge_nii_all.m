%% merge_nii_all 

function merge_nii_all(mergename,donecheckname)
tic
fileinfo = dir('*E.nii*');


for k = 1:numel(fileinfo);
    nii.(fileinfo(k).name(1:end-4)) = load_nii(fileinfo(k).name);
end

dummyimg = zeros(256,256,256);

for k = 1:numel(fileinfo);
    dummyimg = nii.(fileinfo(k).name(1:end-4)).img + dummyimg;
end

dummynii = make_nii(dummyimg);
dummynii.hdr = nii.(fileinfo(1).name(1:end-4)).hdr;
save_nii(dummynii,strcat(mergename,'.nii')); 
delete('*ctx*');
a = 1;
save(donecheckname,'a')
toc