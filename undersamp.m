function data = undersamp(filename,outname,sampFac,filttype,gvdir)
% This function is made to pseudoundersample a dataset as we wish to do
% so.
%
% Primarily, this will be done only for the output of the gradient
% direction information (keeping in mind that we actually want to make sure
% that what we undersample is going to be the direction perpendicular to
% that line, going through the origin)
%
% This function has some parts of a code that I wrote in order to build
% PDFs (probability density functions) for spreading outside of a line.
%
%
%
% The parameters are as follows:
%
% filename - the input filename (string)
%          - This should be a minc file with information about the brain and
%          which gradient direction it is. Note that for Jacob's data (which
%          this is currently written for) the last 5 are no gradient
%          datasets. In theory, we may be able to get the gradient direction
%          from this information
% outname - The output filename (string)
%         - This data will effectively be the input file with the data
%         changed - that is, undersampled
% sampFac - The undersampling factor, generally 0.5
% gvdir - readout direction (string)
%       - The point of this data is to effectively make sure that we are
%       not messing up the data that we are looking at.
%       - As per Jacob, the general readout direction is 'y' for exvivo
%       scans
%       - Edited such that now we are going to include all of them,
%       ro,pe,sl
%
%
% Anthony Salerno                       01/06/15

if nargin < 3
    sampFac = 0.5;
end

if nargin < 4
    filttype = 'per';
end

if nargin < 5
    gvdir = {'dpe' 'dro' 'dsl'}; % This assumes an order of PE, RO, SL as per the grad vec file
                                 % However, if the order is different, which we
                                 % will check for, it will be changed.
end

rawdata = mincread(filename,'image'); % This gives us the dataset (k-space)
datamin = mincread(filename,'min'); % to be used in mincfft
datamax = mincread(filename,'max'); % to be used in mincfft

disp('Data read in')
data = zeros(size(rawdata)); % Preallocate memory for speed.

% Double check to make sure that the order is RO, PE, SL
check = h5readatt(filename,'/minc-2.0/info/vnmr','array');
check = check(2:end-2); % This gets rid of the brackets at the beginning and end
check = strsplit(check,',');
loc = zeros(1,3);
for i=1:3
    if check{i} == gvdir{1}
        loc(i) = 1;
    elseif check{i} == gvdir{2}
        loc(i) = 2;
    elseif check{i} == gvdir{3}
        loc(i) = 3;
    else
        error('Problem with your dimorder. Check file')
    end
end
disp('Proper order found and corrected')

% OLD METHOD USING DIMORDER
% % A little bit of work to make sure that we have the correct order for the
% % dimensions
% dimorder = h5readatt(filename,'/minc-2.0/image/0/image','dimorder'); %Dimension order
% dimorder = strsplit(dimorder,',');
% 
% for i = 1:length(dimorder)
%     a = dimorder{i};
%     dim{i} = a(1);
%     clear a
% end
% clear dimorder
% % Now we look at the order and see how we have to change around our
% % gradient directions so that they match!
% loc = zeros(1,3);
% for i=1:3
%     if dim{i} == 'x'
%         loc(i) = 1;
%     elseif dim{i} == 'y'
%         loc(i) = 2;
%     elseif dim{i} == 'z'
%         loc(i) = 3;
%     else
%         error('Problem with your dimorder. Check file')
%     end
% end

% Change the order of the gradient vectors so it corresponds with the data
graddir = load('GradientVector.txt');
disp('Gradient Loaded')
graddir = [graddir(:,loc(1)) graddir(:,loc(2)) graddir(:,loc(3))];

% Get which gradient we're working with by Splitting the name
nameSpl = strsplit(filename,'.');
gradvec = graddir(round(str2num(nameSpl{end-1})),:); % Get the gradient vector so we know which one we need

if gradvec > 30
    disp('No gradient. Do not undersample');
else
%     readloc = find(ismember(dim,gvdir)); % This tells us which dimension the readout is on for our dataset, i.e. 1, 2, or 3
%     tester = 1:3;
%     tester = find(~ismember(tester,readloc));
%     gradvec = gradvec(tester); % Gives us only the values for the non readout direction
%     % Quick and dirty way to do a projection
%     
%     % Here is where we will have the heart of the code - this is where we will
%     % actually do the undersampling
%     % As of 01/06/15 the method will only have the linear undersampling as the
%     % perpendicular value of the gradient vector
%     
%     gradvec = [-gradvec(2) gradvec(1)]; % Here is where we make it perpendicular
%     slp = gradvec(2)/gradvec(1);
    n = size(rawdata);
    disp('Creating filter')
    [fil,readloc] = genFilt(filttype,data,filename,sampFac,loc,gvdir);
    fil = uint16(fil);
    disp('Filter created and converted to uint16')

    if readloc == 1
        for i = 1:n(1)
            data(i,:,:) = reshape(fil,size(rawdata(i,:,:))).*rawdata(i,:,:); % Applies the filter to each "slice"
        end
    elseif readloc == 2
%         slicesz = ones(n(1),n(3)); %What is the size of each slice
%         filt = testline(slicesz,slp,sampFac); % Make the filter that we will use
        for i = 1:n(2)
            data(:,i,:) = reshape(fil,size(rawdata(:,i,:))).*rawdata(:,i,:); % Applies the filter to each "slice"
        end
    elseif readloc == 3
%         slicesz = ones(n(1),n(2)); %What is the size of each slice
%         filt = testline(slicesz,slp,sampFac); % Make the filter that we will use
        for i = 1:n(3)
            data(:,:,i) = reshape(fil,size(rawdata(:,:,i))).*rawdata(:,:,i); % Applies the filter to each "slice"
        end
    end
    
% In order to have this work properly, we need to make a copy of the original file to the output file, then change the data that we so choose
    datawrite = mincfft(data,3,1,datamax,datamin);
    [datawritemin,datawritemax] = mincmaxmin(datawrite,3);
    mincwrite(filename,outname,datawrite,datawritemax,datawritemin);
    
end

