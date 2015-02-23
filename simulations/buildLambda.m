data = ones(128,128);
sq = 1/sqrt(2);
[x,y] = meshgrid(linspace(-sq,sq,128),linspace(-sq,sq,128));
locs = [2 3];
gvdir = load('/micehome/asalerno/Documents/GradientVector.txt');

if 1 == 1
    % This will build the linear diffusion mask
    
    
