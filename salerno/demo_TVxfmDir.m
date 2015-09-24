function [im_res,diffRMS] = demo_TVxfmDir(TVWeight,xfmWeight,dirWeight,thresh,sigma)
rand('twister',2000);
addpath(strcat(pwd,'/utils'));


% This one is for reality checking
% load brain.6.01-zpad.mat
load brain.6-zpad-ksp.mat
% im = phantom(256) + 0.01*(1i*randn(256) + randn(256));
load ksp_startloc.mat


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
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% L1 Recon Parameters -- in normal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%N = [256,256]; 		% image Size
%DN = [256,256]; 	% data Size
% N = [128 128];
% DN = [128 128];
pctg = 0.25;  	% undersampling factor
P = 5;			% Variable density polymonial degree
% TVWeight = 0.01; 	% Weight for TV penalty
% xfmWeight = 0.1;	% Weight for Transform L1 penalty
Itnlim = 8;		% Number of iterations

% generate variable density random sampling
% pdf = genPDF(DN,P,pctg , 2 ,0.1,0);	% generates the sampling PDF
% k = genSampling(pdf,10,60);		% generates a sampling pattern
load('sampPattern.mat');
k = samp;
data = data.*k;
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
%     ph = phCalc(squeeze(im(:,:,kk)),0,0);
%     % FT
%     trans.FT{kk} = p2DFT(k(:,:,kk), [N(1) N(2)], ph, 2);
%     FT = trans.FT{kk};
    % data(:,:,kk) = reshape(FT*squeeze(im(:,:,kk)),[N(1) N(2) 1]);
    im_dc(:,:,kk) = reshape(ifft2c(squeeze(data(:,:,kk))),[N(1) N(2) 1]);
    res(:,:,kk) = reshape(XFM*(squeeze(im_dc(:,:,kk))),[N(1) N(2) 1]);
end
% ---------------------------

% % Then have the y term be our data that's added together.
% load ksp_startloc.mat

% initialize Parameters for reconstruction
%param.FT = trans.FT;
param.XFM = XFM;
param.TV = TVOP;
param.data = data;
param.TVWeight =TVWeight;     % TV penalty
param.xfmWeight = xfmWeight;  % L1 wavelet penalty
param.dirWeight = dirWeight;  % directional weight
param.Itnlim = Itnlim;

tic
for n=1:8
    res = fnlCg(res,param);
     n
% 	im_hold = XFM'*res(:,:,1);
% % 	%figure(100), imshow(abs(im_res),[]), drawnow
%     figure(3)
%     subplot(2,4,n)
%     imshow(abs(im_hold),[])
end

for i=N(3):-1:1
    im_res(:,:,i) = XFM'*res(:,:,i);
end
% % create a low-res mask
% mask_lr = genLRSampling_pctg(DN,pctg,1,0);
% im_lr = ifft2c(zpad(fft2c(im).*mask_lr,N(1),N(2)));
% 
% im_full = ifft2c(zpad(fft2c(im),N(1),N(2)));
% figure
% imshow(abs(cat(2,im_full,im_lr,im_dc,im_res)),[]);
% c = caxis;
% clf
% subplot(221)
% imshow(abs(im_full),c);
% title('Original (Fully Sampled)')
% subplot(222)
% imshow(abs(im_lr),c);
% title('Low Res')
% subplot(223)
% imshow(abs(im_dc),c);
% title('Zero Filled')
% subplot(224)
% imshow(abs(im_res),c);
% title(['CS with ',num2str(round(100*pctg)),'% pts']);
% 
% figure, plot(1:N(1), abs(im_full(end/2,:)),1:N(1), abs(im_lr(end/2,:)), 1:N(2), abs(im_dc(end/2,:)), 1:N(2), abs(im_res(end/2,:)),'LineWidth',2);
% legend('original', 'LR', 'zf-w/dc', 'TV');

diffRMS = rms(im(:)-im_res(:));

% w = whos;
% for a = 1:length(w)
% outs.(w(a).name) = eval(w(a).name);
% end
% save(['/projects/muisjes/asalerno/CS/data/directionalData/thresh_' num2str(thresh) '/xfm_' num2str(xfmWeight) '.TV_' num2str(TVWeight) '.dir_' num2str(dirWeight) '.mat'],'im_res')

% h = figure;
% subplot(131)
% imshow(im(:,:,1))
% ph = phCalc(squeeze(im(:,:,1)),0,0);
% imshow(im(:,:,1).*ph)
% title('Fully Sampled')
% 
% subplot(132)
% imshow(im_dc(:,:,1))
% title('k-space Added')
% 
% subplot(133)
% imshow(im_res(:,:,1))
% title(['\lambda_1 = \lambda_2 = 0   \lambda_3 = ' num2str(dirWeight)])

%mat2mnc(abs(im_res),['/home/asalerno/Desktop/08.11.15/add-ksp-data_dirWeight-' num2str(dirWeight) '_TVWeight-' num2str(TVWeight) '_xfmWeight-' num2str(xfmWeight) '.mnc'])
