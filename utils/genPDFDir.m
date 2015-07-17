function [pdf,val] = genPDFann(imSize,p,pctg,wpdfs,cyl,distType,radius,disp)
%[pdf,val] = genPDFann(imSize,p,pctg [,annRad,cyl,orImSz,distType,radius,disp])
%
%	generates a pdf for a 1d or 2d random sampling pattern
%	with polynomial variable density sampling
%
%   Also adds on a term such that an annulus can be added on to the PDF in
%   order to get some of the high frequency data as well.
%
%   In addition, it tacks on a term that allows work to be done looking
%   only at the data actually collected -- i.e. the cylindrical data. Thus,
%   we should just be working with the original dataset size, and then zero
%   pad after the fact.
%
%	Input:
%		imSize - size of matrix or vector
%		p - power of polynomial
%		pctg - partial sampling factor e.g. 0.5 for half
%		distType - 1 or 2 for L1 or L2 distance measure
%		radius - radius of fully sampled center
%		disp - display output
%
%	Output:
%		pdf - the pdf
%		val - min sampling density
%
%
%	Example:
%	[pdf,val] = genPDF([128,128],2,0.5,2,0,1);
%
%	(c) Michael Lustig 2007

if nargin < 4
    wpdfs = ones(imSize);
end

if nargin < 5
    cyl = 0;
end

if nargin < 6
    distType = 2;
end

if nargin < 7
    radius = 0.1;
end

if nargin < 8
    disp = 0;
end


minval=0;
maxval=1;
val = 0.5;

if length(imSize)==1
    imSize = [imSize,1];
end

sx = imSize(1);
sy = imSize(2);

% AAS
% If it's cylindrical, we only care about how many points within our
% circle.
if cyl
    PCTG = floor(pctg*pi*(sx/2)*(sy/2));
else
    PCTG = floor(pctg*sx*sy);
end

if sum(imSize==1)==0  % 2D
    [x,y] = meshgrid(linspace(-1,1,sy),linspace(-1,1,sx));
    switch distType
        case 1
            r = max(abs(x),abs(y));
        otherwise
            r = sqrt(x.^2+y.^2);
            if cyl == 0
                r = r/max(abs(r(:)));
            end
    end
else %1d
    r = abs(linspace(-1,1,max(sx,sy)));
end

idx = find(r<radius);

pdf = (1-r).^p.*wpdfs; 
pdf(idx) = 1;
if floor(sum(pdf(:))) > PCTG
    error('infeasible without undersampling dc, increase p');
end

% begin bisection
while(1)
    val = minval/2 + maxval/2;
    pdf = (1-r).^p.*wpdfs + val; 
    pdf(find(pdf>1)) = 1; 
    pdf(idx)=1;
    pdf(find(r>1)) = 0;
    N = floor(sum(pdf(:)));
    if N > PCTG % infeasible
        maxval=val;
    end
    if N < PCTG % feasible, but not optimal
        minval=val;
    end
    if N==PCTG % optimal
        break;
    end
end

% if imSize ~= finalSz
%     pdf = zpad(pdf,finalSz(1),finalSz(2));
% end

if disp
    figure,
    subplot(211), imshow(pdf)
    if sum(imSize==1)==0
        subplot(212), plot(pdf(end/2+1,:));
    else
        subplot(212), plot(pdf);
    end
end