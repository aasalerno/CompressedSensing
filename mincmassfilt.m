function mincmassfilt(outbase,brains,dirs,filttype)
% This function is built to run a mass undersampling regimen on the
% datasets, based on the filtertype that you feed into it!
% The heart of it comes from "undersample.m", but it is noted that a few
% additions come into play

fileMid = 'ImgRaw';
fileSuf = '.mnc';
outnameK = 'filtK/';
outnameX = 'filtX/';
sampFac = 0.5;

if ~strcmp(outbase(end),'/')
    outpathdirK = [outbase '/' outnameK];
    outpathdirX = [outbase '/' outnameX];
else
    outpathdirK = [outbase outnameK];
    outpathdirX = [outbase outnameX];
end

if ispc()
    base = 'C:\Users\saler_000\Documents\raw\';
    prefixR = 'real\Real';
    prefixI = 'imag\Imag';
else
    base = '/projects/souris/asalerno/CS/data/';
    prefixR = 'Real';
    prefixI = 'Imag';
end

% Build paths for undersampling
USfilenameR = [base prefixR fileMid];
USfilenameI = [base prefixI fileMid];


if ~exist(outpathdirK,'dir')
    mkdir(outpathdirK)
end

if ~exist(outpathdirX,'dir')
    mkdir(outpathdirX)
end

nB = numel(brains);
nD = numel(dirs);
totScan = nB*nD;
for i = 1:nB
    for j = 1:nD
        numScan = (nD-1)*i + j;
        disp(['Undersampling. On brain ' num2str(brains(i)) ', direction ' num2str(dirs(j)) ...
            '. This is brain ' num2str(numScan) ' of ' num2str(totScan)]);
        
        fileEndR = [USfilenameR '.' num2str(brain(i)) '.' num2str(dirs(j)) fileSuf]; % Full input filenames
        fileEndI = [USfilenameI '.' num2str(brain(i)) '.' num2str(dirs(j)) fileSuf];
        % FUll output filenames
        outpathR = [outpathdirK prefixR 'US_' filttype '.' num2str(brain(i)) '.' num2str(dirs(j)) fileSuf];
        outpathI = [outpathdirK prefixI 'US_' filttype '.' num2str(brain(i)) '.' num2str(dirs(j)) fileSuf];
        
        % Undersample to file
        undersamp(fileEndR,outpathR,sampFac,filttype);
        undersamp(fileEndI,outpathI,sampFac,filttype);
        
        
        % Now, we have the files, but need to do the recon!
        fileSufRecon = ['US' filttype '.' num2str(brain(i)) '.' num2str(dirs(j)) fileSuf];
        
        % Do the FFT and write to file!
        data = mincrecon(fileSufRecon,outpathdirK);
        data = abs(data);
        
        ind = mincind(fileEndR,'dsl');
        [datamin,datamax] = mincmaxmin(data,ind);
        outpathRecon = [outpathdirX 'Recon_' filttype '.' num2str(brain(i)) '.' num2str(dirs(j)) fileSuf];
        mincwrite(fileEndR,outpathRecon,data,datamax,datamin);
    end
end



