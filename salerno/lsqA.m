function [dirInfo] = lsqA(file,ncons)
% r            - The other directional vectors that we are working with
% q            - The original directional vector that we are working with
% file         - The gradient vector file -- Not necessarily required
%
% I_r - I_q = A*B where r is a counter. There are a certain number of
% directions that we are going to be working with, and this is how we will
% have it work. It is easiest if we work in the cartesian system.

if nargin<2
    ncons = 4;
end

dirs = load(file);
N = size(dirs);

dp = zeros(N(1));
for i = 1:N(1)
    for j = 1:N(1)
        dp(i,j) = abs(dot(dirs(i,:),dirs(j,:)));
    end
end

[~,inds] = sort(dp,2);
% d = fliplr(d);
inds = fliplr(inds);

q = dirs(1:N(1),:);
for i = 1:N(1)
    r(:,:,i) = dirs(inds(i,2:ncons+1),:); % gets the three closest vecs
end

Nr = size(r);

% Make a vector that gives us Ir - Iq for all r and give us A
Aleft = zeros(Nr(2),Nr(1),N(1));
for i = 1:length(q)
    for j = 1:Nr(1)
        A(j,:) = r(j,:,i) - q(i);
        
        % Give us the required left side to make the proper term for beta
        % Irq = A*B
        % A' * Irq = A' * A * B
        % (A' * A)^-1 * A' * Irq =
        
    end
    Aleft(:,:,i) = (A'*A)\A';
end

dirInfo.Aleft = Aleft;
dirInfo.r = r;
dirInfo.inds = inds(:,2:ncons+1);