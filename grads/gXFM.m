function grad = gXFM(x,params)
% compute gradient of the L1 transform operator

p = params.pNorm;

grad = zeros(size(x));

for kk = 1:size(x,3)
    x1 = squeeze(x(:,:,kk));
    grad(:,:,kk) = p*x1.*(x1.*conj(x1)+params.l1Smooth).^(p/2-1);
end