% this is a script to demonstrate the original experiment by Candes, Romberg and Tao
%
% (c) Michael Lustig 2007

rand('twister',2000);
addpath(strcat(pwd,'/utils'));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% L1 Recon Parameters 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

N = [256,256]; 		% image Size
DN = [256,256]; 	% data Size
% N = [128 128];
% DN = [128 128];
pctg = [0.25];  	% undersampling factor
P = 5;			% Variable density polymonial degree
TVWeight = 0.5; 	% Weight for TV penalty
xfmWeight = 0.5;	% Weight for Transform L1 penalty
Itnlim = 8;		% Number of iterations


% generate variable density random sampling
pdf = genPDF(DN,P,pctg , 2 ,0.1,0);	% generates the sampling PDF
k = genSampling(pdf,10,60);		% generates a sampling pattern

%generate image
%im = (phantom(N(1)))  + randn(N)*0.01 + i*randn(N)*0.01;
load brain.6.01-zpad-ksp.mat

%generate Fourier sampling operator
ph = phCalc(im,0,0);
trans.FT{1} = p2DFT(k, N, ph, 2);
data = trans.FT{1}*im;

%generate transform operator

XFM = Wavelet('Daubechies',6,4);	% Wavelet
%XFM = TIDCT(8,4);			% DCT
%XFM = 1;				% Identity transform 	

% initialize Parameters for reconstruction
param = init;
param.FT = trans.FT;
param.XFM = XFM;
param.TV = TVOP;
param.data = data;
param.TVWeight =TVWeight;     % TV penalty 
param.xfmWeight = xfmWeight;  % L1 wavelet penalty
param.Itnlim = Itnlim;

im_dc = trans.FT{1}'*(data./pdf);	% init with zf-w/dc (zero-fill with density compensation)
figure(100), imshow(abs(im_dc),[]);drawnow;

res = XFM*im_dc;

% do iterations
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


% create a low-res mask
mask_lr = genLRSampling_pctg(DN,pctg,1,0);
im_lr = ifft2c(zpad(fft2c(im).*mask_lr,N(1),N(2)));

im_full = ifft2c(zpad(fft2c(im),N(1),N(2)));
figure
imshow(abs(cat(2,im_full,im_lr,im_dc,im_res)),[]);
c = caxis;
clf
subplot(221)
imshow(abs(im_full),c);
title('Original (Fully Sampled)')
subplot(222)
imshow(abs(im_lr),c);
title('Low Res')
subplot(223)
imshow(abs(im_dc),c);
title('Zero Filled')
subplot(224)
imshow(abs(im_res),c);
title(['CS with ',num2str(round(100*pctg)),'% pts']);

figure, plot(1:N(1), abs(im_full(end/2,:)),1:N(1), abs(im_lr(end/2,:)), 1:N(2), abs(im_dc(end/2,:)), 1:N(2), abs(im_res(end/2,:)),'LineWidth',2);
legend('original', 'LR', 'zf-w/dc', 'TV');


