sz = 180;
sty = 'circ';
% The equation that wlll be followed is exp(-b*D)
b = 1917; % s/mm^2
Dlow = 1e-5; % Low diffusion value
Dhigh = 1e-3; % High diffusion value
ndim = 2; % Number of dimensions for the data
slp = 1; % For the line filter if we use it

l1 = ones(sz)*2e-6;
l2 = ones(sz)*2e-6;



if ndim == 2
    v1 = zeros(sz,sz,2);
    v2 = v1;
elseif ndim == 3
    l3 = ones(sz) * 2e-4;
    
    v1 = zeros(sz,sz,3);
    v2 = v1;
    v3 = v1;
    v3(:,:,1) = ones(sz,sz,1);
end

data = ones(sz);


if ispc()
    gvdir = load('/micehome/asalerno/Documents/GradientVector.txt');
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
l1high = 0.002;

disp('Building Diffusion Map')
if strcmp(sty,'lin')
    % This will build the linear diffusion mask
    
    fil = linefilt(P.D,slp,0.25);
    th = atan(slp);
    for i = 1:sz
        for j = 1:sz
            if fil(i,j)
                P.D(i,j) = Dhigh;
                l1(i,j) = l1high;
                v1(i,j,:) = [cos(th) sin(th)];
                v2(i,j,:) = [-sin(th) cos(th)]; % Ensure orthogonality
            else
                P.D(i,j) = Dlow;
                v1(i,j,:) = [1 0];
                v2(i,j,:) = [0 1];
            end
        end
    end
    
elseif strcmp(sty,'circ')
    fil = circfilt(P.D,0.5) - circfilt(P.D,0.25);
    sq = 1/sqrt(2);
    [x,y] = meshgrid(linspace(-sq,sq,sz),linspace(-sq,sq,sz));
    for i = 1:sz
        for j = 1:sz
            if fil(i,j)
                P.D(i,j) = Dhigh;
                l1(i,j) = l1high;
                v1(i,j,:) = [x(i,j) y(i,j)];
                v2(i,j,:) = [-y(i,j) x(i,j)];
            else
                P.D(i,j) = Dlow;
                v1(i,j,:) = [1 0];
                v2(i,j,:) = [0 1];
            end
        end
    end
    
end

disp('Finding Deff')
%D = zeros(sz,sz,ndim,ndim);
Deff = zeros(size(gvdir,1),sz,sz);

if ndim == 2
    for i=1:sz
        disp(['On ' num2str(i) ' out of ' num2str(sz)])
        for j=1:sz
            
            L = [l1(i,j) 0; 0 l2(i,j)];
            V = [squeeze(v1(i,j,:))'; squeeze(v2(i,j,:))'];
            D = V*L/V;
            
            for k = 1:size(gvdir,1)
                gradvec = squeeze(gvdir(k,:));
                Deff(k,i,j) = gradvec*D*gradvec';
            end
        end
    end
end

disp('Solving for signal values with S0 = 1');
diffData = exp(-b.*Deff);

clearvars -except diffData sz


dataSave = zeros(324,sz,sz);

disp('Creating and saving data')
tic
for i = 1:size(diffData,1)
    for j = 1:size(dataSave,1)
        dataSave(j,:,:) = diffData(i,:,:);
    end
    [datamin,datamax] = mincmaxmin(dataSave,3);
    if i<10
        stri = ['0' num2str(i)];
    else
        stri = num2str(i);
    end
    disp(['Writing ' stri ' out of 30'])
    mincwrite(['/projects/muisjes/asalerno/jacob/DW_Recon.6.' stri '.mnc'],...
        ['/projects/muisjes/asalerno/CS/data/simulation/Circ_' stri '.mnc'],...
        dataSave,datamax,datamin)
end
toc