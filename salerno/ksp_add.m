% The purpose of this function is to look at all of the data from the
% different directions and do datasharing on them. The datasharing as it
% currently stands is based on the closest 5 directions (including itself)
% which relates to about 30 deg.

% Parameters for the data sharing
bymax = 0;
maxCheck = 5;

% load in the data and the sampling patters
dirs = load('GradientVectorMag.txt');
load('sampPattern.mat')
load('brain.6-zpad-ksp.mat')

% Create a grid of what we will and will not sample -- note that the 180 is
% there for the original dataset before zeropadding -- this needs to be
% edited before doing any other work!
N = size(im);
data = zeros(N);
[x,y] = meshgrid(linspace(-1,1,180),linspace(-1,1,180));
r = sqrt(x.^2 + y.^2);
r = zpad(r,256,256);
% Only look for those points that are between zero and 1
[x,y] = find((r<1 & r>0));

% Use this to calculate the FT for the data that we're feeding in
for kk=1:N(3)
    % calculate the phase:
    ph = phCalc(squeeze(im(:,:,kk)),0,0);
    % FT
    trans.FT{kk} = p2DFT(samp(:,:,kk), [N(1) N(2)], ph, 2);
    FT = trans.FT{kk};
    data(:,:,kk) = reshape(FT*squeeze(im(:,:,kk)),[N(1) N(2) 1]);
    %im_dc(:,:,kk) = reshape(FT'*(squeeze(data(:,:,kk))./pdf),[N(1) N(2) 1]);
    %res(:,:,kk) = reshape(XFM*(squeeze(im_dc(:,:,kk))),[N(1) N(2) 1]);
end

% Make a dot product matrix
dp = zeros(N(3));
for i = 1:N(3)
    for j = 1:N(3)
        dp(i,j) = abs(dot(dirs(i,:),dirs(j,:)));
    end
end
% Sort it from least to greatest
[d,inds] = sort(dp,2);
if bymax
    d = fliplr(d);
    inds = fliplr(inds);
end

data_tog = data;

for i = 1:30
    i
    for j = 1:length(x)
        cnt = 1;
        if ~samp(x(j),y(j),i)
            while cnt < maxCheck && ~abs(data(x(j),y(j),inds(i,cnt)))
                cnt = cnt+1;
            end
            data_tog(x(j),y(j),i) = data(x(j),y(j),inds(i,cnt));
        end
    end
end

im_done = zeros(N);

for i = 1:30
    im_done(:,:,i) = fftshift(ifft2(fftshift(data_tog(:,:,i))));
    im_done(:,:,i) = im_done(:,:,i)./max(max(im_done(:,:,i)));
end
