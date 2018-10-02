%% E2normE.m

function E2normE(Efield,outfilename)
tic 
load(Efield);
varnames = fieldnames(efield);

for k = 1:numel(varnames)
    dummyvar = efield.(varnames{k});
    dummyvar2 = dummyvar(:,1:3);
    dummyvar3 = sqrt(sum(abs(dummyvar(:,4:6)).^2,2));
    dummyvar4 = dummyvar(:,7);
    efield.(varnames{k}) = [dummyvar2 dummyvar3];
end

save(outfilename,'efield','d');