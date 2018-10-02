% Perp E-field Fill
function perpEfill(perpE, E)
load(perpE);
load(E);
tic
[index dist] = knnsearch(VT2(:,1:3),VS2(:,1:3));
assignednormals = VT2_n(index,:);
efields = VS2(:,4:6);
perpE_vol = bsxfun(@times,dot(efields,assignednormals,2),assignednormals);

VT2_vol = [VS2(:,1:3) perpE_vol];
VT2 = [VT2; VT2_vol];
save('adjperpE.mat','VT2')
VS2 = [VS2(:,1:6); VT2_E];
VS1 = VS1(:,1:6);
save('E.mat','VS1','VS2','VS3','VS4','VS5');



toc