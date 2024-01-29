clear all, close all, clc

%% Assign variables for the healthy, D0, and D3 PQ treatments

spectra_corn_H = zeros(1, 1024);
spectra_corn_H_mean=[];

spectra_corn_D0 = zeros(1, 1024);
spectra_corn_D0_mean=[];

spectra_corn_D3 = zeros(1, 1024);
spectra_corn_D3_mean=[];

x=[];

%% Read Healthy, D0, and D3 data

%H 
mainFolder = "C:\Users\hbanah\North Carolina State University\Funcrops - General\DeepUVData\MASTER-DIR\crop-samples\Corn_PQ\";
date = "2023-03-27\";
subFolders = {'H'};
[spectra_corn_H, lambda] = AcquireDataCube(mainFolder, date, subFolders(1), spectra_corn_H); 

%D0 
subFolders = {'D0'};
[spectra_corn_D0, ~] = AcquireDataCube(mainFolder, date, subFolders(1), spectra_corn_D0); 

%D3
date = "2023-03-30\";
subFolders = {'D3'};
[spectra_corn_D3, ~] = AcquireDataCube(mainFolder, date, subFolders(1), spectra_corn_D3); 

%% Remove 0's, get the mean, and normalize the spectra

%H
spectra_corn_H(1,:) = [];
spectra_corn_H_mean(1,:) = mean(spectra_corn_H);
spectra_corn_H_mean(1,:) = spectra_corn_H_mean(1,:) / max(spectra_corn_H_mean(1,:));


%D0
spectra_corn_D0(1,:) = [];
spectra_corn_D0_mean(1,:) = mean(spectra_corn_D0);
spectra_corn_D0_mean(1,:) = spectra_corn_D0_mean(1,:) / max(spectra_corn_D0_mean(1,:));


%D3
spectra_corn_D3(1,:) = [];
spectra_corn_D3_mean(1,:) = mean(spectra_corn_D3);
spectra_corn_D3_mean(1,:) = spectra_corn_D3_mean(1,:) / max(spectra_corn_D3_mean(1,:));

%% Plot the PQ treated and healthy spectra

figure(1)
plot(lambda,spectra_corn_H_mean(:,:)) %H
hold on
plot(lambda,spectra_corn_D0_mean(:,:)) %D0
hold on 
plot(lambda,spectra_corn_D3_mean(:,:)) %D3

legend('Healthy','Day 0 ', 'Day 3 ')
title('Paraquat Effect on Corn Leaves Spectra')
xlabel({'Wavelength (nm)','(a)'})
ylabel('Intensity (AU)')

%% Box plot for the paraquat treatment versus time

x(1,:) = spectra_corn_H_mean(:,:);
x(2,:) = spectra_corn_D0_mean(:,:);
x(3,:) = spectra_corn_D3_mean(:,:);

x_plot = x(1:3,224:281).'; % 224:281 represent the values around 325 nm region
boxchart(x_plot);
title('325nm/450nm fluorescence emission ratio')
xlabel({'Category','(b)'})
ylabel('Intensity (AU)')
ylim([0.1 0.3])