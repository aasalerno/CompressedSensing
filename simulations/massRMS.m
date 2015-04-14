% massRMS

% Does all the RMS differences

dirs = dir('./');
dirNames = {};
for i = 3:size(dirs,1)
    if dirs(i).isdir 
        dirNames = {dirNames{:}, dirs(i).name};
    end
end

typ = '/33_10thick/small_';

diffs = zeros(1,length(dirNames));       

ref = ['Full' typ 'Circ'];

tmploc = find(strcmp('Full',dirNames));
dirNames = circshift(dirNames,[0,tmploc]);

for i = 1:length(dirNames)
    cmp = [dirNames{i} typ dirNames{i}];
    if strcmp(dirNames{i},'Full')
        cmp = ref;
    end
    diffs(i) = usRMS(ref,cmp,30);
end

bar(diffs);
set(gca,'XTickLabel',dirNames)