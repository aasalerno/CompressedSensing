function gradObj = gOBJ(x,params)
% computes the gradient of the data consistency

	gradObj = params.XFM*(params.FT'*(params.FT*(params.XFM'*x) - params.data));

gradObj = 2*gradObj ;