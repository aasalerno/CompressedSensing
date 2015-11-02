function res = D(image)

%
% res = D(image)
%
% image = a 2D image
%
% This function computes the finite difference transform of the image
%
% Related functions:
%       adjD , invD 
%
%
% (c) Michael Lustig 2005
[sx,sy,sz] = size(image);
res = zeros(sx,sy,2,sz);
for i = 1:sz
    im = image(:,:,i);
    
    Dx = im([2:end,end],:) - im;
    Dy = im(:,[2:end,end]) - im;

    %res = [sum(image(:))/sqrt(sx*sy); Dx(:);  Dy(:)]; 
    res(:,:,i,:) = cat(4,Dx,Dy);
end 
    