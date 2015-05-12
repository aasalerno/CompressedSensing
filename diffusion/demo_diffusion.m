% This is a script to test with diffusion data

rand('twister',2000);
addpath(strcat(pwd,'/utils'));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DATA LOADING and PREALLOCATION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The image should be a 3D stack of different directions
% This file is *complex* data from all 30 directions from Brain #6 of

% Jacob's data from July. Variable is "im"
load brain6-zpad.mat

% This one is for reality checking
% load brain.6.01-zpad.mat

N = size(im);
if length(N) == 2
    N = [N 1];
end
DN = [N(1) N(2)];
data = zeros(N);
im_dc = zeros(N);
res = zeros(N);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Direction Recon Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = '/micehome/asalerno/Documents/CompressedSensing/GradientVectorMag.txt'; % Vector file
thresh = 0.25; % Minimum dot product we'll accept
sigma = 2; % Standard deviation of the gaussian to control thickness (this is the weight)

% Check to make sure that the number of directions is the same as number of
% slices (one per direction) in our stack!
% Comment this out when doing reality checks
dimcheck = load(filename);
if (isempty(find(size(dimcheck) == N(3),1))) && dirWeight ~= 0
    error('The data does not comply with the number of directions')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% L1 Recon Parameters -- in normal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%N = [256,256]; 		% image Size
%DN = [256,256]; 	% data Size
% N = [128 128];
% DN = [128 128];
pctg = [0.25];  	% undersampling factor
P = 5;			% Variable density polymonial degree
TVWeight = 0.01; 	% Weight for TV penalty
xfmWeight = 0.1;	% Weight for Transform L1 penalty
dirWeight = 0.01;   % Weight for directionally similar penalty
Itnlim = 8;		% Number of iterations

% generate variable density random sampling
pdf = genPDF(DN,P,pctg , 2 ,0.1,0);	% generates the sampling PDF
k = genSampling(pdf,10,60);		% generates a sampling pattern

%generate transform operator
XFM = Wavelet('Daubechies',6,4);	% Wavelet
%XFM = TIDCT(8,4);			% DCT
%XFM = 1;				% Identity transform

%  ------------- END


% AS
for kk=1:N(3)
    % calculate the phase:
    ph = phCalc(squeeze(im(:,:,kk)),0,0);
    % FT
    trans.FT{kk} = p2DFT(k, [N(1) N(2)], ph, 2);
    FT = trans.FT{kk};
    data(:,:,kk) = reshape(FT*squeeze(im(:,:,kk)),[N(1) N(2) 1]);
    im_dc(:,:,kk) = reshape(FT'*(squeeze(data(:,:,kk))./pdf),[N(1) N(2) 1]);
    res(:,:,kk) = reshape(XFM*(squeeze(im_dc(:,:,kk))./pdf),[N(1) N(2) 1]);
end
% ---------------------------


% initialize Parameters for reconstruction
param = init;
param.FT = trans.FT;
param.XFM = XFM;
param.TV = TVOP;
param.data = data;
param.TVWeight =TVWeight;     % TV penalty
param.xfmWeight = xfmWeight;  % L1 wavelet penalty
param.dirWeight = dirWeight;  % directional weight
param.Itnlim = Itnlim;
[param.dirPair, param.dirPairWeight] = dotThresh(filename,thresh,sigma); % AS

tic
for n=1:8
	res = fnlCg(res,param);
	im_res = XFM'*res;
	%figure(100), imshow(abs(im_res),[]), drawnow
    figure(2)
    subplot(2,4,n)
    imshow(abs(im_res),[])
end
toc
