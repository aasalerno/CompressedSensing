function [beta,Gdiffsq] = directionIntensityFit(Ir,Iq,r,q,file)
% [beta,Gdiffsq] = directionIntensityFit(Ir,Iq,r,q,file)
%
% beta         - Fits of the plane that we will be using
% Gdiffsq      - bx^2 + by^2 + bz^2
% Ir           - 1 x length(r) matrix of intensities of the other
%                directions
% Iq           - The original intensity that we are working with             
% r            - The other directional vectors that we are working with
% q            - The original directional vector that we are working with
% file         - The gradient vector file -- Not necessarily required
%
% I_r - I_q = A*B where r is a counter. There are a certain number of
% directions that we are going to be working with, and this is how we will
% have it work. It is easiest if we work in the cartesian system.

if nargin == 5 || numel(q) == 1
    dirs = load(file);
    r = dirs(r,:);
    q = dirs(q,:);
end

% Obtain the number of rows and columns in the slice we're working with
[nrow, ncol] = size(Iq);

% Make a vector that gives us Ir - Iq for all r and give us A
A = zeros(size(r,1),3);
Irq = zeros(size(Ir));
for i = 1:size(r,1)
    Irq(:,:,i) = Ir(:,:,i) - Iq;
    A(i,:) = r(i,:) - q;
end

% Give us the required left side to make the proper term for beta
% Irq = A*B
% A' * Irq = A' * A * B
% (A' * A)^-1 * A' * Irq = B

Aleft = (A'*A)\A';
beta = zeros([size(Iq) 3]);
Gdiffsq = zeros(size(Iq));

for i = 1:nrow
    for j = 1:ncol
        beta(i,j,:) = Aleft*squeeze(Irq(i,j,:));
        Gdiffsq(i,j) = sum(beta(i,j,:).^2);
    end
end




