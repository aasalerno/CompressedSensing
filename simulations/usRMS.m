function diff = usRMS(ref,cmp,dirs,ROI)

if nargin<4; ROI=[]; end

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
    else
        fil = ROI;
    end
    
    data = zeros(size(refDat));
    for j = 1:size(refDat,1)
        tmpRef = refDat(j,:,:);
        tmpCmp = cmpDat(j,:,:);
        
        tmpRef = tmpRef(fil);
        tmpCmp = tmpCmp(fil);
        
        tmpDat = tmpCmp - tmpRef;
        
        data(i,:,:) = tmpDat;
    end
    disp(['On direction ' num2str(i) ' of ' num2str(dirs)]);
end

diff = rms(data(:));