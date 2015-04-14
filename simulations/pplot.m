function pplot(theta,r,cols,isxy)

% PPLOT(THETA,R) makes a plot that will create a line from (r,th) to
% (r,th+pi)

if nargin < 3; cols = '-ob'; end
if nargin < 4; isxy = 1; end

if isxy == 1
    x = abs(r).*cos(theta);
    y = abs(r).*sin(theta);
    for i = 1:max(size(theta))
        plot([-x(i) x(i)],[-y(i) y(i)],cols);
        hold on
    end
end



[~,loc] = max(abs(r));
polar([theta(loc) theta(loc)+pi],[r(loc) r(loc)],cols);
hold on

for i = 1:max(size(theta))
    polar([theta(i) theta(i)+pi],abs([r(i) r(i)]),cols);
    hold on
end

axis auto

