function res = angioSym(imSize, xradVec, yradVec, ampVec)

% res = angioSym(imSize, xradVec, yradVec, ampVec)

res = zeros(imSize);
map = zeros(imSize);
for n=1:length(xradVec)

	tmp = ellipsoid(imSize,xradVec(n),yradVec(n));
	while sum((tmp(:) + map(:))>1)
		tmp = ellipsoid(imSize,xradVec(n),yradVec(n));
	end
	map = tmp + map;
	res = res + tmp*ampVec(n);
end




function res = ellipsoid(imSize,xrad,yrad)
	ang = (rand(1)-0.5)*2*pi;

	[x,y] = meshgrid(-imSize(2)/2:imSize(2)/2-1,-imSize(1)/2:imSize(2)/2-1);
	b = sqrt(2/(1+xrad^2/yrad^2));
	a = b*xrad/yrad;

	xr = a*(x*cos(ang) - y*sin(ang));
	yr = b*(y*cos(ang) + x*sin(ang));

	coord = 1.1*(rand(1,2)-0.5).*([max(abs(xr(:))), max(abs(yr(:)))]);
	r = sqrt((xr-coord(1)).^2 + (yr-coord(2)).^2);
	res = r < yrad;
	while (sum(res(:))==0)
		coord = sqrt(2)*(rand(1,2)-0.5).*([max(abs(xr(:))), max(abs(yr(:)))]);
		r = sqrt((xr-coord(1)).^2 + (yr-coord(2)).^2);
		res = r < yrad;
	end


