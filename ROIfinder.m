function roifieldmat = ROIfinder(efieldmat, roimat)
%% Instructions
% IN MATLAB
%  1. Rename the file name in line 16 and in line 17 to the file name you
%     specified earlier and the roi dataset.
%  2. Rename the exported matrix name in line 33 to whatever you want
%  3. ROI Coordinates should be given in a matrix with 3 columns where each
%     row corresponds to a coordinate and each column represents the x, y
%     or z coordinate
 
% Written by Wesley Lim, Duke University Class of 2018
% Last Modification: 4/21/2016

%% Prep
tic
load(efieldmat);
load(roimat);

%% Grouping data
VS1(:,7) = 1;
VS2(:,7) = 2;
VS3(:,7) = 3;
VS4(:,7) = 4;
VS5(:,7) = 5;
VS = [VS1; VS2; VS3; VS4; VS5];

%% Finding cooresponding elements
[VS_index, d] = dsearchn(VS(:,1:3), roi);
roi_mat = VS(VS_index,:);
roi_mat(:,8) = d;

save('roi_field.mat', 'roi_mat'); % optional: rename this


toc

% The exported file contains columns in the order of:
% Xcoord Ycoord Zcoord Xfield Yfield Zfield MaterialType Distance
% Where distance is distance from the neareset simulation coordinate (mm)

end 