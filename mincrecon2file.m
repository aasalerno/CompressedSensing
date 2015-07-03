function mincrecon2file(fileSuf,infile,outfile)
% Simple way to write the data to file when doing a mincrecon, in a
% seperate file so that we can still run a mincrecon without worrying about
% it being written to file.

data = mincrecon(fileSuf);
data = abs(data);

ind = mincind(infile,'dsl');
[datamin,datamax] = mincmaxmin(data,ind);

mincwrite(infile,outfile,data,datamax,datamin);