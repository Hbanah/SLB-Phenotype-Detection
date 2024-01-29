# SLB-Phenotype-Detection
Detection of SLB caused by fungal disease in corn plants using fluorescence spectroscopy and autoencoder (AE) anomaly detection techniques
Before we explain the project it is important to be familiar with Autoencoders here:

https://towardsdatascience.com/anomaly-detection-using-autoencoders-5b032178a1ea
https://towardsdatascience.com/anomaly-detection-with-autoencoder-b4cdce4866a6 


*********************************************************************************************************************************************************************************

In this project, we train the AE using the healthy leaf spectrum found in the file ("Healthy"). 
This consists of 75 samples of the fluorescence emission spectrum of healthy corn plants.
Each sample consists of 8 measurements to give a total of 600 mission spectrum for training, this will serve as a control dataset (XTrain). 

We test the AE on the diseased samples given by our ground-truth data the Visual Scores (VS) and can be found in the ("Disease") file.
The VS consists of 7 scores from (2-8) representing the disease severity where 8 means a highly resistant leaf and 2 a nearly dead leaf. 
The scores have an unequal sample size (different numbers of fluorescence emission spectra), this will serve as a disease dataset (XTest).

**The code can be improved to be less hard-coded, and we are working on that to facilitate reuse and reproducibility.**

*********************************************************************************************************************************************************************************

"AcquireDataCube" 

This code is used to read the spectra from the files. 

*[spectraInput, lambda] = AcquireDataCube(mainFolder, date, subFolders, spectraInput)*

Here, *spectraInput* is the fluorescence emission spectra. 
      *lambda* is the wavelength axis (1,1024) from 250 - 600 nm. 
      *mainFolder* is the location of the healthy and disease files (should be modified based on the user's location of the files). 
      *date* we mentioned that different samples have different dates so specify the date. 
      *subFolders* is the subfolder location of the files. 

**note** The code reads the file in this order: "mainFolder" + "date" + "subFolders" + "date"

Then it reads the "spectraInput" given as ".brane" files. 

**note** the AcquireDataCube code needs to be in the same location as AE Anomaly Detection code to work. 

*********************************************************************************************************************************************************************************

"AE Anomaly Detection" 

This is the main code we used to get the linear inverse relationship between the VS and the AE error shown in Figure 12. 
The AE error was generated from the absolute difference between the AE reconstructed spectrum and XTest. 
The code is divided into 12 blocks. 

1- In the first block, we read the healthy dataset of corn emission spectra and assigned it to "spectra_leafcontrol"
2- Then, we remove all the 0's from the first row of the matrix spectra_leafcontrol. 
3- Then, we normalize the spectra_leafcontrol matrix to the maximum peak of corn leaf at ~450 nm and assign it to XTrain for AE training. 
4- Then, we train the autoencoder using "trainAutoencoder" MATLAB built-in function. 
5- The 5th block, we read each SLB score *Manually* since each score has a different date and assign that to "spectra_leaffungi".
6- Then we remove the zeros from the spectra_leaffungi matrix. 
7- Normalize the spectra_leaffungi spectra and assign it to XTest for AE evaluation.
8- Model prediction can be found in block 8 where we obtain the AE reconstructed spectrum "XReconstructed". 
9- Then, we calculate the AE error between XTest and XReconstructed. 
 (Here, we need to narrow down our analysis to the region between 260 and 350 nm, therefore we got the sum of AE error between 260 and 350 nm indices from "lambda" vector) 
10- From block 9 we obtain the AE Error mean and std for the score and then we dump it in the "AE_Error_mean" and "AE_Error_std" arrays. 
(We repeat blocks 5 to 10 for each score, until we get 7 indices for AE_Error_mean and AE_Error_std arrays). 

**note** step number 9, the indices AE error between 260 and 350 nm from "lambda" will be different for each score. 

11- Here, we plot the AE error versus the VS. 
12- Then, we get r-squared for the plot in block 12. 


*********************************************************************************************************************************************************************************

"Intensity and VS"

This code is used to generate the graph shown in Figure 10. 
The code is similar to the AE Anomaly Detection code, but we are not training any AE algorithm. 
Instead, we are calculating the intensity around 325 nm for each visual score (Here, we focused on the intensity around the 325 nm region only).  
The code is divided into 6 blocks. 

1- In the first block, we read the disease dataset of corn emission spectra and assigned it to "spectra"
2- Then, we remove all the 0's from the first row of the matrix spectra & normalize the spectra to the maximum peak of corn leaf at ~450.
3- Then, we calculate the mean intensity and std of the intensities around the 325 nm region. 
 (Here, we need to narrow down our analysis to 325 nm, therefore we got the mean of indices around 325 nm from "lambda" vector)
4- From block 3 we obtain the intensity mean and std for the scores and then we dump it in the "mean_int" and std_int" arrays.
 (We repeat blocks 1 to 4 for each score until we get 7 indices for mean_int" and std_int" arrays).

 **note** step number 4, the indices around 325 nm from "lambda" vector will be different for each score. 
 
5- Here, we plot the AE error versus the VS. 
6- Then, we get r-squared for the plot in block 5. 

*********************************************************************************************************************************************************************************

"Corn with Paraquat Treatment" 

This code is used to generate the graph shown in Figure 7. 
The code is divided into 5 blocks. 

1- In the first block, we assign the variables for healthy, day 0, and day 3 samples. 
2- Then, we read the healthy, day 0, and day 3 and assign them to "spectra_corn_H", "spectra_corn_D0", and "spectra_corn_D3" respectively. 
3- Then, we remove all the 0's from the first row of the matrices, get the mean for the three spectra, and normalize them to the maximum peak of corn leaf at ~450.
4- Then, we plot healthy and PQ-treated samples versus the VS.
5- Finally, a box plot was generated to show the change in the intensity values around 325 nm for the three samples. 
(Here, the x_plot means the intensity values around 325 nm (224:281 taken from lambda vector) for the three samples)

*********************************************************************************************************************************************************************************
