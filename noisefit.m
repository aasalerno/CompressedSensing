function [fits,h] = noisefit(data)
% tests if the data fits specific tests. It looks at Lorentzian, gaussian, rayleigh

plotit = 0;
if numel(size(data)) ~= 2
    error('This isn''t an image of noise')
end

if nargin<2
    magN = 100;
end

rayl = @(c1,c2,c3,c4,x) c1.*x./c2.*exp(-(x-c3).^2./c2)+c4;
lor = @(c1,c2,c3,c4,x) c1.*c3./((x - c2).^2 + c3)+c4;
ext = @(c1,c2,c3,c4,x) c1.*exp(c2*(-x-c3)).*exp(-exp(c2*(-x-c3))) + c4;
mb = @(c1,c2,c3,c4,x) c1.*x.^2.*exp(c2.*((x.^2-c3))) + c4;

mag = (double(data(:)));
magMin = min(mag);
magMax = max(mag);
magVar = var(mag);
magMean = mean(mag);
[magData,magRange] = hist(mag,magN);

%fits
SPGauss = [1 magMean sqrt(magVar)];
SPRay = [1 magVar magMean 0];
SPLor = [1 magMean sqrt(magVar)/2 0];
% SPExt = [1 magMean magVar 0];
% SPMB = [1 magMean magVar 0];


try
    [magFitGauss,magRGauss] = fit(magRange',magData','gauss1','StartPoint',SPGauss);
catch
    magRGauss.adjrsquare = -1e99;
end

try
    [magFitRay,magRRay] = fit(magRange',magData',rayl,'Lower',[-Inf 0 -Inf -Inf],'StartPoint',SPRay);
catch
    magRRay.adjrsquare = -1e99;
end

try
    [magFitLor,magRLor] = fit(magRange',magData',lor,'StartPoint',SPLor);
catch
    magRLor.adjrsquare = -1e99;
end
% 
% try
%     [magFitExt,magRExt] = fit(magRange',magData',ext,'StartPoint',SPExt);
% catch
%     magRExt.adjrsquare = -1e99;
% end

% try
%     [magFitMB,magRMB] = fit(magRange',magData',mb,'StartPoint',SPMB);
% catch
%     magRMB.adjrsquare = -1e99;
%    
% end

if plotit || nargout == 2
    figure; hold on;
    bar(magRange,magData);
    h = plot(magFitGauss);
    set(h,'LineWidth',4,'Color','r');
    h = plot(magFitLor);
    set(h,'LineWidth',4,'Color','c');
    h = plot(magFitRay);
    set(h,'LineWidth',4,'Color','b');
%     h = plot(magFitExt);
%     set(h,'LineWidth',4,'Color','k');
%     h = plot(magFitMB);
%     set(h,'LineWidth',4,'Color','g');
    legend('Histogram','Gaussian','Lorentzian','Rayleigh');%,'Extreme Value','Maxwell-Boltz')
    title('Noise Magnitude Fits')
    xlabel('Voxel Intensity')
    ylabel('Counts')
    a = axis;
    ylim([0 a(4)])
end
Rs = [magRLor.adjrsquare magRRay.adjrsquare magRGauss.adjrsquare];% magRExt.adjrsquare];% magRMB.adjrsquare];
typs = {'Lorentzian','Rayleigh','Gaussian'};%,'Extreme Value','Maxwell-Boltz'};
[rsq,ind] = max(Rs);

fits.Lor = magRLor;
fits.Ray = magRRay;
fits.Gauss = magRGauss;
%fits.Ext = magRExt;
%fits.MB = magRMB;
fits.best = typs{ind};
fits.adjrsquare = rsq;