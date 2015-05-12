function gradDir = gDir(x,params)
% computes the gradient of data similarity

dirPair = params.dirPair;
wgt = params.dirPairWeight;

N = size(dirPair,1);
gradDirTot = zeros([size(x,1) size(x,2) N]);
gradDir = zeros(size(x));

% This takes 5 seconds :'(

for kk = 1:N
    i = dirPair(kk,1);
    j = dirPair(kk,2);
    x1 = squeeze(x(:,:,i));
    x2 = squeeze(x(:,:,j));
    gradDirTot(:,:,kk) = params.XFM*(2.*wgt(kk).*(params.XFM'*x1-params.XFM'*x2));
end


nums = (1:N)';

for kk = 1:30
    inRow = nums(any(kk == dirPair,2).*nums ~= 0);
    gradDir(:,:,kk) = sum(gradDirTot(:,:,inRow),3);
end

% Whole thing takes ~8 seconds.