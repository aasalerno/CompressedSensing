function undersamp(filename,outname,rodir)
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
% rodir - readout direction (string)
%       - The point of this data is to effectively make sure that we are
%       not messing up the data that we are looking at. 
%       - As per Jacob, the general readout direction is 'y' for exvivo
%       scans
%
%
% Anthony Salerno                       01/06/15

if nargin<3
    rodir = 'y';
end

rawdata = h5read(filename,'/minc-2.0/image/0/image'); % This gives us the dataset

% A little bit of work to make sure that we have the correct order for the
% dimensions
dimorder = h5readatt('C:\Users\saler_000\Documents\raw\real\RealImgRaw.2.1.mnc',...
    '/minc-2.0/image/0/image','dimorder'); %Dimension order
dimorder = strsplit(dimorder,',');

for i = 1:length(dimorder)
    a = dimorder{i};
    dim{i} = a(1);
    clear a
end

clear dimorder




    
