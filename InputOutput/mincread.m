function data = mincread(filename,type)
% data = mincread(filename,type) 
%
% The sole purpose of this code is to get the image data or max/min data
% from a minc file

if nargin<2
    type = 'image';
end

if strcmp(type,'image')
    data = h5read(filename,'/minc-2.0/image/0/image');
elseif strcmp(type,'max')
    data = h5read(filename,'/minc-2.0/image/0/image-max');
elseif strcmp(type,'max')
    data = h5read(filename,'/minc-2.0/image/0/image-max');
else
    disp('Type not understood. Retry with either ''image'', ''max'', or ''min''');
end