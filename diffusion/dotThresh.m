function [locs,wgt] = dotThresh(filename,thresh,sigma)

if nargin<3 || isempty(sigma); sigma = 1; end

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
        if abs(dp) >= thresh
            cnt = cnt + 1;
            locs(cnt,:) = int8([i j]);
            vals(cnt) = dp;
        end
    end
end

wgt = exp(-(vals.^2-1)./(2.*sigma.^2))';