function [locs,vals] = dotThresh(filename,thresh,sigma)

if isempty(filename); 
    v1 = load('C:\Users\saler_000\Dropbox\GradientVector.txt'); 
else
    v1 = load(filename);
end

if isempty(thresh); 
    thresh = 0.1; 
end

nv = length(v1);
cnt = 0; % Start the location for the ordered pairs

for i=1:nv-1
    for j = 1+1:nv
        dp = (dot(v1(i,:),v1(j,:)));
        if dp >= thresh
            cnt = cnt + 1;
            locs(cnt,:) = int8([i j]);
            vals(cnt) = exp(-((abs(dp)-1).^2)/(2*sigma^2));
        end
    end
end

