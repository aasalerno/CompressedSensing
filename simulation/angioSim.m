% generate randomly oriented vessels with different sizes and magnitude

if ~exist('automate')
	if automate==1
		Nmag = 3;
		N = [100,100]; % k-space and image size do not have to be the same
		DN = [100,100]; 
		pctg = [1/15];
		P = 20;
		TVWeight = 0.1;
		xfmWeight = 0.1;
		Itnlim = 30;
		sizes = [ 1,3,6]
		maxN = 40;
		Show = 1;
	end
end

mags = [1:Nmag]/Nmag;

% generate random coordinates and orientations
[sx,sy,m] = meshgrid(sizes(:),sizes(:),mags(:));
for n=1:3
	sx(:,:,n) = triu(sx(:,:,n));
	sy(:,:,n) = triu(sy(:,:,n));
end
idx = find(sx~=0);
sx = sx(idx);
sy = sy(idx);
m = m(idx);

% generate image
rand('twister',16000);	% init random generator so image is the same
im = angioSynth(N, sx(:), sy(:), m(:));

% generate variable density random sampling
pdf = genPDF(DN,P,pctg , 2 ,0,0);
k = genSampling(pdf,500,2);


%generate Fourier sampling operator and data
FT = p2DFT(k, N, 1, 2);
data = FT*im;


%generate transform operator
XFM = 1;

% initialize

im_init = FT'*(data./pdf);
figure(100), imshow(abs(im_init),[]);drawnow;


% initialize Parameters for reconstruction
param = init;
param.FT = FT;
param.XFM = XFM;
param.TV = TVOP;
param.data = data;
param.TVWeight =TVWeight;     % TV penalty 
param.xfmWeight = xfmWeight;  % L1 wavelet penalty
param.Itnlim = Itnlim;

im_dc = FT'*(data./pdf);	% init with zf-w/dc (zero-fill with density compensation)
figure(100), imshow(abs(im_dc),[]);drawnow;

res = XFM*im_dc;

% do iterations
MSE = [];
L1 = [];
for n=1:maxN
	res = fnlCg(res,param);
	param.TVWeight = param.TVWeight*0.8;  % decrease Lambda every iteration
	param.xfmWeight = param.xfmWeight*0.8;
	im_res = XFM'*res;
	
	tmpmse = sum(sum(abs(param.FT*im_res - data).^2));
	tmpl1 = sum(sum(sum(abs(param.TV*im_res)))) + sum(sum(abs(res)));
	MSE = [MSE ; tmpmse];
	L1 = [L1 ; tmpl1];
	figure(100), imshow(abs(im_res),[]), drawnow
end

mask_lr = genLRSampling_pctg(DN,pctg,1,0);
im_lr = ifft2c(zpad(fft2c(im).*mask_lr,N(1),N(2)));
im_full = ifft2c(zpad(fft2c(im),N(1),N(2)));

if Show==1
	figure,subplot(211), imshow(abs(cat(2,im_full,im_lr,im_dc,im_res)),[0,1]);
	title(sprintf('Reconstruction: full -> LR -> zf-w/dc -> CS  from %f%% k-space samples',pctg*100))
	 subplot(212), imshow(cat(2,ones(size(k)),mask_lr,k,k),[]);
	title('sampling pattern')
end

