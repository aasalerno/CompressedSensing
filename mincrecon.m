function Data = mincrecon(fileSuf)
% Data = mincrecon(filebase)
%
% This function will:
%   - Perform a 3D FFT on the summative dataset
% 	- Take the magnitude of the FFT
% 	- Write the magnitude information to file
% 	- Write the min and max information to file
% This function can then be put into a script to be done recursively over 
% all datasets.

% This is specific for the current dataset and should be phased out!
base = 'C:\Users\saler_000\Documents\raw\';
prefixR = 'real\Real';
prefixI = 'imag\Imag';

% Build the paths
pathR = [base prefixR fileSuf];
pathI = [base prefixI fileSuf];

% % Can be done in a method that we pull all of the data individually
% % Obtain all of the data for the real dataset
% dataR = mincread(pathR,'image');
% dataRmax = mincread(pathR,'max');
% dataRmin = mincread(pathR,'min');
% 
% % Obtain all of the data for the imaginary dataset
% dataI = mincread(pathI,'image');
% dataImax = mincread(pathI,'max');
% dataImin = mincread(pathI,'min');
%
% dataR = mincmap(dataR,dataRmin,dataRmax,3);
% dataI = mincmap(dataI,dataImin,dataImax,3);
%

dataR = mincmap(pathR); % Maps the data to double using the information in the minc file specified
dataI = mincmap(pathI); % " " " " " " " " " " " " " " " " " " " " " " " " " " " 

% Build the dataset
data = dataR + 1i*dataI; % This is the total dataset as we expect it, with both real and imaginary parts

Data = mincfft(data,3); % Telling the code to do a 3D fft on data - NOTE THAT IT IS ALREADY SHIFTED

