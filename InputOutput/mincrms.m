function rmsDiff = mincrms(file1,file2)

if isa(file1,'char')
    % Read the data in
    data1 = mincread(file1);
    % Make sure we don't have it as uint16
else
    data1 = file1;
end

if isa(file2,'char')
    data2 = mincread(file2);
    
else
    data2 = file2;
end

if isa(data1,'uint16');
    data1 = mincmap(file1);
end
if isa(data2,'uint16');
    data2 = mincmap(file2);
end

norm1 = data1/max(data1(:));
norm2 = data2/max(data2(:));

size(data1)
size(data2)

%rmsDiff = sqrt(abs(norm1).^2 - abs(norm2).^2);
rmsDiff = norm1 - norm2;