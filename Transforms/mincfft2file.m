function mincfft2file(fileSuf,outname,type)
if ~strcmp(outname(end-3:end),'.mnc')
    outname = [outname '.mnc'];
end

base = 'C:\Users\saler_000\Documents\raw\';
prefixR = 'real\Real';
prefixI = 'imag\Imag';

% Build the paths
pathR = [base prefixR fileSuf];
pathI = [base prefixI fileSuf];

paths = {pathR pathI};
dataholdR = 0;
dataholdI = 0;
for i = 1:numel(paths)
    filename = paths{i};
    
    % Initalize by reading in the data
    data = mincread(filename,'image');
    datamax = mincread(filename,'max');
    datamin = mincread(filename,'min');
    
    % Find the index that we want for the dataset (i.e. do we want sl,pe,ro)
    ind = mincind(filename,type);
    
    if strcmp(type,'sl') || strcmp(type,'dsl')
        ind2 = ind;
    else
        ind2 = mincind(filename,'sl');
    end
    
    DATA = mincfft(data,1,ind,datamax,datamin);
    
    dataholdR = dataholdR + real(DATA);
    
    if any(imag(DATA(:)))
        dataholdI = dataholdI + imag(DATA);
    end
    
end


if all(imag(DATA(:)==0))
    [DATAmin,DATAmax] = mincmaxmin(dataholdR,ind2);
    mincwrite(filename,outname,dataholdR,DATAmax,DATAmin);
else
    [DATAminR,DATAmaxR] = mincmaxmin(dataholdR,ind2);
    [DATAminI,DATAmaxI] = mincmaxmin(dataholdI,ind2);
    outnameR = [outname(1:end-4) 'REAL' outname(end-3:end)];
    outnameI = [outname(1:end-4) 'IMAG' outname(end-3:end)];
    mincwrite(filename,outnameR,dataholdR,DATAmaxR,DATAminR);
    mincwrite(filename,outnameI,dataholdI,DATAmaxI,DATAminI);
end