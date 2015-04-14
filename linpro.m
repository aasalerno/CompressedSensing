function [dataHold,typ] = linpro(dir,rc,cnt)
olddir = pwd;
if isunix()
    cd '/micehome/asalerno/Dropbox/Compressed Sensing'
else
    cd ''
end

if ~strcmp('c',rc)
    rc = 'r';
    if ~strcmp('r',rc)
        warning('RC must be either ''r'' or ''c'', changing to ''r''')
    end
end

if dir<0 || dir>30
    error('Direction value must be between 1 and 30')
end

if dir<10
    dirStr = ['0' num2str(dir)];
else
    dirStr = num2str(dir);
end


typ = {'Full','Circ','Elps_ParCirc','Elps_PerCirc','Par_Circ','Per_Circ','SquareCirc'};

for i = 1:numel(typ)
    data = mincmap([typ{i} '/33_10thick/small_' typ{i} '.' dirStr '.mnc']);
    if i == 1
        if strcmp(rc,'r')
            dataHold = squeeze(zeros([size(data(1,1,:)),numel(typ)]));
        elseif strcmp(rc,'c')
            dataHold = squeeze(zeros([size(data(1,:,1)),numel(typ)]));
        end
        
        if size(dataHold,1) ~= numel(typ)
            dataHold = dataHold';
        end
    end
    
    if strcmp(rc,'r')
        dataHold(i,:) = squeeze(data(1,cnt,:))';
    elseif strcmp(rc,'c')
        dataHold(i,:) = squeeze(data(1,:,cnt));
    end
    
end

typ = {'Full','Circ','Ellipse Par','Ellipse Per','Parallel','Perpendicular','Square'};

cd(olddir)

