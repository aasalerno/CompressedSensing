function data = sqfilt(data,sampFac)
                % The central square filter
                % With some simple algebra, we can see that the factor is
                % sqrt(sampfac)*sidelength for the proper square size
s = size(data);
[x,y] = meshgrid(linspace(-1,1,s(2)),linspace(-1,1,s(1)));
wid = sqrt(sampFac); % As per the algebra


for i = 1:s(1)
    for j = 1:s(2)
        if abs(x(i,j)) < wid && abs(y(i,j)) < wid
            data(i,j) = 1;
        else
            data(i,j) = 0;
        end
    end
end
