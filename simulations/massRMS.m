function b = massRMS(brain)
% massRMS
%
% Does all the RMS differences
%
% dirs = dir('./');
% dirNames = {};
% for i = 3:size(dirs,1)
%     if dirs(i).isdir
%         dirNames = {dirNames{:}, dirs(i).name};
%     end
% end

%cd /micehome/asalerno/Documents/CompressedSensing/simulations
load /micehome/asalerno/Documents/CompressedSensing/simulations/ROI
dirNames = {'Full','circ','square','par','per','elps_par','elps_per'};
typ = '/projects/muisjes/asalerno/CS/filtRecon/filtX/small_Recon_';

diffs = zeros(1,length(dirNames));

ref = [typ 'Full.' num2str(brain)];

tmploc = find(strcmp('Full',dirNames));
dirNames = circshift(dirNames,[0,tmploc]);

for i = 1:length(dirNames)
    disp(dirNames{i})
    cmp = [typ dirNames{i} '.' num2str(brain)];
    if strcmp(dirNames{i},'Full')
        cmp = ref;
    end
    diffs(i) = usRMS(ref,cmp,30,ROI);
    
end

%bar(diffs);
%figure
b = diffs([1 4 5 3 2 6 7]);
c = {dirNames{[1 4 5 3 2 6 7]}};
bar(b)
set(gca,'XTickLabel',c)
cd /projects/muisjes/asalerno/CS/filtRecon/filtX


