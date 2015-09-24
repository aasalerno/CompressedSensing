function ind = mincind(filename,refStr)
% Find the location of sl in a dataset
check = h5readatt(filename,'/minc-2.0/info/vnmr','array');
check = check(2:end-2); % This gets rid of the brackets at the beginning and end
check = strsplit(check,',');
if strcmp('d',refStr)
    refStr = ['d' refStr];
end
ind = strfind(check,refStr);
ind = find(~cellfun(@isempty,ind));
