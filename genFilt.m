function [filt,readloc] = genFilt(type,data,filename,sampFac,loc,gvdir)
% This function is built to generate the filter for undersampling. As it
% stands, it will zero fill the rest instead of trying to put some
% randomness to it (that is, there is no data except for where we put this
% filter) - it is NOT a PDF.
%
% Anthony Salerno
showit = 1;
graddir = load('GradientVector.txt');
graddir = [graddir(:,loc(1)) graddir(:,loc(2)) graddir(:,loc(3))];

% Get which gradient we're working with by Splitting the name
nameSpl = strsplit(filename,'.');
gradvec = graddir(round(str2num(nameSpl{end-1})),:); % Get the gradient vector so we know which one we need

if gradvec > 30
    disp('No gradient. Do not undersample');
else
    readloc = find(ismember('dro',gvdir)); % This tells us which dimension the readout is on for our dataset, i.e. 1, 2, or 3
    tester = 1:3;
    tester = find(~ismember(tester,readloc));
    gradvec = gradvec(tester); % Gives us only the values for the non readout direction
    % Quick and dirty way to do a projection
    
    % Here is where we will have the heart of the code - this is where we will
    % actually do the undersampling
    % As of 01/06/15 the method will only have the linear undersampling as the
    % perpendicular value of the gradient vector
    if strcmp('per',type)
        gradvec = [-gradvec(2) gradvec(1)]; % Here is where we make it perpendicular
        disp('Creating a "perpendicular to gradient direction" filter')
    else
        disp('Creating a "parallel to gradient direction" filter')
    end
    
    if all(gradvec == [0 0])
        % We use the circle filter in this case
    else
        slp = gradvec(2)/gradvec(1);
        n = size(data);
        
        
        if readloc == 1
            slicesz = ones(n(2),n(3)); %What is the size of each slice
            if strcmp('per',type) || strcmp('par',type)
                filt = linefilt(slicesz,slp,sampFac); % Make the filter that we will use
                
            elseif strcmp(type,'lores')
                filt = sqfilt(slicesz,sampFac);
            elseif strcmp(type,'circ')
                filt = circfilt(slicesz,sampFac);
            end
            
            filt = uint16(filt);
            
        elseif readloc == 2
            slicesz = ones(n(1),n(3)); %What is the size of each slice
            filt = linefilt(slicesz,slp,sampFac); % Make the filter that we will use
            filt = uint16(filt);
            
        elseif readloc == 3
            slicesz = ones(n(1),n(2)); %What is the size of each slice
            filt = linefilt(slicesz,slp,sampFac); % Make the filter that we will use
            filt = uint16(filt);
        end
    end
end



if showit==1
    imshow(filt,[])
end