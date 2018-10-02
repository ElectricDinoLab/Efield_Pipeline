function ROImat = labelextractor(labelfile)
%% Instructions
% IN MATLAB
%  1. Rename the file name in line 16 to the label file.
%  2. Rename the exported matrix name in line 33 to whatever you want.
%     Default is "ROI.mat"
%  3. ROI Coordinates should be given in a matrix with 3 columns where each
%     row corresponds to a coordinate and each column represents the x, y
%     or z coordinate
 
% Written by Wesley Lim, Duke University Class of 2018
% Last Modification: 5/26/2016

%% Loading Label File
tic
fid = fopen(labelfile); % replace this with file name

% Getting Coordinates
for A = 1:2
    fgetl(fid);
end

Voxchar = textscan(fid, '%f %f %f %f %f', 'delimiter',',');
for k = 1:max(size(Voxchar))
    roifull(:,k) = Voxchar{1,k};
end

roi = roifull(:,2:4);
save('roi.mat', 'roi'); % Optional: change .mat file name
toc
end