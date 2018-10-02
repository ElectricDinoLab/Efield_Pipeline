function VSmat = normEextractor(normEfile, outfilename, plot)
%% Instructions
% IN GMSH:
%  1. Load the simnibs simulation
%  2. Under post processing, choose the field you need then click the 
%     small arrow to the right
%  3. Select save as
%  4. Click the drop down at the top of the menu to select the mesh based 
%     format
%  5. At the bottom type the name for the file you want to save
%  6. Hit save
 
% Notes
%   The program may need to run multiple times in order to eliminate errors 
%   (approx 4 times).  
%   The data file stores the vector tetrahedrons (volume elements) in
%   matrices VS1, VS2, VS3, VS4, and VS5.  Each matrix has six columns.
%   The first 3 correspond to the x-y-z coordinates of the center of the
%   element and the last 3 correspond to the vector field at that element.

% Written by Wesley Lim, Duke University Class of 2018
% Last Modification: 6/20/2016

%% Prep
tic
fid1 = fopen(normEfile); % replace this with file name
if nargin < 3
    plot = 0;
end
if nargin < 2
    outfilename = 'normE.mat';
end

%% Getting Nodes
for A = 1:4
    fgetl(fid1);
end
NumberNodes = fgetl(fid1);
NumberNodes = str2double(NumberNodes)
Nodechar = textscan(fid1, '%f %f %f %f', 'delimiter',',');
for k = 1:max(size(Nodechar))
    Nodes(:,k) = Nodechar{1,k};
end

%% Getting Elements
% Obtaining Vector Triangles
for A = 1:2
    fgetl(fid1);
end
NumberElements = fgetl(fid1);
NumberElements = str2double(NumberElements)
VTchar = textscan(fid1, '%f 2 2 %f %f %f %f %f', 'delimiter',',');
VSmissingelementnumber = VTchar{1,1}(end);
VTchar{1,1}(end) = [];  % Eliminating first number of next line
for k = 1:numel(VTchar)
    VT(:,k) = VTchar{1,k};
end

% Obtaining Vector Tetrahedrons
VSmissingline = fgetl(fid1);
VSmissing = str2num(VSmissingline);
VSchar = textscan(fid1, '%f 4 2 %f %f %f %f %f %f', 'delimiter',',');

for k = 1:numel(VSchar)
    VSincomplete(:,k) = VSchar{1,k};
end

VS = [VSmissingelementnumber VSmissing(:,3:8);
      VSincomplete];
  
%% Element values
% Skipping lines
a = fgetl(fid1);
while 1
    a = fgetl(fid1);
    if str2double(a) == NumberElements
        break
    end
end

% Obtaining Element Values
NumberValchar = textscan(fid1,'%f %f', 'delimiter',',');
for k = 1:numel(NumberValchar)
    Val(:,k) = NumberValchar{1,k};
end

%clear a A fid k Nodechar NumberValchar tline VSchar VSincomplete VSmissing VSmissingelement VSmissingelementnumber VTchar

%% Reorganization
Val = sortrows(Val,1);
FixedVal = zeros(max(Val(:,1)),2);
FixedVal(Val(:,1),:) = Val(:,:);
%save('stuff.mat', 'NumberValchar', 'Val', 'FixedVal');
% Obtaining surface 1 xyz coord
Masksurf1 = VT(:,3) == 1001;
Masksurf1 = [Masksurf1 Masksurf1 Masksurf1 Masksurf1 Masksurf1 Masksurf1];
VT1 = Masksurf1.*VT;
VT1 = VT1(any(VT1,2),:);
VT1_mat(:,:,1) = Nodes(VT1(:,4),2:4);
VT1_mat(:,:,2) = Nodes(VT1(:,5),2:4);
VT1_mat(:,:,3) = Nodes(VT1(:,6),2:4);
VT1_xyz = mean(VT1_mat,3); % Electric field vector positions
% Obtaining surface 1 values
VT1_matindex = VT1(:,1);
VT1_val = FixedVal(VT1_matindex,2); % Electric field vector directions


% Obtaining surface 2 xyz coord
Masksurf2 = VT(:,3) == 1002;
Masksurf2 = [Masksurf2 Masksurf2 Masksurf2 Masksurf2 Masksurf2 Masksurf2];
VT2 = Masksurf2.*VT;
VT2 = VT2(any(VT2,2),:);
VT2_mat(:,:,1) = Nodes(VT2(:,4),2:4);
VT2_mat(:,:,2) = Nodes(VT2(:,5),2:4);
VT2_mat(:,:,3) = Nodes(VT2(:,6),2:4);
VT2_xyz = mean(VT2_mat,3); % Electric field vector positions
% Obtaining surface 2 values
VT2_matindex = VT2(:,1);
VT2_val = FixedVal(VT2_matindex,2); % Electric field vector directions

% Obtaining surface 3 xyz coord
Masksurf3 = VT(:,3) == 1003;
Masksurf3 = [Masksurf3 Masksurf3 Masksurf3 Masksurf3 Masksurf3 Masksurf3];
VT3 = Masksurf3.*VT;
VT3 = VT3(any(VT3,2),:);
VT3_mat(:,:,1) = Nodes(VT3(:,4),2:4);
VT3_mat(:,:,2) = Nodes(VT3(:,5),2:4);
VT3_mat(:,:,3) = Nodes(VT3(:,6),2:4);
VT3_xyz = mean(VT3_mat,3); % Electric field vector positions
% Obtaining surface 3 values
VT3_matindex = VT3(:,1);
VT3_val = FixedVal(VT3_matindex,2); % Electric field vector directions

% Obtaining surface 4 xyz coord
Masksurf4 = VT(:,3) == 1004;
Masksurf4 = [Masksurf4 Masksurf4 Masksurf4 Masksurf4 Masksurf4 Masksurf4];
VT4 = Masksurf4.*VT;
VT4 = VT4(any(VT4,2),:);
VT4_mat(:,:,1) = Nodes(VT4(:,4),2:4);
VT4_mat(:,:,2) = Nodes(VT4(:,5),2:4);
VT4_mat(:,:,3) = Nodes(VT4(:,6),2:4);
VT4_xyz = mean(VT4_mat,3); % Electric field vector positions
% Obtaining surface 4 values
VT4_matindex = VT4(:,1);
VT4_val = FixedVal(VT4_matindex,2); % Electric field vector directions

% Obtaining surface 5 xyz coord
Masksurf5 = VT(:,3) == 1005;
Masksurf5 = [Masksurf5 Masksurf5 Masksurf5 Masksurf5 Masksurf5 Masksurf5];
VT5 = Masksurf5.*VT;
VT5 = VT5(any(VT5,2),:);
VT5_mat(:,:,1) = Nodes(VT5(:,4),2:4);
VT5_mat(:,:,2) = Nodes(VT5(:,5),2:4);
VT5_mat(:,:,3) = Nodes(VT5(:,6),2:4);
VT5_xyz = mean(VT5_mat,3); % Electric field vector positions
% Obtaining surface 5 values
VT5_matindex = VT5(:,1);
VT5_val = FixedVal(VT5_matindex,2); % Electric field vector directions

clear Masksurf1 Masksurf2 Masksurf3 Masksurf4 Masksurf5 VT1 VT2 VT3 VT4 VT5

% Obtaining volume 1 xyz coord
Maskvol1 = VS(:,3) == 1;
Maskvol1 = [Maskvol1 Maskvol1 Maskvol1 Maskvol1 Maskvol1 Maskvol1 Maskvol1];
VS1 = Maskvol1.*VS;
VS1 = VS1(any(VS1,2),:);
VS1_mat(:,:,1) = Nodes(VS1(:,4),2:4);
VS1_mat(:,:,2) = Nodes(VS1(:,5),2:4);
VS1_mat(:,:,3) = Nodes(VS1(:,6),2:4);
VS1_mat(:,:,4) = Nodes(VS1(:,7),2:4);
VS1_xyz = mean(VS1_mat,3);
% Obtaining volume 1 values
VS1_matindex = VS1(:,1);
VS1_val = FixedVal(VS1_matindex,2);

% Obtaining volume 2 xyz coord
Maskvol2 = VS(:,3) == 2;
Maskvol2 = [Maskvol2 Maskvol2 Maskvol2 Maskvol2 Maskvol2 Maskvol2 Maskvol2];
VS2 = Maskvol2.*VS;
VS2 = VS2(any(VS2,2),:);
VS2_mat(:,:,1) = Nodes(VS2(:,4),2:4);
VS2_mat(:,:,2) = Nodes(VS2(:,5),2:4);
VS2_mat(:,:,3) = Nodes(VS2(:,6),2:4);
VS2_mat(:,:,4) = Nodes(VS2(:,7),2:4);
VS2_xyz = mean(VS2_mat,3);
% Obtaining volume 2 values
VS2_matindex = VS2(:,1);
VS2_val = FixedVal(VS2_matindex,2);

% Obtaining volume 3 xyz coord
Maskvol3 = VS(:,3) == 3;
Maskvol3 = [Maskvol3 Maskvol3 Maskvol3 Maskvol3 Maskvol3 Maskvol3 Maskvol3];
VS3 = Maskvol3.*VS;
VS3 = VS3(any(VS3,2),:);
VS3_mat(:,:,1) = Nodes(VS3(:,4),2:4);
VS3_mat(:,:,2) = Nodes(VS3(:,5),2:4);
VS3_mat(:,:,3) = Nodes(VS3(:,6),2:4);
VS3_mat(:,:,4) = Nodes(VS3(:,7),2:4);
VS3_xyz = mean(VS3_mat,3);
% Obtaining volume 3 values
VS3_matindex = VS3(:,1);
VS3_val = FixedVal(VS3_matindex,2);

% Obtaining volume 4 xyz coord
Maskvol4 = VS(:,3) == 4;
Maskvol4 = [Maskvol4 Maskvol4 Maskvol4 Maskvol4 Maskvol4 Maskvol4 Maskvol4];
VS4 = Maskvol4.*VS;
VS4 = VS4(any(VS4,2),:);
VS4_mat(:,:,1) = Nodes(VS4(:,4),2:4);
VS4_mat(:,:,2) = Nodes(VS4(:,5),2:4);
VS4_mat(:,:,3) = Nodes(VS4(:,6),2:4);
VS4_mat(:,:,4) = Nodes(VS4(:,7),2:4);
VS4_xyz = mean(VS4_mat,3);
% Obtaining volume 4 values
VS4_matindex = VS4(:,1);
VS4_val = FixedVal(VS4_matindex,2);

% Obtaining volume 5 xyz coord
Maskvol5 = VS(:,3) == 5;
Maskvol5 = [Maskvol5 Maskvol5 Maskvol5 Maskvol5 Maskvol5 Maskvol5 Maskvol5];
VS5 = Maskvol5.*VS;
VS5 = VS5(any(VS5,2),:);
VS5_mat(:,:,1) = Nodes(VS5(:,4),2:4);
VS5_mat(:,:,2) = Nodes(VS5(:,5),2:4);
VS5_mat(:,:,3) = Nodes(VS5(:,6),2:4);
VS5_mat(:,:,4) = Nodes(VS5(:,7),2:4);
VS5_xyz = mean(VS5_mat,3);
% Obtaining volume 5 values
VS5_matindex = VS5(:,1);
VS5_val = FixedVal(VS5_matindex,2);

clear Maskvol1 Maskvol2 Maskvol3 Maskvol4 Maskvol5 VS1 VS2 VS3 VS4 VS5
clear VT1_matindex VT2_matindex VT3_matindex VT4_matindex VT5_matindex 
clear VS1_matindex VS2_matindex VS3_matindex VS4_matindex VS5_matindex 
clear ans VS1_mat VS2_mat VS3_mat VS4_mat VS5_mat 
clear VT1_mat VT2_mat VT3_mat VT4_mat VT5_mat

%% Exporting Data
VT1(:,1:3) = VT1_xyz; VT1(:,4) = VT1_val;
VT2(:,1:3) = VT2_xyz; VT2(:,4) = VT2_val;
VT3(:,1:3) = VT3_xyz; VT3(:,4) = VT3_val;
VT4(:,1:3) = VT4_xyz; VT4(:,4) = VT4_val;
VT5(:,1:3) = VT5_xyz; VT5(:,4) = VT5_val;

VS1(:,1:3) = VS1_xyz; VS1(:,4) = VS1_val;
VS2(:,1:3) = VS2_xyz; VS2(:,4) = VS2_val;
VS3(:,1:3) = VS3_xyz; VS3(:,4) = VS3_val;
VS4(:,1:3) = VS4_xyz; VS4(:,4) = VS4_val;
VS5(:,1:3) = VS5_xyz; VS5(:,4) = VS5_val;

save(outfilename, 'VS1', 'VS2', 'VS3', 'VS4', 'VS5'); % optional: rename this


%% Plotting points and surfaces
% Types of views available:
%   Surfaces
%       -Vector Triangles as points (midpoint of the triangle) with
%       electric field vectors
%       -Vector Triangles as surfaces with electric field vectors from the
%       midpoint
%   Volumes
%       -Vector tetrahedrons as points (midpoint of the tetrahedron) with
%       electric field vectors
%       -Vector tetrahedrons as volumes with electric field vectors from
%       the midpoint

if plot == 1
    % Surfaces
    %   Vector Triangles as points
    figure(1); quiver3(VT1_xyz(:,1), VT1_xyz(:,2), VT1_xyz(:,3), VT1_val(:,1), VT1_val(:,2), VT1_val(:,3), 4,'b');
    hold on
    quiver3(VT2_xyz(:,1), VT2_xyz(:,2), VT2_xyz(:,3), VT2_val(:,1), VT2_val(:,2), VT2_val(:,3), 4, 'r');
    quiver3(VT3_xyz(:,1), VT3_xyz(:,2), VT3_xyz(:,3), VT3_val(:,1), VT3_val(:,2), VT3_val(:,3), 4);
    quiver3(VT4_xyz(:,1), VT4_xyz(:,2), VT4_xyz(:,3), VT4_val(:,1), VT4_val(:,2), VT4_val(:,3), 4);
    quiver3(VT5_xyz(:,1), VT5_xyz(:,2), VT5_xyz(:,3), VT5_val(:,1), VT5_val(:,2), VT5_val(:,3), 4);
    hold off

    % Volumes 
    %   Tetrahedrons as points
    figure(2); quiver3(VS1_xyz(:,1), VS1_xyz(:,2), VS1_xyz(:,3), VS1_val(:,1), VS1_val(:,2), VS1_val(:,3), 4,'b');
    hold on
    quiver3(VS2_xyz(:,1), VS2_xyz(:,2), VS2_xyz(:,3), VS2_val(:,1), VS2_val(:,2), VS2_val(:,3), 4, 'r');
    quiver3(VS3_xyz(:,1), VS3_xyz(:,2), VS3_xyz(:,3), VS3_val(:,1), VS3_val(:,2), VS3_val(:,3), 4);
    quiver3(VS4_xyz(:,1), VS4_xyz(:,2), VS4_xyz(:,3), VS4_val(:,1), VS4_val(:,2), VS4_val(:,3), 4);
    quiver3(VS5_xyz(:,1), VS5_xyz(:,2), VS5_xyz(:,3), VS5_val(:,1), VS5_val(:,2), VS5_val(:,3), 4);
    hold off
end

ST = fclose(fid1);

toc
end