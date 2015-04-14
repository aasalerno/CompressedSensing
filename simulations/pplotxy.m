function pplotxy(r,theta,phi,mkMov,outname)

% PPLOT(THETA,R) makes a plot that will create a line from (r,th) to
% (r,th+pi)

if nargin == 2
    [x,y] = pol2cart(theta,r);
    
    %     [~,loc] = max(abs(r));
    %     plot([-x(loc) x(loc)],[-y(loc) y(loc)]);
    %     hold on
    
    for i = 1:max(size(x))
        plot([-x(i) x(i)],[-y(i) y(i)]);
        hold on
    end
    
    maxval = max([max(x(:)) max(y(:))],'-o');
    axis([-maxval maxval -maxval maxval])
    
elseif nargin >= 3
    
    [x,y,z] = sph2cart(theta,phi,r);
    
    %     [~,loc] = max(abs(r));
    %     plot3([-x(loc) x(loc)],[-y(loc) y(loc)],[-z(loc) z(loc)]);
    %     hold on
    
    for i = 1:max(size(x))
        f1 = plot3([-x(i) x(i)],[-y(i) y(i)],[-z(i) z(i)],'-o');
        hold on
    end
    
    xlabel('X Direction')
    ylabel('Y Direction')
    zlabel('Z Direction')
    
    maxval = max([max(x(:)) max(y(:)) max(z(:))]);
    axis([-maxval maxval -maxval maxval -maxval maxval])
    
    if nargin == 5
    if mkMov == 1
        nFrames = 180;
        for k=1:nFrames
            view([2*k 10]);
            mov(k) = getframe(figure(1));
        end
        movie2avi(mov, outname, 'compression','None', 'fps',10);
    end
    end
end
