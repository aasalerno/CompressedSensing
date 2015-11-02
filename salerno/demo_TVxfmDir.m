function [im_res,diffRMS] = demo_TVxfmDir(TVWeight,xfmWeight,dirWeight,thresh,sigma)
rand('twister',2000);
addpath(strcat(pwd,'/utils'));


% This one is for reality checking
% load brain.6.01-zpad.mat
load brain.6-zpad-ksp.mat
% im = phantom(256) + 0.01*(1i*randn(256) + randn(256));
dat_share = 'data_added_nearest.mat';
load(dat_share);


N = size(im);
if length(N) == 2
    N = [N 1];
end
for i = 1:N(3)
     im(:,:,i) = im(:,:,i)/max(max(im(:,:,i)));
end

DN = [N(1) N(2)];
% data = zeros(N);
% im_dc = zeros(N);
% res = zeros(N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Direction Recon Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = '/micehome/asalerno/Documents/CompressedSensing/GradientVectorMag.txt'; % Vector file
thresh = 0.6; % Minimum dot product we'll accept
threshAcc = 4;
sigma = 0.1; % Standard deviation of the gaussian to control thickness (this is the weight)
%dirWeight = 0;   % Weight for directionally similar penalty

% Check to make sure that the number of directions is the same as number of
% slices (one per direction) in our stack!
% Comment this out when doing reality checks
dimcheck = load(filename);
if (isempty(find(size(dimcheck) == N(3),1))) && dirWeight ~= 0
    error('The data does not comply with the number of directions')
end

param = init;
if dirWeight
    [param.dirPair, param.dirPairWeight] = dotThresh(filename,thresh,sigma); % AS
    %dirInfo = lsqA(file,threshAcc);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% L1 Recon Parameters -- in normal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


pctg = 0.25;  	% undersampling factor
P = 5;			% Variable density polymonial degree
Itnlim = 8;		% Number of iterations

% generate variable density random sampling
% pdf = genPDF(DN,P,pctg , 2 ,0.1,0);	% generates the sampling PDF
% k = genSampling(pdf,10,60);		% generates a sampling pattern


%generate transform operator
XFM = Wavelet('Daubechies',10,4);	% Wavelet
%XFM = TIDCT(8,4);			% DCT
%XFM = 1;				% Identity transform

%  ------------- END
pdf = (sum(k,3) + eps)/max(k(:));

%Make the starting point what we got off the scanner
% data = data.*k;

% AS
for kk=1:N(3)
    % calculate the phase:
    ph = phCalc(squeeze(im(:,:,kk)),0,0);
%     % FT
    trans.FT{kk} = p2DFT(k(:,:,kk), [N(1) N(2)], ph, 2);
    FT = trans.FT{kk};
    % data(:,:,kk) = reshape(FT*squeeze(im(:,:,kk)),[N(1) N(2) 1]);
    im_dc(:,:,kk) = reshape(ifft2c(squeeze(data(:,:,kk))),[N(1) N(2) 1]);
    res(:,:,kk) = reshape(XFM*(squeeze(im_dc(:,:,kk))),[N(1) N(2) 1]);
end
% ---------------------------

% % Then have the  term be our data that's NOT added together.
load('sampPattern.mat');
k = samp;
data = data.*k;


% initialize Parameters for reconstruction
param.FT = trans.FT;
param.XFM = XFM;
param.TV = TVOP;
param.data = data;
param.TVWeight =TVWeight;     % TV penalty
param.xfmWeight = xfmWeight;  % L1 wavelet penalty
param.dirWeight = dirWeight;  % directional weight
%param.dirInfo = dirInfo;
param.Itnlim = Itnlim;

steps = zeros([size(res) 8]);
tic
for n=1:8
    res = fnlCg(res,param);
    n
    steps(:,:,:,n) = res;
% 	im_hold = XFM'*res(:,:,1);
% % 	%figure(100), imshow(abs(im_res),[]), drawnow
%     figure(3)
%     subplot(2,4,n)
%     imshow(abs(im_hold),[])
end

for i=N(3):-1:1
    im_res(:,:,i) = XFM'*res(:,:,i);
end


diffRMS = rms(im(:)-im_res(:));


%mat2mnc(abs(im_res),['/home/asalerno/Desktop/10.23.15/data_shared_far.mnc'])
