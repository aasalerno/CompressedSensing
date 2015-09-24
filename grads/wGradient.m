function grad = wGradient(x,params)

persistent cnt

if isempty(cnt)
    cnt = 0;
end

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
%    gdir = gradDir(:,:,1);
%    save(['/projects/muisjes/asalerno/CS/data/dirArtefactData/dx_grad.' num2str(cnt) '.mat'],'gdir');
%    cnt = cnt + 1;
else
    %NORMAL
   grad = (gradObj + params.xfmWeight.*gradXFM + params.TVWeight.*gradTV);
end

