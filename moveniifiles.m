%% for uploading

folderinfo = dir('*config*');

if ~exist('niifiles')
    mkdir('niifiles')
end

for k = 1:numel(folderinfo);
    if exist(strcat(folderinfo(k).name,'/NIfTI'))
        delete(strcat(folderinfo(k).name,'/NIfTI','/*done*'));
        movefile(strcat(folderinfo(k).name,'/NIfTI','/*E*'),'niifiles');
        rmdir(strcat(folderinfo(k).name,'/NIfTI'));
    end
end