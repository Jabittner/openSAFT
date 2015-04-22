function [ curscan ] = a_plotSurface( Z,curscan )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here

figure;plot(curscan.surf_arrival_index.*10^-6, curscan.indx_to_dist,'o');
title('Shear Arrival vs Distance Traveled')
figure;    
[qpoly polystat] = polyfit(curscan.surf_arrival_index.*10^-6, curscan.indx_to_dist, 1);
% Plot the residuals of the surface wave velocity
qpolyval= polyval(qpoly,curscan.surf_arrival_index.*10^-6);
% not sure if this should be percent or raw residual
qpolyrespercent=((qpolyval-curscan.indx_to_dist));%./curscan.indx_to_dist)*100

    for i=1:length(curscan.indx_to_rec)
        curscan.spaceresult(curscan.indx_to_rec(i), ...
            curscan.indx_to_trans(i))= qpolyrespercent(i);
    end
    imagesc(curscan.spaceresult);
    xlabel('Transmitter Number');
    ylabel('Reciever Number');
    title('Residual of Linear Shear Surface Propigation Velocity');
    set(gca,'XTick',0:12);
    grid on
    set(gca,'xdir','reverse')
    
end

