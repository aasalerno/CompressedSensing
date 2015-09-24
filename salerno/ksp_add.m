% The purpose of this function is to look at all of the data from the
% different directions and do datasharing on them. The datasharing as it
% currently stands is based on the closest 5 directions (including itself)
% which relates to about 30 deg.

dirs = load('GradientVectorMag.txt');
load('sampPattern.mat')
load('brain.6-zpad-ksp.mat')

N = size(im);
data = zeros(N);
[x,y] = meshgrid(linspace(-1,1,180),linspace(-1,1,180));
r = sqrt(x.^2 + y.^2);
r = zpad(r,256,256);
[x,y] = find((r<1 & r>0));

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

dp = zeros(30);
for i = 1:30
    for j = 1:30
        dp(i,j) = abs(dot(dirs(i,:),dirs(j,:)));
    end
end
[d,inds] = sort(dp,2);
d = fliplr(d);
inds = fliplr(inds);

data_tog = data;

for i = 1:30
    i
    for j = 1:length(x)
        cnt = 1;
        if ~samp(x(j),y(j),i)
            while cnt < 5 && ~abs(data(x(j),y(j),inds(i,cnt)))
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
