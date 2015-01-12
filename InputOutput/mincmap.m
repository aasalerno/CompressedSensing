function mapdata = mincmap(dataname)
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

% Read in some data
data = mincread(dataname,'image');
datamax = mincread(dataname,'max');
datamin = mincread(dataname,'min');
N = size(data);
mapdata = zeros(N);
n = size(datamax);
disp('Image, max, and min read in. Second matrix made to be altered for output');

% Double check to make sure that the order is RO, PE, SL
check = h5readatt(dataname,'/minc-2.0/info/vnmr','array');
check = check(2:end-2); % This gets rid of the brackets at the beginning and end
check = strsplit(check,',');
refStr = 'dsl'; 
ind = strfind(check,refStr);
ind = find(~cellfun(@isempty,ind));
disp('Dimension of the slice found.')


if ind == 1
    for i = 1:n
        dy = (datamax(i)-datamin(i))/(2^16); %Overall difference between max and min over the number of points
        mapdata(i,:,:) = data(i,:,:)*dy + datamin(i);
    end
elseif ind == 2
    for i = 1:n
        dy = (datamax(i)-datamin(i))/(2^16); %Overall difference between max and min over the number of points
        mapdata(:,i,:) = data(:,i,:)*dy + datamin(i);
    end
elseif ind == 3
    for i = 1:n
        dy = (datamax(i)-datamin(i))/(2^16); %Overall difference between max and min over the number of points
        mapdata(:,:,i) = data(:,:,i)*dy + datamin(i);
    end
end
