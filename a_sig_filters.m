function [ curscan ] = a_sig_filters( curscan )
    % Low Pass Filter Here 
    fs = 1e6;
    Fstop1 = 10E3;
    Fpass1 = 20E3; 
    Fpass2 = 80E3; 
    Fstop2 = 90E3;
    Rp = 0.1;
    As = 50;
    [N,wn] = ellipord([Fpass1 Fpass2]./(fs/2),[Fstop1 Fstop2]./(fs/2),Rp,As);
    [b,a] = ellip(N,Rp,As,wn);
    curscan.Z_raw_filt=filtfilt(b,a,curscan.Z_raw); % apply band pass

    %find Shear arrivals 
    [curscan.surf_arrival_val curscan.surf_arrival_index]=max( ...
       curscan.Z_raw_filt(2:300,:));
%     for jb=1:66
%         [curscan.surf_arrival_val(jb) curscan.surf_arrival_index(jb)]= ...
%             findpeaks(-curscan.Z_raw_filt(2:300,jb), 'minpeakheight', 300,'NPEAKS' , 1);
%     end
    
    % 200 experimentally set 360mm travel min Vr is ~1800m/s

    % make index of signal# to transmitter/reciever/distance 
    l=0;
    for k=11:-1:1 % num of transmitters 
        for j=1:k % each transmitter
            curscan.indx_to_trans(l+j)=j+1+(11-k); % Z index to trans num
            curscan.indx_to_rec(l+j)=12-k;% Z index to reciever num
        end
        l=l+k;
    end
    curscan.indx_to_dist=(curscan.indx_to_trans-curscan.indx_to_rec).*30e-3; %mm
    
    % using arrival and distance estimate Shear wave
    curscan.Est_Vel_Shear= ...
        polyfit(curscan.surf_arrival_index.*10^-6, curscan.indx_to_dist, 1);
        % linear fit for the slope between time and distance of R arrival
    
    % Debug Line
%      figure;    plot(curscan.surf_arrival_val./(2*pi*curscan.indx_to_dist), curscan.indx_to_dist,'o');
%      figure;    plot(curscan.surf_arrival_index.*10^-6, curscan.indx_to_dist,'o');
%      hold on;
%      title('Shear Arrival vs Distance Traveled')
%      % Find x values for plotting the fit based on xlim
%      xdata1=curscan.surf_arrival_index.*10^-6;
%      ydata1=curscan.indx_to_dist;
%     axesLimits1 = xlim;
%     xplot1 = linspace(axesLimits1(1), axesLimits1(2));
%     % Preallocate for "Show equations" coefficients
%     coeffs1 = cell(1,1);
%     fitResults1 = polyfit(xdata1, ydata1, 1);
%     % Evaluate polynomial
%     yplot1 = polyval(fitResults1, xplot1);
%     % Save type of fit for "Show equations"
%     fittypesArray1(1) = 2;
%     % Save coefficients for "Show Equation"
%     coeffs1{1} = fitResults1;
%     %    Plot the fit
%     fitLine1 = plot(xplot1,yplot1,'DisplayName','   linear',...
%     'Tag','linear',...
%     'Color',[1 0 0]); 
%     % "Show equations" was selected
%     showEquations(fittypesArray1, coeffs1, 4,gca);
% 
%      
     
     
    % figure;

    % need propigation model
     curscan.time_to_dist=(0.5*curscan.Est_Vel_Shear(1)*10^-6)*[1:length(curscan.indx_to_dist)];
     qmask=repmat(curscan.surf_arrival_index+25,2048,1)<repmat(1:2048,66,1)';
    % cut out surface wave

     curscan.Z_noSurface=qmask.*curscan.Z_raw_filt;
    %curscan.Z_noSurface=curscan.Z_raw_filt_nodaqnoise;
    
    curscan.Z_done = curscan.Z_noSurface; % use this moving forward
end

%-------------------------------------------------------------------------%
function showEquations(fittypes1, coeffs1, digits1, axesh1)
%SHOWEQUATIONS(FITTYPES1,COEFFS1,DIGITS1,AXESH1)
%  Show equations
%  FITTYPES1:  types of fits
%  COEFFS1:  coefficients
%  DIGITS1:  number of significant digits
%  AXESH1:  axes

n = length(fittypes1);
txt = cell(length(n + 1) ,1);
txt{1,:} = ' ';
for i = 1:n
    txt{i + 1,:} = getEquationString(fittypes1(i),coeffs1{i},digits1,axesh1);
end
text(.05,.95,txt,'parent',axesh1, ...
    'verticalalignment','top','units','normalized');
end

%-------------------------------------------------------------------------%
function [s1] = getEquationString(fittype1, coeffs1, digits1, axesh1)
%GETEQUATIONSTRING(FITTYPE1,COEFFS1,DIGITS1,AXESH1)
%  Get show equation string
%  FITTYPE1:  type of fit
%  COEFFS1:  coefficients
%  DIGITS1:  number of significant digits
%  AXESH1:  axes

if isequal(fittype1, 0)
    s1 = 'Cubic spline interpolant';
elseif isequal(fittype1, 1)
    s1 = 'Shape-preserving interpolant';
else
    op = '+-';
    format1 = ['%s %0.',num2str(digits1),'g*x^{%s} %s'];
    format2 = ['%s %0.',num2str(digits1),'g'];
    xl = get(axesh1, 'xlim');
    fit =  fittype1 - 1;
    s1 = sprintf('y =');
    th = text(xl*[.95;.05],1,s1,'parent',axesh1, 'vis','off');
    if abs(coeffs1(1) < 0)
        s1 = [s1 ' -'];
    end
    for i = 1:fit
        sl = length(s1);
        if ~isequal(coeffs1(i),0) % if exactly zero, skip it
            s1 = sprintf(format1,s1,abs(coeffs1(i)),num2str(fit+1-i), op((coeffs1(i+1)<0)+1));
        end
        if (i==fit) && ~isequal(coeffs1(i),0)
            s1(end-5:end-2) = []; % change x^1 to x.
        end
        set(th,'string',s1);
        et = get(th,'extent');
        if et(1)+et(3) > xl(2)
            s1 = [s1(1:sl) sprintf('\n     ') s1(sl+1:end)];
        end
    end
    if ~isequal(coeffs1(fit+1),0)
        sl = length(s1);
        s1 = sprintf(format2,s1,abs(coeffs1(fit+1)));
        set(th,'string',s1);
        et = get(th,'extent');
        if et(1)+et(3) > xl(2)
            s1 = [s1(1:sl) sprintf('\n     ') s1(sl+1:end)];
        end
    end
    delete(th);
    % Delete last "+"
    if isequal(s1(end),'+')
        s1(end-1:end) = []; % There is always a space before the +.
    end
    if length(s1) == 3
        s1 = sprintf(format2,s1,0);
    end
end
end
