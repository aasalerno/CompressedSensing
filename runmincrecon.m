brains = 1:8;
dirs = 1:35;
outbase = '/projects/souris/asalerno/CS/filtRecon';
filttype = 'per';

mincmassfilt(outbase,brains,dirs,filttype);

filttype = 'par';
mincmassfilt(outbase,brains,dirs,filttype);