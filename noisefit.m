function fits = noisefit(data)
% tests if the data fits specific tests. It looks at Lorentzian, gaussian, rayleigh
plotit = 0;
if numel(size(data)) ~= 2
    error('This isn''t an image of noise')
end

if nargin<2
    magN = 100;
end

rayl = @(c1,c2,c3,c4,x) c1.*x./c2.*exp(-(x-c3).^2./c2)+c4;
lor = @(c1,c2,c3,c4,x) c1./((x - c2).^2 + c3)+c4;

mag = abs(double(data(:)));
magMin = min(mag);
magMax = max(mag);
magVar = var(mag);
magMean = mean(mag);
[magData,magRange] = hist(mag,magN);

%fits
SPGauss = [1 magMean sqrt(magVar)];
SPRay = [1 magVar magMean 0];
SPLor = [1 magMean magVar 0];
[magFitGauss,magRGauss] = fit(magRange',magData','gauss1','StartPoint',SPGauss);
[magFitRay,magRRay] = fit(magRange',magData',rayl,'Lower',[-Inf 0 -Inf -Inf],'StartPoint',SPRay);
[magFitLor,magRLor] = fit(magRange',magData',lor,'StartPoint',SPLor);

if plotit
    figure; hold on;
    bar(magRange,magData);
    h = plot(magFitGauss);
    set(h,'LineWidth',4,'Color','r');
    h = plot(magFitLor);
    set(h,'LineWidth',4,'Color','c');
    h = plot(magFitRay);
    set(h,'LineWidth',4,'Color','b');
    legend('Histogram','Gaussian','Lorentzian','Rayleigh')
    title('Noise Magnitude Fits')
end
Rs = [magRLor.adjrsquare magRRay.adjrsquare magRGauss.adjrsquare];
typs = {'Lorentzian','Rayleigh','Gaussian'};
[~,ind] = max(Rs);

fits.Lor = magRLor;
fits.Ray = magRRay;
fits.Gauss = magRGauss;
fits.best = typs{ind};
