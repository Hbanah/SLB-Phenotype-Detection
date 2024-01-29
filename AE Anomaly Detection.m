clear all, close all, clc

%% Reading healthy dataset spectra 

spectra_leafcontrol = zeros(1, 1024);

mainFolder = "C:\Users\hbanah\North Carolina State University\Funcrops - General\DeepUVData\MASTER-DIR\crop-samples\control\";
date = "2021-06-18\";
subFolders = {'sample1','sample2','sample3','sample4', 'sample5', 'sample6','sample7', 'sample8', 'sample9','sample10', 'sample11', 'sample12','sample13', 'sample14', 'sample15', ...
    'sample16', 'sample17', 'sample18','sample19', 'sample20', 'sample21','sample22', 'sample23', 'sample24','sample25', 'sample26', 'sample27','sample28', 'sample29', 'sample30', ...
    'sample31', 'sample32', 'sample33','sample34', 'sample35', 'sample36','sample37', 'sample38', 'sample39','sample40'};


[spectra_leafcontrol, lambda] = AcquireDataCube(mainFolder, date, subFolders, spectra_leafcontrol); 
date = "2021-06-19\";

subFolders = {'sample1', 'sample2', 'sample3','sample4', 'sample5', 'sample6','sample7', 'sample8', 'sample9','sample10', 'sample11', 'sample12','sample13', 'sample14', 'sample15', ...
    'sample16', 'sample17', 'sample18','sample19', 'sample20', 'sample21','sample22', 'sample23', 'sample24','sample25', 'sample26', 'sample27','sample28', 'sample29', 'sample30', ...
    'sample31', 'sample32', 'sample33','sample34', 'sample35'};
[spectra_leafcontrol, ~] = AcquireDataCube(mainFolder, date, subFolders, spectra_leafcontrol); 

'Data cubes finished'

%% The first row of both sets of data is all 0's, remove from data 
spectra_leafcontrol(1,:) = [];
[L_c, L_l] = size(spectra_leafcontrol);

%% Normalize the intensity of the data (between 0-1) before training 
%  & assign healthy leaves as (XTrain) for the AE

[min_lam_indx] = find(round(lambda) == 420);
[max_lam_indx] = find(round(lambda) == 480);
 
for indx = 1:L_c
    max_v = max(spectra_leafcontrol(indx,:));
    
    XTrain{indx} = spectra_leafcontrol(indx,:) ./ max_v;
    
    XTrainVis(indx,:) = spectra_leafcontrol(indx,:) ./ max_v;
end

%% Setup autoencoder & train based on healthy leaves (XTrain)


hiddenSize1 = 25;

autoenc = trainAutoencoder(XTrain,hiddenSize1, ...
    'MaxEpochs',100, ...
    'L2WeightRegularization',0,...
    'SparsityRegularization',0,...
    'SparsityProportion',0, ...
    'UseGPU',true);



%% Read SLB-infected samples scores from (2-9). 

spectra_leaffungi = zeros(1, 1024);
mainFolder = "C:\Users\hbanah\North Carolina State University\Funcrops - General\DeepUVData\MASTER-DIR\field-samples\SLB Scores\8\";
subFolders = {'BINNED_UP'};
date = "2022-07-14\";
[spectra_leaffungi, ~] = AcquireDataCube(mainFolder, date, subFolders, spectra_leaffungi);

%% The first row of both sets of data is all 0's, remove from data
spectra_leaffungi(1,:) = [];
[L_f, L_l] = size(spectra_leaffungi);


%% Normalize the intensity of the data (between 0-1) before testing 
%  & assign diseased leaves as (XTest) for the AE

[min_lam_indx] = find(round(lambda) == 420);
[max_lam_indx] = find(round(lambda) == 480);
for indx = 1:L_f
    max_v = max(spectra_leaffungi(indx,:));
    
    XTest{indx} = spectra_leaffungi(indx,:) ./ max_v;
    
    XTestVis(indx,:) = spectra_leaffungi(indx,:) ./ max_v;
end

'Data cubes finished'

%% Predict on test data
clear xReconstructed XReconVis

for indx = 1:L_f
    temp = XTest{indx};
    xReconstructed{indx} = predict(autoenc,temp);
end

for indx = 1:L_f
    XReconVis(indx,:) = xReconstructed{indx};
end

'Data processed'

%% sum of the AE error for the 50 samples between 260-350 nm region

 % Accumlilated error between 260-350 nm for each sample
AccError_SLB_Leaf=[];

for val_f = 1:L_f 

TestData = XTest{val_f};
ReconData = xReconstructed{val_f};
normErr = abs((TestData - ReconData));
normErr(normErr > 1) = 1;


AccError_SLB_Leaf_sum= 0;
AccError_SLB_Leaf_sum= sum(normErr(1:245)); % sum of AE error between 260-350 nm region
           
AccError_SLB_Leaf = [AccError_SLB_Leaf , AccError_SLB_Leaf_sum];

end 


Avg_AccError_SLB_Leaf = mean(AccError_SLB_Leaf);

Std_AccError_SLB_Leaf= std(AccError_SLB_Leaf);

'AccErr Calculated'

%%
              %   8       7        6         5           4       3           2  
AE_Error_mean= [7.4142,  10.3636, 11.1392, 11.9724 , 16.6737,   22.6318,  22.1165];  

AE_Error_std=  [9.1877,  9.9441,  12.3871,  12.4996,   15.9997,  22.3182,  17.5670];

Visual_Score = [8,7,6,5,4,3,2];

x_data = Visual_Score;
y_data= AE_Error_mean;

%% Plot AE error for each score with error bars

figure(1)

plot(Visual_Score,AE_Error_mean,'rx')
errorbar(x_data, y_data, AE_Error_std, 'Rx') 
xlim([0 10])
ylim('auto')
xlabel({'Visual Scores','(a)'})
ylabel('AE Error')
title('Autoencoder Error between 260-350nm')
subtitle(' (R^2 = %) ')

c = polyfit(Visual_Score,AE_Error_mean,1);
disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))])
y_est_f_avg = polyval(c,Visual_Score);

hold on
plot(Visual_Score,y_est_f_avg,'b--','LineWidth',2)
hold off

%% Finding R-squared of the plot above

yresid = y_data - y_est_f_avg;
SSresid = sum(yresid.^2);
SStotal = (length(y_data)-1)*var(y_data);
rsq= 1- (SSresid/SStotal)

%%
%{
%                           Score     Sample#
Ae_fungi=[  6.7957,... %      2         3112
            21.9550,...%      2         11029
            24.1206,...%      2.5       11021
            10.6967,...%      3         11023
            12.6916,...%      3         11535
            12.5335,...%      4         11007
            23.4447,...%      4         11022
            8.4456,... %      4         11025
            8.4440,...%      4.5       6087
            10.4965,...%      5         11036
            16.7721,...%      5         11037
            5.3444,...%      6         3106
            3.6903,...%      6         6085
            13.7217,... %      6         11030
            11.9607,... %      6         11033
            7.6664,... %      6.5       6086
            11.3910,... %      6.5       11034
            7.2730,... %      7         11018
            5.0946,... %      7.5       6076
            4.7529,... %      7.5       6078
            7.5791,... %      7.5       11042
            8.8167,... %      8         6079
            7.4570,... %      8         11020
            3.5492];   %      8.5       3109


Ae_corn=[   8.9766,... %     2         3112
            56.5369,...%      2         11029
            44.3940,...%      2.5       11021
            73.2517,...%      3         11023
            63.4624,...%      3         11535
            22.1338,...%      4         11007
            35.0680,...%      4         11022
            30.0888,... %      4         11025
            16.9862,...%      4.5       6087
            19.4774,...%      5         11036
            25.9618,...%      5         11037
            10.4443,...%      6         3106
            16.7025,...%      6         6085
            34.8265,... %      6         11030
            33.4348,... %      6         11033
            12.3155,... %      6.5       6086
            28.4106,... %      6.5       11034
            13.8344,... %      7         11018
            10.3178,... %      7.5       6076
            18.7149,... %      7.5       6078
            23.1794,... %      7.5       11042
            33.3752,... %      8         6079
            22.4418,... %      8         11020
            12.7038];   %      8.5       3109



%Ae_fungi_mean=[13.4563,14.5207,10.0557,12.2948,7.4874,14.4750,8.6126,6.3443,8.3768,15.0814,11.4045,12.7128,5.1258,7.2030,6.6614];
%Ae_corn_mean=[50.3527,43.3544,68.7691,58.9102,20.9194,33.8964,26.5857,16.0925,22.2026,31.5067,28.1538,26.5174,10.5761,20.0382,19.1783];
%,24.3478
%,2.5
%,67.1267
%%                 2      2.5        3         4        4.5        5         6       6.5       7        7.5       8         8.5
Ae_fungi_mean=[14.3753,  24.1206, 11.6942,  14.8079,  8.4440,  13.6343,   8.6793,  9.5287,   7.2730,  5.8089,   8.1369,  3.5492];
Ae_corn_mean=[32.7568,44.3940,29.0969,16.9862,22.7196,23.8520,20.3631, 13.8344,17.4040,27.9085,12.7038];

V_Score = [2,2,2.5,3,3,4,4,4,4.5,5,5,6,6,6,6,6.5,6.5,7,7.5,7.5,7.5,8,8,8.5];
V_Score_avg = [2,3,4,4.5,5,6,6.5,7,7.5,8,8.5];
V_Score_avg_temp = [2,2.5,4,4.5,5,6,6.5,7,7.5,8,8.5];
%%
figure(1)
plot(V_Score,Ae_fungi,'rx')
xlim([1 9])
ylim([0 30])
xlabel('Visual Scores')
ylabel('AE Error')
title('SUM Error (Around Fungi Peak 260-350nm)')
subtitle('R^2 = 40.2%')

c = polyfit(V_Score,Ae_fungi,1);
disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))])
y_est_f = polyval(c,V_Score);

hold on
plot(V_Score,y_est_f,'b--','LineWidth',2)
hold off
%%


figure(2)
plot(V_Score,Ae_corn,'rx')
xlim([1 9])
ylim([0 70])
xlabel('Visual Scores')
ylabel('AE Error')
title('SUM Error (Around Corn Peak 351-550nm)')
subtitle('R^2 = 35.35%')

c = polyfit(V_Score,Ae_corn,1);
disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))])
y_est_c = polyval(c,V_Score);

hold on
plot(V_Score,y_est_c,'b--','LineWidth',2)
hold off

%%
figure(3)
plot(V_Score_avg,Ae_fungi_mean,'rx')
xlim([1 9])
ylim([0 30])
xlabel('Visual Scores')
ylabel('AE Error')
title('Avg SUM Error (Around Fungi Peak 260-350nm)')
subtitle('R^2 = 67.9%')

c = polyfit(V_Score_avg,Ae_fungi_mean,1);
disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))])
y_est_f_avg = polyval(c,V_Score_avg);

hold on
plot(V_Score_avg,y_est_f_avg,'b--','LineWidth',2)
hold off

%%
figure(4)
plot(V_Score_avg_temp,Ae_corn_mean,'rx')
xlim([1 9])
ylim([0 70])
xlabel('Visual Scores')
ylabel('AE Error')
title('Avg SUM Error (Around Corn Peak 351-550nm)')
subtitle('R^2 = 52.86%')

c = polyfit(V_Score_avg_temp,Ae_corn_mean,1);
disp(['Equation is y = ' num2str(c(1)) '*x + ' num2str(c(2))])
y_est_c_avg = polyval(c,V_Score_avg_temp);

hold on
plot(V_Score_avg_temp,y_est_c_avg,'b--','LineWidth',2)
hold off

%%

mdl_f = fitlm(V_Score,Ae_fungi);
mdl_c = fitlm(V_Score,Ae_corn);

mdl_f_avg = fitlm(V_Score_avg,Ae_fungi_mean);
mdl_c_avg = fitlm(V_Score_avg,Ae_corn_mean);



%% Finding the error bars for each VS
%     min    mean   max
S_2=[ 86.1162, 92.7692, 98.5765];
S_2_pointfive = [ 94.6866, 102.4323, 109.7555];
S_3 =[99.6666, 105.2723, 114.3011];
S_4=[80.0222, 89.5062, 99.1750];
S_4_pointfive= [81.0180, 81.0180, 81.0180];
S_5=[84.5700, 92.0574, 95.2611 ];
S_6=[58.4445, 64.1632, 70.5094];
S_6_pointfive=[56.0924, 59.8650, 67.1855];
S_7=[86.8519, 88.9224, 91.2436];
S_7_pointfive = [25.9644,28.0749,29.8958];
S_8=[39.4703, 44.1177, 48.8274];
S_8_pointfive=[18.3541,18.3541,18.3541];


% Min Max method
x= S_8;
max_interval = ((min(x)+max(x))/2 ) + ((max(x)-min(x))/2);

min_interval = ((min(x)+max(x))/2 ) - ((max(x)-min(x))/2);

d = ((max(x)-min(x))/2) ;
%}