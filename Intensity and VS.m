clear all, close all, clc

%% Read data 

spectra = zeros(1, 1024);

mainFolder = "....../Disease/2/";
date = "2022-07-28/";
subFolders = {'Score 2'};


[spectra, lambda] = AcquireDataCube(mainFolder, date, subFolders, spectra); 

%% remove zeros & Normalize

spectra(1,:) = [];
[L_c, L_l] = size(spectra);

[min_lam_indx] = find(round(lambda) == 420);
[max_lam_indx] = find(round(lambda) == 480);

for indx = 1:L_c
    max_v = max(New_spectra(indx,:));
    
    Normalized_spectra{indx} = spectra(indx,:) ./ max_v;
    
    Normalized_spectraVis(indx,:) = spectra(indx,:) ./ max_v;
end

%% Get the mean of intensity values around 325 nm region for each spectrum

Intensity = [];

for i = 1:L_c
    
   int = mean(Normalized_spectraVis(i,659:661)) ; % Only 3 values around 325 nm 
   
   intensity= [ intensity, int]; 
end

mean(intensity)
std(intensity)

%% We record the mean and std for each VS and put it in mean_int & std_int matrices

%           8        7       6       5       4       3       2
mean_int=[0.2291,  0.2590, 0.2429, 0.2752, 0.3287, 0.2975, 0.3415];
std_int= [0.0866,  0.1225, 0.1177, 0.1379, 0.1568, 0.1776, 0.1847];
VS = [8,7,6,5,4,3,2];

x_data = VS;
y_data= mean_int;

%% Plot the intesity versus VS 

figure(1)
plot(VS,mean_int,'rx')
errorbar(x_data, y_data, std_int, 'Rx') 
xlim([0 10])
ylim([0 0.6])
xlabel('Visual Scores')
ylabel('Intensity')
title('Mean and standard deviation of Intensity at 325nm')
subtitle('(R^2 = 82%) ')

c = polyfit(VS,mean_int,1);
disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))])
y_est_f_avg = polyval(c,VS);

hold on
plot(VS,y_est_f_avg,'b--','LineWidth',2)
hold off


%% Finding R-squared of the plot above

yresid = y_data - y_est_f_avg;
SSresid = sum(yresid.^2);
SStotal = (length(y_data)-1)*var(y_data);
rsq= 1- (SSresid/SStotal)