function grad = gTV(x,params)
% compute gradient of TV operator

p = params.pNorm;

grad = zeros(size(x));

for kk = 1:size(x,3)
    x1 = squeeze(x(:,:,kk));
    Dx = params.TV*(params.XFM'*x1);
    G = p*Dx.*(Dx.*conj(Dx) + params.l1Smooth).^(p/2-1);
    grad(:,:,kk) = params.XFM*(params.TV'*G);
end