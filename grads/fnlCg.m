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
% g0 = zeros(size(x));
% for kk=size(x,3)
%     g0(:,:,kk) = wGradient(x(:,:,kk),params);
% end

g0 = wGradient(x,params);
dx = -g0;
%test = 0;
% iterations

while(1)
    % backtracking line-search
    
    % pre-calculate values, such that it would be cheap to compute the objective
    % many times for efficient line-search
    [FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx, XFMtx, XFMtdx] = preobjective(x, dx, params);
    f0 = objective(FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx, XFMtx, XFMtdx, x,dx, 0, params);
    t = t0;
    [f1, ERRobj, RMSerr]  =  objective(FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx, XFMtx, XFMtdx, x,dx, t, params);
    
    lsiter = 0;
    
    while (f1 > f0 - alpha*t*abs(g0(:)'*dx(:))) & (lsiter<maxlsiter)
        lsiter = lsiter + 1;
        t = t * beta;
        [f1, ERRobj, RMSerr]  =  objective(FTXFMtx, FTXFMtdx, DXFMtx, DXFMtdx,XFMtx, XFMtdx,x,dx, t, params);
        if abs(f1/f0 - 1) < 1e-2
            break;
        end
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
    
%     x1 = x(:,:,1);
%     save(['/projects/muisjes/asalerno/CS/data/dirArtefactData/x_grad.' num2str(cntX) '.mat'],'x1');
%     cntX = cntX +1;
    x = (x + t*dx);
    
    
    %--------- uncomment for debug purposes ------------------------
    fprintf('k = %1.0f, obj: %3e, RMS: %3e, L-S: %1.0f \n',k,f1,RMSerr,lsiter);
    
    %---------------------------------------------------------------
    
    %conjugate gradient calculation
    
    g1 = wGradient(x,params);
    bk = g1(:)'*g1(:)/(g0(:)'*g0(:)+eps);
    g0 = g1;
    dx =  - g1 + bk* dx;
    k = k + 1;
    
    %TODO: need to "think" of a "better" stopping criteria ;-)
    if (k > params.Itnlim) | (norm(dx(:))/numel(dx) < gradToll)
        break;
    else
   %     toc
   %     disp(num2str(norm(dx(:))/numel(dx)));
   %     test = test+1;
    end
%     imshow(params.XFM'*x(:,:,1));
%     pause(0.1)

end


return;