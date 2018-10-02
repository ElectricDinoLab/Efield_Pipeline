%% DosingCalc.m
clear all
a = [252];
b = num2str(a);
names = ['1mm'; '2mm'; '3mm'; '4mm'; '5mm'; '6mm'; '7mm'; '8mm'; '9mm' ];

%% Calculations

for k = 1:numel(a)
    for kk = 1:3
    
        % Startup
        subid = strcat('S',b(k,:));
        cd(strcat('/Users/BSEL/Desktop/WMT+TMS_Subjects/WMTMS_Anat/',subid,'/DosingSim/DosingData/'))
        fprintf(strcat('Running...',subid,'\n'))
        tic; x=100;
        
        % Loading files
        efieldfile = strcat('../',names(kk,:),'_normE.nii.gz');
        zstat = load_nii(strcat('zstat_',subid,'.nii.gz'));
        efield = load_nii(efieldfile);
        efield.img = efield.img;
        parietalmask = load_nii(strcat('parietalmask_',subid,'.nii.gz'));


        % Applying Mask
        ROI = efield.img.*(zstat.img>0).*(parietalmask.img>0);%.*parietalmask.img;.*(efield.img>35);
        maskedefield = efield.img.*(ROI~=0);
        maskedzstat = zstat.img.*(ROI~=0);


        % Calculating statistics
        peakefield(kk) = max(max(max(ROI)));     %Peak efield
        sortede=sort(ROI(:),'descend');
        sortede(isnan(sortede))=[];
        topxe=sortede(1:x);
        top_efield_par(kk) = topxe(x);           % Xth highest efield
        meanX_efield_par(kk) = mean(topxe(1:x)); % mean of the x highest efields
        numerator = sum(sum(sum(maskedefield.*maskedzstat)));
        denominator = sum(sum(sum(maskedzstat)));
        E_cog_par(kk) = numerator/denominator;   % cog approach using zstat



        % Additional Calculations
        evector = ROI(:); evector(evector==0) = []; evector(isnan(evector)) = [];
        zROI = zstat.img.*(ROI~=0);
        zvector = zROI(:); zvector(zvector==0) = []; zvector(isnan(zvector)) = [];

        % Plots
        figure(1); clf;
        histogram(evector); xlabel('Efield Mag'); ylabel('# of Voxels'); axis([0 120 0 300]);
        saveas(figure(1), strcat(subid,'E_parietal.png'))

        figure(2); clf;
        histogram(zvector); xlabel('Z Scores'); ylabel('# of Voxels'); axis([-4 10 0 300]);
        saveas(figure(2), strcat(subid,'Z_parietal.png'))

        copyfile(strcat(subid,'E_parietal.png'),'/Users/BSEL/Desktop/Efieldscaling/Dosing/Subjects/')
        copyfile(strcat(subid,'Z_parietal.png'),'/Users/BSEL/Desktop/Efieldscaling/Dosing/Subjects/')
        toc
    end
end


%% Reformatting data

E_cog_par = E_cog_par';
top_efield_par = top_efield_par';
peakefield = peakefield';
meanX_efield_par = meanX_efield_par';
scalingfactor = 56*ones(numel(top_efield_par),1)./top_efield_par;


