function grad = gXFM(x,params)
% compute gradient of the L1 transform operator

p = params.pNorm;

grad = zeros(size(x)); %AAS

for kk = 1:size(x,3) %AAS
    x1 = squeeze(x(:,:,kk)); %AAS
    grad(:,:,kk) = p*x1.*(x1.*conj(x1)+params.l1Smooth).^(p/2-1);
end