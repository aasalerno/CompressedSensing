sz = 128;
sty = 'circ';
% The equation that wlll be followed is exp(-b*D)
b = 1917; % s/mm^2
Dlow = 0.5e-3; % Low diffusion value
Dhigh = 1e-3; % High diffusion value
ndim = 3; % Number of dimensions for the data
slp = 1; % For the line filter if we use it
sampFac = 0.50;

l1 = ones(sz)*Dhigh;
l2 = ones(sz)*Dhigh;



if ndim == 2
    v1 = zeros(sz,sz,2);
    v2 = v1;
elseif ndim == 3
    l3 = ones(sz) * 1e-3;
    
    v1 = zeros(sz,sz,3);
    v2 = v1;
    v3 = v1;
    %v3(:,:,1) = ones(sz,sz,1);
end

data = ones(sz);


if ispc()
    gvdir = load('C:\Users\saler_000\Documents\GitHub\CompressedSensing\GradientVector.txt');
elseif isunix()
    gvdir = load('/projects/muisjes/asalerno/CS/Code/CompressedSensing/GradientVector.txt');
else
    str = input('Where is the gradient vector matrix? Use an absolute path.');
    load(str);
end


if ndim == 2
    locs = [1 3];
    gv = [gvdir(:,locs(1)) gvdir(:,locs(2))];
    for i = 1:size(gvdir,1)
        th = atan(gv(i,2)/gv(i,1));
        gv(i,:) = [cos(th) sin(th)];
    end
    gvdir = gv;
end


% Build the data structure
P.D = ones(sz); % diffusion matrix
P.data = ones(sz); % isotropic data

% Use a value for the diffusion that is seen in the data (max)
l2low = 0.5e-3;

disp('Building Diffusion Map')
if strcmp(sty,'lin')
    % This will build the linear diffusion mask
    %
    %     fil = linefilt(P.D,slp,0.25);
    %     th = atan(slp);
    %     for i = 1:sz
    %         for j = 1:sz
    %             if fil(i,j)
    %                 P.D(i,j) = Dhigh;
    %                 l1(i,j) = l1high;
    %                 v1(i,j,:) = [cos(th) sin(th)];
    %                 v2(i,j,:) = [-sin(th) cos(th)]; % Ensure orthogonality
    %             else
    %                 P.D(i,j) = Dlow;
    %                 v1(i,j,:) = [1 0];
    %                 v2(i,j,:) = [0 1];
    %             end
    %         end
    %     end
    
elseif strcmp(sty,'circ')
    fil = circfilt(P.D,0.5) - circfilt(P.D,0.40);
    sq = 1/sqrt(2);
    [x,y] = meshgrid(linspace(-sq,sq,sz),linspace(-sq,sq,sz));
    r = sqrt(x.^2 + y.^2);
    for i = 1:sz
        for j = 1:sz
            if fil(i,j)
                P.D(i,j) = Dhigh;
                l2(i,j) = l2low;
                l3(i,j) = l2low;
                v1(i,j,:) = [x(i,j) y(i,j) 0];
                v2(i,j,:) = [-y(i,j) x(i,j) 0];
            elseif r(i,j) < 0.315 && r(i,j) > 0.28
                a = 1-(cos(pi*1/2/(0.315-0.28)*r(i,j))).^2;
                P.D(i,j) = a*Dhigh;
                l2(i,j) = l2(i,j)/2+a*l2low;
                l3(i,j) = l2(i,j);
                v1(i,j,:) = [x(i,j) y(i,j) 0];
                v2(i,j,:) = [-y(i,j) x(i,j) 0];
                fil(i,j) = 1-a;
            elseif r(i,j) < 0.2580 && r(i,j) > 0.22
                a = 1-(cos(pi*1/2/-(0.258-0.22)*(r(i,j)-0.258))).^2;
                P.D(i,j) = a*Dhigh;
                l2(i,j) = l2(i,j)/2+a*l2low;
                l3(i,j) = l2(i,j);
                v1(i,j,:) = [x(i,j) y(i,j) 0];
                v2(i,j,:) = [-y(i,j) x(i,j) 0];
                fil(i,j) = 1-a;
            else
                P.D(i,j) = Dlow;
                v1(i,j,:) = [1 0 0];
                v2(i,j,:) = [0 1 0];
            end
            v3(i,j,:) = [0 0 1];
        end
    end
    
end

disp('Finding Deff')
%D = zeros(sz,sz,ndim,ndim);
Deff = zeros(size(gvdir,1),sz,sz);

if ndim == 3
    for i=1:sz
        disp(['On ' num2str(i) ' out of ' num2str(sz)])
        for j=1:sz
            
            L = [l1(i,j) 0 0; 0 l2(i,j) 0; 0 0 l3(i,j)];
            V = [squeeze(v1(i,j,:))'; squeeze(v2(i,j,:))'; squeeze(v3(i,j,:))'];
            D = V*L/V;
            
            for k = 1:size(gvdir,1)
                gradvec = squeeze(gvdir(k,:));
                Deff(k,i,j) = gradvec*D*gradvec';
            end
        end
    end
end

disp('Solving for signal values with S0 = 1');
safeData = exp(-b.*Deff);
[x,y] = meshgrid(linspace(-1,1,sz),linspace(-1,1,sz));
r = sqrt(x.^2+y.^2);
r = r <= 1;
for i = 1:30
    ruse(i,:,:) = reshape(r,[1 size(r)]);
end
safeData = ruse.*safeData;

%for cc = 1:3
cc = 6;
diffData = safeData;

dataSave = zeros(4,sz,sz);

disp('Creating and saving data')
tic
for i = 1:size(diffData,1)
    
    diffData(i,:,:) = reshape(fftshift(fft2(squeeze(diffData(i,:,:)))),size(diffData(i,:,:)));
    
    if cc == 1 % Par
        fil = reshape(linefilt(squeeze(diffData(i,:,:)),-gvdir(i,2)/gvdir(i,1),sampFac),size(diffData(i,:,:)));
        uns = 'Par_';
    elseif cc == 2 % Per
        fil = reshape(linefilt(squeeze(diffData(i,:,:)),gvdir(i,1)/gvdir(i,2),sampFac),size(diffData(i,:,:)));
        uns = 'Per_';
    elseif cc == 3 % No undersample
        fil = ones(1,sz,sz);
        uns = 'Full';
    elseif cc == 4;
        fil = reshape(circfilt(squeeze(diffData(i,:,:)),4*sampFac),[1 sz sz]);
        uns = 'Circ';
    elseif cc == 5;
        fil = reshape(sqfilt(squeeze(diffData(i,:,:)),4*sampFac),[1 sz sz]);
        uns = 'Square';
    elseif cc == 6;
        fil = reshape(elpsfilt(squeeze(diffData(i,:,:)),-gvdir(i,2)/gvdir(i,1),sampFac,2),[1 sz sz]);
        uns = 'Elps_Par';
    elseif cc == 7
        fil = reshape(elpsfilt(squeeze(diffData(i,:,:)),gvdir(i,1)/gvdir(i,2),sampFac,2),[1 sz sz]);
        uns = 'Elps_Per';
    end
    
    
    
    diffData(i,:,:) = reshape(ifft2(squeeze(diffData(i,:,:).*fil)),size(diffData(i,:,:)));
    
    for j = 1:size(dataSave,1)
        dataSave(j,:,:) = diffData(i,:,:);
    end
    
    
    
    
    
    
    [datamin,datamax] = mincmaxmin(abs(dataSave),3);
    if i<10
        stri = ['0' num2str(i)];
    else
        stri = num2str(i);
    end
    disp(['Writing ' stri ' out of 30'])
    if isunix()
        disp(['Writing to /projects/muisjes/asalerno/CS/data/simulation/' uns 'Circ/' num2str(round(100*sampFac)) '_10thick/small_' uns 'Circ.' stri '.mnc']);
        mincwrite('/micehome/asalerno/Documents/CompressedSensing/simulations/test.mnc',...
            ['/projects/muisjes/asalerno/CS/data/simulation/' uns '/' num2str(round(100*sampFac)) '_10thick/small_' uns 'Circ.' stri '.mnc'],...
            abs(dataSave),datamax,datamin)
    elseif ispc()
        disp(['Writing to C:\Users\saler_000\Documents\GitHub\CompressedSensing\simulations\' uns 'Circ\' num2str(round(100*sampFac)) '_10thick/small_' uns 'Circ.' stri '.mnc']);
        mincwrite('C:\Users\saler_000\Documents\GitHub\CompressedSensing\simulations\test.mnc',...
            ['C:\Users\saler_000\Documents\GitHub\CompressedSensing\simulations\' uns '\' num2str(round(100*sampFac)) '_10thick\small_' uns 'Circ.' stri '.mnc'],...
            abs(dataSave),datamax,datamin)
    end
end
toc
%end

if 1 == 0
    system(['OCCIviewer /projects/muisjes/asalerno/CS/data/simulation/Circ/' num2str(round(100*sampFac)) '_10thick/small_Circ.10.mnc ' ...
        '/projects/muisjes/asalerno/CS/data/simulation/Per_Circ/' num2str(round(100*sampFac)) '_10thick/small_Per_Circ.10.mnc ' ...
        '/projects/muisjes/asalerno/CS/data/simulation/Par_Circ/' num2str(round(100*sampFac)) '_10thick/small_Par_Circ.10.mnc']);
end