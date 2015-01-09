function data = circlfilt(data,sampFac)
                % The central circle
                % With some simple algebra, we can see that the factor is
                % sqrt(sampfac/pi)*sidelength for the proper radius size
s = size(data);
[x,y] = meshgrid(linspace(-1,1,s(2)),linspace(-1,1,s(1)));
wid = sampFac/pi; % As per the algebra


for i = 1:s(1)
    for j = 1:s(2)
        if (x(i,j)^2 + y(i,j)^2) <= wid
            data(i,j) = 1;
        else
            data(i,j) = 0;
        end
    end
end
