function gradObj = gOBJ(x,params)
% computes the gradient of the data consistency

if length(size(x)) == 2
    x = reshape(x,[size(x) 1]);
end

gradObj = zeros(size(x));

for kk = 1:size(x,3)
    x1 = squeeze(x(:,:,kk));
    dat = squeeze(params.data(:,:,kk));
    gradObj(:,:,kk) = params.XFM*...
            (params.FT{kk}'*(params.FT{kk}*(params.XFM'*x1) - dat));
    gradObj(:,:,kk) = 2*gradObj(:,:,kk) ;
end
