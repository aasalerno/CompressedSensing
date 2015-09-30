dirs = load('GradientVectorMag.txt');
load('30DirSamp.mat')

[x,y] = meshgrid(linspace(-1,1,180),linspace(-1,1,180));
r = sqrt(x.^2 + y.^2);
r = zpad(r,256,256);
[x,y] = find((r<1 & r>0));

dp = zeros(30);
for i = 1:30
    for j = 1:30
        dp(i,j) = abs(dot(dirs(i,:),dirs(j,:)));
    end
end

[d,inds] = sort(dp,2);
d = fliplr(d);
inds = fliplr(inds);

load('brain.6-zpad-ksp.mat')

dis = (256-180)/2;

im_tog = im;
for i = 1:30
    for j = 1:length(x)
        j
        cnt = 1;
        if ~samp(x(j),y(j),i)
            while cnt < 5 && ~im(x(j),y(j),inds(i,cnt))
                cnt = cnt+1;
            end
            im_tog(x,y,i) = im(x,y,inds(i,cnt));
        end
        
    end
end