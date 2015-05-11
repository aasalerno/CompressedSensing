function [FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx] = preobjective(x, dx, params)

% precalculates transforms to make line search cheap

FTXFMtx = params.FT*(params.XFM'*x);
FTXFMtdx = params.FT*(params.XFM'*dx);

if params.TVWeight
    DXFMtx = params.TV*(params.XFM'*x);
    DXFMtdx = params.TV*(params.XFM'*dx);
else
    DXFMtx = 0;
    DXFMtdx = 0;
end