function logim(data,xdata,ydata)

if nargin < 3
    error('Needs Xdata and YData, or ranges!')
end

if length(xdata) == 2
    xdata = logspace(10^xdata(1),10^xdata(2),size(data,1));
end

if length(ydata) == 2
    ydata = logspace(10^ydata(1),10^ydata(2),size(data,2));
end

surf(xdata,ydata,zeros(size(data)),'Cdata',data,'LineStyle','none')
view(0,90)
set(gca,'xscale','log')
set(gca,'yscale','log')
axis tight