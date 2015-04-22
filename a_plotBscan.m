function [ curscan ] = a_plotBscan(Z, curscan )
%a_plotBscan This function generates a B-Scan estimate based on a sensor
%matrix signals Z and curscan struct of values. 
%   a_plotBscan constructs the x-y matrix by performing a rough numerical
%   intergration over all of the A-Scan signals. Ultimately a scaled image
%   is plotted. No actual integration is performed and the sampling rate is
%   assume to be significantly small enough to make summation a reasonable
%   approximation. (this was not checked it just made things much faster
%   and did not look significantly different). 


%    This file is part of OpenSAFT.
%    OpenSAFT is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.

%    OpenSAFT is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.

%    You should have received a copy of the GNU General Public License
%    along with OpenSAFT.  If not, see <http://www.gnu.org/licenses/>.


width=500; % must be greater than 301
jend = 66;
b1 = zeros(width,width,jend);

for j=1:jend
    % a podization factor
    x_r_loc=(width/2)-150+curscan.indx_to_rec(j)*30;
    x_t_loc=(width/2)-150+curscan.indx_to_trans(j)*30;
    z_k = repmat([1:width]',1,width);  % depth from surface
    x_r = repmat(x_r_loc-[1:width],width,1); % horz dist from rec
    x_t = repmat(x_t_loc-[1:width],width,1); % horz dist from trans
    apodr = (z_k)./(sqrt(1*x_r.^2+(z_k).^2)); % directly from appendix ...
                                        %(reasonable propagation assumption)
    apodt = (z_k)./(sqrt(1*x_t.^2+(z_k).^2));
    apod=apodr.*apodt;
    % takes in to account send and rec
    dist = sqrt(z_k.^2+x_r.^2)+sqrt(z_k.^2+x_t.^2); %dist from pt to t/r
    xyindx = round((dist*10^-3)/(curscan.Est_Vel_Shear(1)*1e-6)); % dist to time usec
    S = reshape(Z(xyindx(:),j), width, width); % time to approx. signal 
    b1(:,:,j) = S.*apod; % x-y fit to propagation estimate apod
end
bsum = sum(b1,3); % sum all by 3rd axis 
Amplitude_DepthShift = round(0.5*(1/50000)*curscan.Est_Vel_Shear(1)*1000);
bsum = bsum(Amplitude_DepthShift:end, :);
curscan.Z_bscan=bsum; % save in global spot
curscan.Z_bscan_nohilbert=curscan.Z_bscan;
curscan.Z_bscan=abs(hilbert(curscan.Z_bscan)); % hilbert

curscan.Z_bscan([1:5],(width/2-150)+[1:12]*30)=max(max(bsum)); % make ticks for sensor locations
curscan.Z_bscan([1:5],(width/2-150)+[1:12]*30+1)=max(max(bsum)); % make it 2px wide
% now it's just making it look good

curscan.Z_bscan = fliplr(curscan.Z_bscan); % did it backwards
%figure; 
colormap('jet');
imagesc(curscan.Z_bscan, [min(min(curscan.Z_bscan)), max(max(curscan.Z_bscan))*.7]);
title('B-Scan Estimation');
end

