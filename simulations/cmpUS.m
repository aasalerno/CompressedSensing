function cmpUS(ref,cmp,dirs,saveFile)

% For right now, this code is only meant to do the work for the pseudo 3D
% samples, as it will take an RMS difference, by looking at each slice in
% the dataset!



for i = 1:dirs
    
    if i < 10
        stri = ['0' num2str(i)];
    else
        stri = num2str(i);
    end
    refDat = mincmap([ref '.' stri '.mnc']);
    cmpDat = mincmap([cmp '.' stri '.mnc']); % read in the info for one direction
    
    if i == 1
        radData = zeros([size(refDat) dirs]);
    end
    
    radData(:,:,:,i) = reshape(cmpDat./refDat,[size(refDat) 1]);
    disp(['Completed Direction ' stri ' of ' num2str(dirs)])
end

save(saveFile,'radData');

