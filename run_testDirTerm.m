sigma = 0.1:0.1:1;
dirWeights = logspace(-2,0,11);
thresh = [0 sigma];

cd('/micehome/asalerno/Documents/CompressedSensing');
addpath(genpath('./'));
setmail

parfor i = 1:numel(dirWeights)
    try
        %starttime = datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z');
        for j = 1:numel(sigma)
            for k = 1:numel(thresh)
                disp([num2str(i) num2str(j) num2str(k)])
                testDirTerm(dirWeights(i),sigma(j),thresh(k));
            end
        end
    catch
        sendmail('salerno.anthony92@gmail.com','Code Failed','Code failed')
    end
end