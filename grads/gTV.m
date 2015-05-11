function grad = gTV(x,params)
% compute gradient of TV operator

p = params.pNorm;

Dx = params.TV*(params.XFM'*x);

G = p*Dx.*(Dx.*conj(Dx) + params.l1Smooth).^(p/2-1);
grad = params.XFM*(params.TV'*G);