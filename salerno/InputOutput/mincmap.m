function mapdata = mincmap(dataset,datamin,datamax,ind)
% mapdata = mincmap(filename)
%
%
% This function is made to map the data from uint16 (i.e. 0 - 2^16-1) into
% the actual data that we are working with...
%
% The code also makes a pretty big assumption that the max/min are done on
% the slice dimension
%
% It will first be built in a brute force method, and then, it will be
% optimized to work more quickly and efficiently
%
% dataset - the data or filename
% datamin - minima from the minc file
% datamax - maxima from minc files
% ind - the index that the minima/maxima are found on (generally the slice
%       dimension)

% Read in some data

% To halt errors
if nargin == 1
    datamax = 0;
    datamin = 0;
end

% if somehow a mistake was made, we fix it here.
if datamin(1) > datamax(1)
    a = datamin;
    datamin = datamax;
    datamax = a;
end

if isa(dataset,'uint16') || isa(dataset,'string') || isa(dataset,'char')
    if isa(dataset,'string') || isa(dataset,'char')
        filename = dataset;
        dataset = mincread(filename,'image');
        datamax = mincread(filename,'max');
        datamin = mincread(filename,'min');
        N = size(dataset);
        mapdata = zeros(N);
        n = size(datamax);

        % Double check to make sure that the order is RO, PE, SL
        check = h5readatt(filename,'/minc-2.0/info/vnmr','array');
        check = check(2:end-2); % This gets rid of the brackets at the beginning and end
        check = strsplit(check,',');
        refStr = 'dsl';
        ind = strfind(check,refStr);
        ind = find(~cellfun(@isempty,ind));
    else
        n = size(datamax);
    end
    
    dataset = double(dataset);
    if ind == 1
        for i = 1:n
            dy = (datamax(i)-datamin(i))/(2^16-1); %Overall difference between max and min over the number of points
            mapdata(i,:,:) = dataset(i,:,:)*dy + datamin(i);
        end
    elseif ind == 2
        for i = 1:n
            dy = (datamax(i)-datamin(i))/(2^16-1); %Overall difference between max and min over the number of points
            mapdata(:,i,:) = dataset(:,i,:)*dy + datamin(i);
        end
    elseif ind == 3
        for i = 1:n
            dy = (datamax(i)-datamin(i))/(2^16-1); %Overall difference between max and min over the number of points
            mapdata(:,:,i) = dataset(:,:,i)*dy + datamin(i);
        end
    end
else
    disp('Wrong datatype. If you have a double, use mincmap16 to convert to uint16.')
end
