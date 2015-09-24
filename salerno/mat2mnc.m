function mat2mnc(invar,outfile)

if ~strcmp(outfile(end-3:end),'.mnc')
    outfile = [outfile '.mnc'];
end

N = size(invar);

if numel(N) == 2
    N = [N 1];
end
%system(['rm ' outfile '.mnc ' outfile '.nrrd'])
system(['mincreshape  -start 0,0,0 -count ' num2str(N(1)) ','  num2str(N(2)) ',' num2str(N(3)) ' /axiom2/projects/software/mouse-brain-atlases/Dorr_2008/ex-vivo/Dorr_2008_on_VVW_Sert_v1_average.mnc  ' outfile '.mnc']);
system(['minc_modify_header -dinsert xspace:step=1 -dinsert yspace:step=1 -dinsert zspace:step=1 ' outfile '.mnc ']);
system(['itk_convert ' outfile '.mnc ' outfile '.nrrd']);
[inputdata, inputmeta] = nrrdread([ outfile '.nrrd']);

inputdata = permute(invar,[3 2 1]);

nrrdWriter([outfile '_out.nrrd'], inputdata, [0.056,0.056,0.056], [-6.27,-8.19,-4.2], inputmeta.encoding);

if exist(outfile,'file')
    test = input('This file exists, please rename it, otherwise, it will clobber.\n');
    if ~isempty(test)
        outfile = test;
    end
end

system(['itk_convert --clobber ' outfile '_out.nrrd ' outfile]);


%system(['mincconcat -concat_dimension vector_dimension x_component_of_displacement_Matlab_out.mnc y_component_of_displacement_Matlab_out.mnc z_component_of_displacement_Matlab_out.mnc' outfile])
%system('rm x_component_of_displacement_Matlab_out.mnc y_component_of_displacement_Matlab_out.mnc z_component_of_displacement_Matlab_out.mnc')
system(['rm ' outfile '.mnc ' outfile '.nrrd ' outfile '_out.nrrd'])