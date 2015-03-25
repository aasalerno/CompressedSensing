function data = elpsfilt(data,slp,sampFac,rat)
% ELPSFILT(DATA,SLP,SAMPFAC,RAT)
%
% This function will build an elliptical filter, the size of DATA at an
% angle as stated by SLP. SAMPFAC dictates the number of points it will
% have, and RAT tells us what a/b is, if:
%
%           (x/a)^2 + (y/b)^2 = 1 
% 
% is the equation of the ellipse.

s = size(data);
[x1,y1] = meshgrid(linspace(-1,1,s(2)),linspace(-1,1,s(1)));

theta = atan(slp);

rot = [cos(theta) -sin(theta); sin(theta) cos(theta)];
x = zeros(s);
y = x;

dbls = zeros([s 2]);

dbls(:,:,1) = x1;
dbls(:,:,2) = y1;
rotdbl = zeros([s 2]);

for i = 1:s(1)
    for j = 1:s(2)
        rotdbl(i,j,:) = reshape(rot*squeeze(dbls(i,j,:)),[1 1 2]);
    end
end

x = squeeze(rotdbl(:,:,1));
y = squeeze(rotdbl(:,:,2));

if rat<1
    rat = 1/rat;
end

b = 2*sqrt(sampFac/(rat*pi));
a = rat*b;

for i = 1:s(1)
    for j = 1:s(2)
        if ((x(i,j)/a)^2 + (y(i,j)/b)^2) <= 1
            data(i,j) = 1;
        else
            data(i,j) = 0;
        end
    end
end

