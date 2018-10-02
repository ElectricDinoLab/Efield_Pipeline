function m = mesh_extract_planes(m,n1,k1,n2,k2, varargin)
% extracts the part of the mesh between two planes, m = mesh, n1,k1,n2,k2
% are the paramters from Gmsh n1 is a [3x1] vector, k1 is the distance
% Alexander Opitz

if nargin > 5
    inverse = logical(varargin{1});
else
    inverse = false;
end

ind1 = sum(repmat(n1,size(m.points,1),1).* m.points,2)+k1 < 0;
ind2 = sum(repmat(n2,size(m.points,1),1).* m.points,2)+k2 > 0;
ind = (ind1 - ind2);

if inverse
   m = mesh_extract_points(m,~logical(ind)); 
else
   m = mesh_extract_points(m,logical(ind));
end