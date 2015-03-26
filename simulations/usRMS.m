function diff = usRMS(ref,cmp,dirs,ROI)


data = [];
for i = 1:dirs
    
    if i < 10
        stri = ['0' num2str(i)];
    else
        stri = num2str(i);
    end
    refDat = mincmap([ref '.' stri '.mnc']);
    cmpDat = mincmap([cmp '.' stri '.mnc']); % read in the info for one direction
    
    if i == 1 && (isempty(ROI) || ~any(ROI(:)));
        fil = logical(circfilt(squeeze(refDat(i,:,:)),0.7) - circfilt(squeeze(refDat(i,:,:)),0.4));
    end
    
    
    
    
    for j = 1:size(refDat,1)
        tmpRef = refDat(j,:,:);
        tmpCmp = cmpDat(j,:,:);
        
        tmpRef = tmpRef(fil);
        tmpCmp = tmpCmp(fil);
        
        tmpDat = tmpCmp - tmpRef;
        
        data = [data; tmpDat];
    end
end

diff = rms(data(:));