%% sulcwall.m
function sulcwall(SUBID,target, hairdepth)
%clear all
addpath('/Users/BSEL/Documents/MATLAB');
%% loading gm and skin
% SUBID='S258';
% target = [-37.89 -62.47 18.69];
% hairdepth = 1.3; 
testpoint = target;
hairmax = ceil(hairdepth) + 1.5; numdist = hairmax*2 + 1;

%GM = load(strcat('~/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBID,'/ROIanalysis/gm.xyz'));
skin = load(strcat('~/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBID,'/ROIanalysis/skin.xyz'));
%[v, f, n, name] = stlRead(strcat('~/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBID,'/m2m_',SUBID,'/skin.stl'));

%skin.node=v';
%skin.face=f';
%skin.field=n';
clear v f n name;
load(strcat('~/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',SUBID,'/ROIanalysis/lh_sulc.mat'));
GM=Field1.node';
GM_faces=Field1.face'+1;
GM_curv=Field1.field';
%% Calculate target point and orientation point
[testpoint_ind dist] = knnsearch(GM(:,1:3),testpoint);
testpoint_gm = GM(testpoint_ind,1:3);
wall = Field1.field.*(Field1.field>-0.05 & Field1.field<0.05);
wall_ind = find(wall);
wall_nodes = Field1.node(:,wall_ind)';
% set sulc nodes
[ind dist] = knnsearch(wall_nodes,testpoint_gm,'K',5);
sulc_nodes = wall_nodes(ind,:);
% get their faces
[a b c]=intersect(GM,sulc_nodes,'rows','stable');
f1=ismember(GM_faces(:,1),b); f2=ismember(GM_faces(:,2),b);f3=ismember(GM_faces(:,3),b);
f=f1+f2+f3; clear f1 f2 f3; f=find(f>0);
Field = clean_tri_mesh(GM,GM_faces(f,:),1:length(GM));
FV.vertices=Field.node';
FV.faces=Field.face';
[FV, fixedFaces] = unifyMeshNormals(FV,'alignTo','out');
Field.face=FV.faces';
Field.node=FV.vertices';
Field.field=trinormal(FV.faces,FV.vertices);

% get sulc GM normal and average for angle 
sulc_norm = Field.field;
avg_norm = mean(sulc_norm); 
unitnorm = avg_norm./norm(avg_norm);

% get skin location, skin normals are outwards
% sp=skin.node(1:3,:)';
% sn=skin.field(1:3,:)';
% sf=skin.face(1:3,:)';
% an=zeros(length(sp),1);
% sp(:,1)=sp(:,1)-testpoint(1);
% sp(:,2)=sp(:,2)-testpoint(2);
% sp(:,3)=sp(:,3)-testpoint(3);
% 
% for i=1:length(sn)
%   a1=sp(sf(i,1),:)/norm(sp(sf(i,1),:));
%   a2=sp(sf(i,2),:)/norm(sp(sf(i,2),:));
%   a3=sp(sf(i,3),:)/norm(sp(sf(i,3),:));
%   a=mean([a1; a2; a3]);
%   b=sn(i,:);
%   an(i)=real(acosd(a*b')/(norm(a)*norm(b)));
% end
% skinloc_ind=find(an==min(an));
% sp=skin.node(1:3,:)';
% tmp=[sp(sf(skinloc_ind,1),:);
% sp(sf(skinloc_ind,2),:);
% sp(sf(skinloc_ind,3),:)];
% skinloc=tmp;

%or as an alternative Wesley's way
[skinloc_ind dist] = knnsearch(skin(:,1:3),testpoint);
skinloc = skin(skinloc_ind,:);

% calculate target point (in air)
newpoint = testpoint + 20*unitnorm;

%% Calculate target matrix
% obtain skin tangent plane

center = testpoint;
[index d] = knnsearch(skin(:,1:3),center);
normal = skin(index,:);
center = skin(index,1:3); % Sets the skin surface to the new center of the coil
a = normal(4); b = normal(5); c = normal(6);
D = a*center(1) + b*center(2) + c*center(3);

% Creating the tangent plane vectors
flatpos1 = center + [10 0 0];
z1 = (D-a*flatpos1(1)-b*flatpos1(2))/c;
vector1 = [flatpos1(1:2) z1] - center;
magv1 = sqrt(sum(vector1.^2,2));
normalvec = normal(4:6);
magnormvec = sqrt(sum(normalvec.^2,2));
vector1 = vector1/magv1;
normalvec = normalvec/magnormvec;
vector2 = cross(normalvec,vector1);



% Creating defining vector matrix defining plane
definematrix = [vector1; vector2; normalvec;];

% Create target position matrix 
dirpos1z = (D-a*newpoint(1)-b*newpoint(2))/c;
dirpos1 = [newpoint(1) newpoint(2) dirpos1z];
dirvector1 = unitnorm;
dirvectorprojnorm = (dot(dirvector1,normalvec)/norm(normalvec))*normalvec;
dirvectorplane = dirvector1 - dirvectorprojnorm;

% for testing
flatpos2 = center - [0 10 0];
z2 = (D-a*flatpos2(1)-b*flatpos2(2))/c;
apvec = [flatpos2(1:2) z2] - center;
dirvec = dirvectorplane;
angle_plane = atan2d(norm(cross(apvec,dirvec)),dot(apvec,dirvec));

% Create distances
for k = 1:numdist
    dist(k) = 0 + .5*(k-1);
end
for k = 1:numdist
    coilpos(k,:) = center + dist(k)*normalvec;
end

for k = 1:1
    dummyvec1 = dirpos1 - coilpos(k,:);
    dummyvec1 = dirvectorplane;
    dirvec1(k,:) = dummyvec1./norm(dummyvec1);
    dummyvec2 = cross(dirvec1(k,:),normalvec,2);
    magvector2 = sqrt(dummyvec2(:,1).^2 + dummyvec2(:,2).^2 + dummyvec2(:,3).^2);
    dirvec2(k,:) = dummyvec2./magvector2;
end


for k = 1:numdist
    simnibsmat{k} = [-dirvec2(1,:)' dirvec1(1,:)' -normalvec' coilpos(k,:)';
                    0 0 0 1;];
end


for k = 1:1
    dummyvar = coilpos(k,:) + 20*dirvec1(k,:);
    testmatrix(k,:) = [coilpos(k,:) dummyvar];
end

dummyvarrrr = [target newpoint];
save('simulationpositions','simnibsmat');

writematrix = [angle_plane];
dlmwrite('angle.txt',writematrix);
dlmwrite('testtarget.txt',testmatrix);

dlmwrite('testtarget2.txt',dummyvarrrr);
%save('test','target','center','unitnorm','newpoint','coilpos')





