function  res = TVOP()

%res = TVOP()
%
% Implements a spatial finite-differencing operator.
%
% (c) Michael Lustig 2007

% if nargin >= 1
%     res.Aleft = dirInfo.Aleft;
%     res.inds = dirInfo.inds;
%     res.r = dirInfo.r;
% end

res.adjoint = 0;
res = class(res,'TVOP');



