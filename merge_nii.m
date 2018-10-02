%% NIfTI Merge

function merge_nii(mergename, varargin)

for k = 1:numel(varargin);
    nii.(varargin{k}) = load_nii(strcat(varargin{k},'.nii'));
end

dummyimg = zeros(256,256,256);

for k = 1:numel(varargin);
    dummyimg = nii.(varargin{k}).img + dummyimg;
end

dummynii = make_nii(dummyimg);
dummynii.hdr = nii.(varargin{1}).hdr;
save_nii(dummynii,strcat(mergename,'.nii'));