function pplot(theta,r,cols)

% PPLOT(THETA,R) makes a plot that will create a line from (r,th) to
% (r,th+pi)

if nargin < 3; cols = '-ob'; end

[~,loc] = max(abs(r))
polar([theta(loc) theta(loc)+pi],[r(loc) r(loc)],cols);
hold on

for i = 1:max(size(theta))
    polar([theta(i) theta(i)+pi],abs([r(i) r(i)]),cols);
    hold on
end


