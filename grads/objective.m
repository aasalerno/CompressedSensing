function [res, obj, RMS] = objective(FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx, XFMtx, XFMtdx, x,dx,t, params)
%calculated the objective function

p = params.pNorm;
N = size(FTXFMtx);

if length(N) == 2
    N = [N 1];
end

obj = zeros(N(3),1);
objPre = FTXFMtx + t*FTXFMtdx - params.data;


for kk = 1:N(3)
    mul = objPre(:,:,kk);
    obj(kk) = (mul(:)'*mul(:))';
end

if params.TVWeight
    TV = zeros(N(1)*N(2)*2,N(3));
    for kk = 1:N(3)
        DXFMtx1 = DXFMtx(:,:,:,kk);
        DXFMtdx1 = DXFMtdx(:,:,:,kk);
        w = DXFMtx1(:) + t*DXFMtdx1(:);
        TV(:,kk) = (w.*conj(w)+params.l1Smooth).^(p/2);
    end
else
    TV = 0;
end

if params.xfmWeight
    XFM = zeros(N(1)*N(2),N(3));
    for kk = 1:N(3)
        x1 = x(:,:,kk);
        dx1 = dx(:,:,kk);
        w = x1(:) + t*dx1(:);
        XFM(:,kk) = (w.*conj(w)+params.l1Smooth).^(p/2);
    end
else
    XFM=0;
end

if params.dirWeight
    wgt = params.dirPairWeight;
    dirPair = params.dirPair;
    n = length(wgt);
    dir = zeros(1,n);
    for kk = 1:n
        Xi = XFMtx(:,:,dirPair(kk,1));
        DXi = XFMtdx(:,:,dirPair(kk,1));
        Xj = XFMtx(:,:,dirPair(kk,2));
        DXj = XFMtdx(:,:,dirPair(kk,2));
        val = wgt(kk).*(Xi(:) + t*DXi(:) - Xj(:) - t*DXj(:));
        dir(kk) = val(:)'*val(:);
    end
    
    % Separate by diffusion direction?
    if 1 == 1
        n = size(dirPair,1);
        nums = (1:n)';
        dirDiff = zeros(1,N(3));
        for kk = 1:30
            inRow = nums(any(kk == dirPair,2).*nums ~= 0);
            dirDiff(kk) = sum(dir(inRow),2);
        end
        
        % How shall I sum them?
        % Each diff gets it's own
        res = sum(obj,1) + sum(params.xfmWeight(:).*XFM,1) + sum(params.TVWeight(:).*TV,1)...
            + params.dirWeight(:).*dirDiff;
        RMS = sqrt(obj/sum(abs(params.data(:))>0));
    else
        
        TV = sum(TV.*params.TVWeight(:));
        XFM = sum(XFM.*params.xfmWeight(:));
        dirDiff = sum(dir.*params.dirWeight(:));
        RMS = sqrt(obj/sum(abs(params.data(:))>0));
        
        
        res = obj + (TV) + (XFM) + (dirDiff);
    end
    
    
else % If dirWeight doesn't exist.
    
    TV = sum(TV.*params.TVWeight(:));
    XFM = sum(XFM.*params.xfmWeight(:));
    RMS = sqrt(obj/sum(abs(params.data(:))>0));
    
    
    res = obj + (TV) + (XFM) ;
end
