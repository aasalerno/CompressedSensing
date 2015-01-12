function [mapdata,mindat,maxdat] = mincmap16(data,dim)
% mapdata = mincmap16(data,dim)
%
% The funciton is made to quickly bring the data from double to uint16. It
% assumes dim3 is the slice dimension, but this can be manually changed in
% the coe if you wish.

if nargin < 2
    dim = 3;
end

dim = round(dim); % Make sure nothing stupid happens.

N = size(data);
% Preallocate some information for speed.
mapdata = zeros(N);
mindat = zeros(1,N(dim));
maxdat = zeros(1,N(dim));

if dim > 3
    error('Dimension cannot be greater than 3.');
elseif dim == 1
    for i = N(dim)
        mindat(i) = min(min(squeeze(data(i,:,:))));
        maxdat(i) = max(max(squeeze(data(i,:,:))));
        dy = (maxdat(i)-mindat(i))/2^16;
        mapdata(i,:,:) = (data(i,:,:)-mindat(i))./dy;
    end
elseif dim == 2
    for i = N(dim)
        mindat(i) = min(min(squeeze(data(:,i,:))));
        maxdat(i) = max(max(squeeze(data(:,i,:))));
        dy = (maxdat(i)-mindat(i))/2^16;
        mapdata(:,i,:) = (data(:,i,:)-mindat(i))./dy;
    end
elseif dim == 3
    for i = N(dim)
        mindat(i) = min(min(squeeze(data(:,:,i))));
        maxdat(i) = max(max(squeeze(data(:,:,i))));
        dy = (maxdat(i)-mindat(i))/2^16;
        mapdata(:,:,i) = (data(:,:,i)-mindat(i))./dy;
    end
end

mapdata = uint16(mapdata);