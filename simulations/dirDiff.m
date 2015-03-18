function dirDiff(dataset,dirs,b0s)

% For right now, this code is only meant to do the work for the pseudo 3D
% samples, as it will take an RMS difference, by looking at each slice in
% the dataset!

fs = 0;

for i = dirs+1:dirs+b0s
    if i < 10
        stri = ['0' num2str(i)];
    else
        stri = num2str(i);
    end
    

    fs = fs + mincmap([dataset '.' stri '.mnc']); % read in and sum the b0s
    
    if i == dirs+b0s
        fs = squeeze(mean(fs/b0s,1)); % perform the division for the average
        radData = zeros([size(fs) dirs]); % This is where we're saving the radius information for the dataset
    end
    
end



for i = 1:dirs
    if i < 10
        stri = ['0' num2str(i)];
    else
        stri = num2str(i);
     end
    
     us = mincmap([dataset '.' stri '.mnc']); % read in the info for one direction
        
     us = squeeze(mean(us,1));
        
     radData(:,:,i) = log(reshape(us,[size(us) 1]))/1917;
end
    
save([dataset 'RadiusData.mat'],'radData');

    