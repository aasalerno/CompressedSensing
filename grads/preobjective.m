function [FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx] = preobjective(x, dx, params)

% precalculates transforms to make line search cheap

% AS - preallocation and for looping
FTXFMtx = zeros(size(x));
FTXFMtdx = zeros(size(x));

DXFMtx = zeros([size(x,1) size(x,2) 2 size(x,3)]);
DXFMtdx = DXFMtx;

for kk = 1:size(x,3)
    x1 = squeeze(x(:,:,kk));
    dx1 = squeeze(dx(:,:,kk));
    FTXFMtx(:,:,kk) = params.FT{kk}*(params.XFM'*x1);
    FTXFMtdx(:,:,kk) = params.FT{kk}*(params.XFM'*dx1);
end


if params.TVWeight
    for kk = 1:size(x,3)
        x1 = squeeze(x(:,:,kk));
        dx1 = squeeze(dx(:,:,kk));
        DXFMtx(:,:,:,kk) = params.TV*(params.XFM'*x1);
        DXFMtdx(:,:,:,kk) = params.TV*(params.XFM'*dx1);
    end
    % else
    %     DXFMtx = 0;
    %     DXFMtdx = 0;
end