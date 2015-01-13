function y = mincfft(data,n,dim,maxdata,mindata)
% Does a 3D fft and FFT shifts the data
%
% data - either the filename or data that we want to do the fft over
% n - number of dimensions to do the fft over (i.e. 1D fft, 2D fft, 3D fft)
% dim - in the case that n == 1, it is the dimension that we do the fft
%       over
%     - in the case that n == 2, it is the dimension that we do NOT do the
%     fft over. That is, that is the dimension that we treat as the slices.

if nargin < 3
    dim = 3;
end

if nargin < 4 && ~isa(data,'char') && ~isa(data,'double')
    error('Need to specify maxima and minima of data')
end

if isa(data,'char')
    filename = data;
    data = mincmap(filename);
elseif isa(data,'uint16')
    data = mincmap(data,maxdata,mindata,3);
end

N = size(data);
disp(['Doing a ',num2str(n),'D FFT'])
if n == numel(N); % FULL fft
    y = fftn(data);
    y = fftshift(y);
elseif n == 1 % 1D fft over the dimension dim
    y = fft(data,[],dim);
    y = fftshift(y);
elseif n == 2 % 2D fft in a for loop going through the dimension of choice
    y = zeros(size(data));
    if dim == 1
        for i = 1:N(dim)
            fftval = fft2(squeeze(data(i,:,:)));
            fftval = fftshift(fftval);
            y(i,:,:) = reshape(fftval,[1 size(fftval)]);
        end
    elseif dim == 2
        for i = 1:N(dim)
            fftval = fft2(squeeze(data(:,i,:)));
            fftval = fftshift(fftval);
            y(:,i,:) = reshape(fftval,[size(fftval,1) 1 size(fftval,2)]);
        end
    elseif dim == 3
        for i = 1:N(dim)
            fftval = fft2(squeeze(data(:,:,i)));
            fftval = fftshift(fftval);
            y(:,:,i) = reshape(fftval,[size(fftval) 1]);
        end
    end
end





