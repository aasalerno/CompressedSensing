% script mincmassrecon
% This will do a mass recon for a specific set of files 
% Meant to be eventually put into a function
fileMid = 'ImgRaw';
fileSuf = '.mnc';
filename = 'C:\Users\saler_000\Documents\raw\real\RealImgRaw';
outname = 'MatlabRecon';
brain = 2;
dir = 3:35;

for i = 1:numel(brain)
    for j = 1:numel(dir)
        disp(['On brain ' num2str(brain(i)) ', direction ' num2str(dir(j)) '.']);
        path = [fileMid '.' num2str(brain(i)) '.' num2str(dir(j)) fileSuf];
        outpath = ['E:/' outname '.' num2str(brain(i)) '.' num2str(dir(j)) fileSuf];
        filein = [filename '.' num2str(brain(i)) '.' num2str(dir(j)) fileSuf];
        mincrecon2file(path,filein,outpath);
    end
end
            
            