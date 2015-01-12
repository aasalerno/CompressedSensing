function mincwrite(filename,outname,data,maxdata,mindata)
% This function will write data to a mincfile, using another file as the
% basis for it. It has the ability to include the mindata and maxdata,
% however, if the information is unknown, it will not touch that
% information.
%
% We should come up with a method that logically outputs the important
% information, such as this, that we need, in the case that the "filename",
% i.e. what we are copying, isn't the same as the data we are processing.

copyfile(filename,outname);

if nargin < 3
    error('Not enough input arguments');
elseif nargin == 3
    copyfile(filename,outname);
    if ~(isa(data,'uint16') && ~(max(data(:)) == (2^16-1)))
        data = mincmap16(data);
    end
    h5write(outname,'/minc-2.0/image/0/image',data);
elseif nargin == 4
    error('Input either both the maxdata and mindata, or neither.')
elseif nargin == 5
    copyfile(filename,outname);
    if ~(isa(data,'uint16') && (max(data(:)) == (2^16-1)))
        data = mincmap16(data);
    end
    h5write(outname,'/minc-2.0/image/0/image',data);
    h5write(outname,'/minc-2.0/image/0/image-max',maxdata);
    h5write(outname,'/minc-2.0/image/0/image-min',mindata);
end