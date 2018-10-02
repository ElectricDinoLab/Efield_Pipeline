%% DosingCalc.m
clear all
a = [250];
b = num2str(a);
names = dir('*normE*');
subid = 'S213';

%% Calculations

for k = 1:9
    for kk = 1:6
    
        % Startup
        
        fprintf(strcat('Running...',strcat('E-',num2str(k),'-',num2str(kk),'_normE.nii.gz'),'\n'))
        tic; x=100;
        
        % Loading files
        efieldfile = strcat('E-',num2str(k),'-',num2str(kk),'_normE.nii.gz');
        zstat = load_nii(strcat('zstat_',subid,'.nii.gz'));
        efield = load_nii(efieldfile);
        efield.img = efield.img;
        parietalmask = load_nii(strcat('parietalmask_',subid,'.nii.gz'));


        % Applying Mask
        ROI = efield.img.*(zstat.img>0).*(parietalmask.img>0);%.*parietalmask.img;.*(efield.img>35);
        maskedefield = efield.img.*(ROI~=0);
        maskedzstat = zstat.img.*(ROI~=0);


        % Calculating statistics
        peakefield(k,kk) = max(max(max(ROI)));     %Peak efield
        sortede=sort(ROI(:),'descend');
        sortede(isnan(sortede))=[];
        topxe=sortede(1:x);
        top_efield_par(k,kk) = topxe(x);           % Xth highest efield
        meanX_efield_par(k,kk) = mean(topxe(1:x)); % mean of the x highest efields
        numerator = sum(sum(sum(maskedefield.*maskedzstat)));
        denominator = sum(sum(sum(maskedzstat)));
        E_cog_par(k,kk) = numerator/denominator;   % cog approach using zstat



        % Additional Calculations
        evector = ROI(:); evector(evector==0) = []; evector(isnan(evector)) = [];
        zROI = zstat.img.*(ROI~=0);
        zvector = zROI(:); zvector(zvector==0) = []; zvector(isnan(zvector)) = [];

        % Plots
        %figure(1); clf;
        %histogram(evector); xlabel('Efield Mag'); ylabel('# of Voxels'); axis([0 1.20 0 300]);
        %saveas(figure(1), strcat(subid,'E_parietal.png'))

        %figure(2); clf;
        %histogram(zvector); xlabel('Z Scores'); ylabel('# of Voxels'); axis([-4 10 0 300]);
        %saveas(figure(2), strcat(subid,'Z_parietal.png'))

        %copyfile(strcat(subid,'E_parietal.png'),'/Users/BSEL/Desktop/Efieldscaling/Dosing/Subjects/')
        %copyfile(strcat(subid,'Z_parietal.png'),'/Users/BSEL/Desktop/Efieldscaling/Dosing/Subjects/')
        toc
    end
end


%% Reformatting data

E_cog_par = E_cog_par';
top_efield_par = top_efield_par';
peakefield = peakefield';
meanX_efield_par = meanX_efield_par';
scalingfactor = 56*ones(size(top_efield_par))./top_efield_par;

figure(1); clf;
imagesc(scalingfactor)
colorbar
xlabel('Position'); ylabel('Orientation');
good = scalingfactor<81.36;
figure(2); clf; imagesc(good); colorbar; xlabel('Position'); ylabel('Orientation');

