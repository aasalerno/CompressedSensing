function gradDir = gDir(x,params)
% computes the gradient of data similarity

dirPair = params.dirPair;
wgt = params.dirPairWeight;

N = size(dirPair,1);
gradDirTot = zeros([size(x,1) size(x,2) N]);
gradDir = zeros(size(x));

for kk = 1:N
    i = dirPair(kk,1);
    j = dirPair(kk,2);
    x1 = squeeze(x(:,:,i));
    x2 = squeeze(x(:,:,j));
    %gradDirTot(:,:,kk) = params.XFM*(2.*wgt(kk).*(params.XFM'*x1-params.XFM'*x2));
    % Edited for time 
    gradDirTot(:,:,kk) = (2.*wgt(kk).*((x1-x2)));
end


nums = (1:N)';

for kk = 1:max(dirPair(:))
    % inRow = nums(any(kk == dirPair,2).*nums ~= 0);
    [inRow,inCol] = find(kk == dirPair);
    gradDirWork = gradDirTot(:,:,inRow);
    
    % Check for the times when it's in the second column
    for i = 1:numel(inCol)
        if inCol(i) == 2
            gradDirTot(:,:,i) = -gradDirWork(:,:,i);
        end
    end
    
    gradDir(:,:,kk) = sum(gradDirWork,3);
end
