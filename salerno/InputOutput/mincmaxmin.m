function [mindata,maxdata] = mincmaxmin(data,dim)
% This function is to be used with datasets. If you want this for a file,
% consider using mincread(filename,'max') and mincread(filename,'min')

n = size(data);
maxdata = zeros(n(dim),1);
mindata = zeros(n(dim),1);

if dim == 1
    for i = 1:n(dim)
        testData = data(i,:,:);
        maxdata(i) = max(testData(:));
        mindata(i) = min(testData(:));
    end
elseif dim == 2
    for i = 1:n(dim)
        testData = data(:,i,:);
        maxdata(i) = max(testData(:));
        mindata(i) = min(testData(:));
    end
elseif dim == 3
    for i = 1:n(dim)
        testData = data(:,:,i);
        maxdata(i) = max(testData(:));
        mindata(i) = min(testData(:));
    end
end