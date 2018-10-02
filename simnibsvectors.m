%% simnibsvectors.m

function simnibsvectors
load('orientations.mat'); % need to clear configurations variable later

simnibs = [datasimnibs{1};
           datasimnibs{2};
           datasimnibs{3};
           datasimnibs{4};
           datasimnibs{5};
           datasimnibs{6};
           datasimnibs{7};
           datasimnibs{8};
           datasimnibs{9};];

       
positions = simnibs(:,1:3);

normals = simnibs(:,4:6);
magnorms = sqrt(normals(:,1).^2 + normals(:,2).^2 + normals(:,3).^2);
magnorms = repmat(magnorms,1,3);
normals = normals./magnorms;

vector1 = simnibs(:,7:9);
magvector1 = sqrt(vector1(:,1).^2 + vector1(:,2).^2 + vector1(:,3).^2);
magvector1 = repmat(magvector1,1,3);
vector1 = vector1./magvector1;

vector2 = cross(vector1,normals,2);
magvector2 = sqrt(vector2(:,1).^2 + vector2(:,2).^2 + vector2(:,3).^2);

           
for k = 1:size(simnibs,1)
    simnibsmat{k} = [-vector2(k,:)' vector1(k,:)' -normals(k,:)' positions(k,:)';
                       0 0 0 1;];
end

save('simulationpositions','simnibsmat');
