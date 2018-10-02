%% TK2nii.m
function voxcoord = TK2nii(tklist,refNII)
%% Instructions


tic

load(tklist);
varnames = fieldnames(efield);
refnii = load_nii(refNII);
origin = refnii.hdr.hist.originator(:,1:3);


for k = 1:numel(varnames);
    if size(varnames{k},2) == 4;
        if varnames{k} == 'aseg';
           field = 5;
        end
    else
        field = 4;
    end
    dummyvar = efield.(sprintf(varnames{k}));
    shift_x = zeros(size(dummyvar,1),size(dummyvar,2));
    shift_x(:,1) = 128;
    flip_x = ones(size(dummyvar,1),size(dummyvar,2));
    flip_x(:,1) = -1;
    shift_y = zeros(size(dummyvar,1),size(dummyvar,2));
    shift_y(:,2) = -128;
    shift_z = zeros(size(dummyvar,1),size(dummyvar,2));
    shift_z(:,3) = 128;
    flip_z = ones(size(dummyvar,1),size(dummyvar,2));
    flip_z(:,3) = -1;

    vox.(sprintf(varnames{k})) = (dummyvar - shift_x - shift_y - shift_z).*flip_x.*flip_z;
    vox.(sprintf(varnames{k})) = [vox.(sprintf(varnames{k}))(:,1) vox.(sprintf(varnames{k}))(:,3) vox.(sprintf(varnames{k}))(:,2) vox.(sprintf(varnames{k}))(:,field)];

end


for k = 1:numel(varnames);
    
    dummyvar2 = vox.(sprintf(varnames{k}));
    dummyvar2 = [dummyvar2(:,1) dummyvar2(:,3) dummyvar2(:,2) dummyvar2(:,4)];
    shift_x = zeros(size(dummyvar2,1),size(dummyvar2,2));
    shift_x(:,1) = 256;
    flip_x = ones(size(dummyvar2,1),size(dummyvar2,2));
    flip_x(:,1) = -1;
    shift_y = zeros(size(dummyvar2,1),size(dummyvar2,2));
    shift_y(:,2) = 1;
    flip_y = ones(size(dummyvar2,1),size(dummyvar2,2));
    flip_y(:,2) = -1;
    shift_z = zeros(size(dummyvar2,1),size(dummyvar2,2));
    shift_z(:,3) = 256;
    flip_z = ones(size(dummyvar2,1),size(dummyvar2,2));
    flip_z(:,3) = -1;

    orient.(sprintf(varnames{k})) = (dummyvar2.*flip_x.*flip_z) + shift_x + shift_z + shift_y;
    
end


for k = 1:numel(varnames);
    
    img.(sprintf(varnames{k})) = zeros(256,256,256);
    for j = 1:size(orient.(sprintf(varnames{k})),1);
        img.(sprintf(varnames{k}))(orient.(sprintf(varnames{k}))(j,1),orient.(sprintf(varnames{k}))(j,2),orient.(sprintf(varnames{k}))(j,3)) = orient.(sprintf(varnames{k}))(j,4);
    end
    nii = make_nii(img.(sprintf(varnames{k})),[],origin);
    save_nii(nii,strcat(varnames{k},'_E.nii'));
    
end

toc
