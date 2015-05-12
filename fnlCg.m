function x = fnlCg(x,params)
%-----------------------------------------------------------------------
%
% res = fnlCg(x0,params)
%
% implementation of a L1 penalized non linear conjugate gradient reconstruction
%
% The function solves the following problem:
%
% given k-space measurments y, and a fourier operator F the function
% finds the image x that minimizes:
%
% Phi(x) = ||F* W' *x - y||^2 + lambda1*|x|_1 + lambda2*TV(W'*x)
%
%
% the optimization method used is non linear conjugate gradient with fast&cheap backtracking
% line-search.
%
% (c) Michael Lustig 2007
%-------------------------------------------------------------------------


% line search parameters
maxlsiter = params.lineSearchItnlim ;
gradToll = params.gradToll ;
alpha = params.lineSearchAlpha;
beta = params.lineSearchBeta;
t0 = params.lineSearchT0;
k = 0;
t = 1;

% copmute g0  = grad(Phi(x))
g0 = zeros(size(x));
for kk=size(x,3)
    g0(:,kk) = wGradient(x(:,:,kk),params);
end
dx = -g0;

% iterations
while(1)
    
    % backtracking line-search
    
    % pre-calculate values, such that it would be cheap to compute the objective
    % many times for efficient line-search
    [FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx] = preobjective(x, dx, params);
    f0 = objective(FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx,x,dx, 0, params);
    t = t0;
    [f1, ERRobj, RMSerr]  =  objective(FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx,x,dx, t, params);
    
    lsiter = 0;
    
    while (f1 > f0 - alpha*t*abs(g0(:)'*dx(:))) & (lsiter<maxlsiter)
        lsiter = lsiter + 1;
        t = t * beta;
        [f1, ERRobj, RMSerr]  =  objective(FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx,x,dx, t, params);
    end
    
    if lsiter == maxlsiter
        disp('Reached max line search,.... not so good... might have a bug in operators. exiting... ');
        return;
    end
    
    % control the number of line searches by adapting the initial step search
    if lsiter > 2
        t0 = t0 * beta;
    end
    
    if lsiter<1
        t0 = t0 / beta;
    end
    
    x = (x + t*dx);
    
    %--------- uncomment for debug purposes ------------------------
    % disp(sprintf('%d   , obj: %f, RMS: %f, L-S: %d', k,f1,RMSerr,lsiter));
    
    %---------------------------------------------------------------
    
    %conjugate gradient calculation
    
    g1 = wGradient(x,params);
    bk = g1(:)'*g1(:)/(g0(:)'*g0(:)+eps);
    g0 = g1;
    dx =  - g1 + bk* dx;
    k = k + 1;
    
    %TODO: need to "think" of a "better" stopping criteria ;-)
    if (k > params.Itnlim) | (norm(dx(:)) < gradToll)
        break;
    end
    
end


return;