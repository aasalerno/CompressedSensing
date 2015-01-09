function data = linefilt(data,slp,sampFac)
%data = rand(200,200);
s = size(data);
%slp = 0;
[x,y] = meshgrid(linspace(-1,1,s(2)),linspace(-1,1,s(1)));
wid = sampFac; %0.5 approximated from algebra from the perpendicular/parallel case

if ~(isnan(slp)||isinf(abs(slp)))
    lnpts = [[0 0 0];[1,slp,0]];
end


for i = 1:s(1)
    for j = 1:s(2)
        if (isnan(slp)||isinf(abs(slp)))
            if abs(x(i,j)) < wid
                data(i,j) = 1;
            else 
                data(i,j) = 0;
            end
            
        else
            if point_to_line([x(i,j),y(i,j),0],lnpts(1,:),lnpts(2,:)) < wid
                data(i,j) = 1;
            else
                data(i,j) = 0;
            end
        end
    end
end

% a = imagesc(data);
% axis off
% colormap(gray)
% xlabel('k_x')
% ylabel('k_y')

% 
% diff = sum(data(:))/prod(size(data));
% 
% disp(['The actual undersample factor is ',num2str(diff*100),'%.'])