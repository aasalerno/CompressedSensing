function grad = wGradient(x,params)

gradXFM = 0;
gradTV = 0;

gradObj = gOBJ(x,params);

if params.xfmWeight
    gradXFM = gXFM(x,params);
end

if params.TVWeight
    gradTV = gTV(x,params);
end

% AAS
if isfield(params,'dirWeight') && params.dirWeight
   gradDir = gDir(x,params);
   grad = (gradObj + params.xfmWeight.*gradXFM + params.TVWeight.*gradTV ...
                + params.dirWeight.*gradDir);
else
    %NORMAL
   grad = (gradObj + params.xfmWeight.*gradXFM + params.TVWeight.*gradTV);
end

