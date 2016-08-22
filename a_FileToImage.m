function [ Z_bscan,Est_Vel_Shear ] = a_FileToImage( filename, settings )
%clear
%filename='../JAB4.lbv';
%settings='';
if ~isstruct(settings)
        clear settings
        settings.imagesize=single(800); %width
        settings.velocitymethod=2;
        settings.velocitystatic=2300; 
        settings.surfacemethod=1;
        settings.display.method=1;
        settings.colorgain=.07;
    end
    global dist apod % This is just an optimization
    tic;  % Load File
    fin= fopen(filename, 'r');
    header=fread(fin,32,'int32', 'l'); 
    data=fread(fin,inf, 'int16', 'b');
    fclose(fin);
    Z_raw = reshape(data, header(12), header(11));
    width=settings.imagesize; % must be greater than 301

 % Process Data      
    if (exist('precache.mat', 'file')~=2)
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
        % make index of signal# to transmitter/reciever/distance 
        l=0;
        indx_to_trans=zeros(1,66,'single');
        indx_to_rec=zeros(1,66,'single');
        for k=11:-1:1 % num of transmitters 
            for j=1:k % each transmitter
                indx_to_trans(l+j)=j+1+(11-k); % Z index to trans num
                indx_to_rec(l+j)=12-k;% Z index to reciever num
            end
            l=l+k;
        end
        indx_to_dist=double(indx_to_trans-indx_to_rec).*30e-3; %mm
        save('precache.mat', 'a','b', 'indx_to_trans', 'indx_to_rec', 'indx_to_dist');
    else            
    load('precache.mat');
    end
    Z_filt=filtfilt(b,a,Z_raw); % apply band pass
    Z_filt=single(Z_filt);
    %Find Surface Shear Arrival 
    [surf_arrival_val surf_arrival_index]=max(Z_filt(2:300,:));
    
    %Calculate a Shear Velocity
    if settings.velocitymethod==1 % Static
        Est_Vel_Shear=settings.velocitystatic;
    elseif settings.velocitymethod ==2 % Linear
        % using arrival and distance estimate Shear wave
        Est_Vel_Shear=polyfit(surf_arrival_index.*10^-6, indx_to_dist, 1);
        % linear fit for the slope between time and distance of R arrival
        Est_Vel_Shear = Est_Vel_Shear(1)
    elseif settings.velocitymethod ==3 % Distribution
        % TODO 
        nck=nchoosek(1:66,2);
        y2=indx_to_dist(nck(:,2));
        y1=indx_to_dist(nck(:,1));
        x1=surf_arrival_index(nck(:,1))*10^-6;
        x2=surf_arrival_index(nck(:,2))*10^-6;
        s0=(y2-y1)./(x2-x1);
        index_used = find(s0>2000 & s0<4000);
        Est_Vel_Shear= mean(s0(index_used)) % or Median 
    end
    
    if settings.surfacemethod==1
        % cut out surface wave
        qmask=repmat(surf_arrival_index+25,2048,1)<repmat(1:2048,66,1)';
        Z_noSurface=qmask.*Z_filt;
    elseif settings.surfacemethod==2
        % subtract a average surface wave
        Z_noSurface=Z_filt;
        dp = unique(indx_to_dist);
        for ik=1:length(dp)
            dpi=find(indx_to_dist==dp(ik));
            avgSurf=mean(Z_filt(1:300,dpi),2);
            Z_noSurface(1:300,dpi)=Z_noSurface(1:300,dpi)-repmat(avgSurf, 1, length(dpi));
        end
    elseif settings.surfacemethod==3
        % Smooth cut out of the surface wave
        qmask=repmat(surf_arrival_index+25,2048,1)<repmat(1:2048,66,1)';
        qmask2=zeros(2048,66);
        slope = 50 ;
        amask=[1:slope].^3/[slope].^3;
        for kk=1:66
        qmask2(surf_arrival_index(kk): surf_arrival_index(kk)+slope-1,kk)=amask;
        qmask2(surf_arrival_index(kk)+slope:end,kk)=1;
        end
        qmask = qmask.*qmask2; 
        Z_noSurface=qmask.*Z_filt;
    end
clear -global apod dist;
dist=[];
    if length(dist)~=settings.imagesize
       % clear -global apod dist;
        disp('recalc')
        apod = zeros(settings.imagesize,settings.imagesize,66,'single');
        dist = zeros(settings.imagesize,settings.imagesize,66,'single');
        for j=1:66
            x_r_loc=(width/2)-150+indx_to_rec(j)*30;
            x_t_loc=(width/2)-150+indx_to_trans(j)*30;
            z_k = repmat([1:width]',1,width);  % depth from surface
            z_k2=z_k.^2;
            x_r2 = repmat((x_r_loc-[1:width]).^2,width,1); % horz dist from rec
            x_t2 = repmat((x_t_loc-[1:width]).^2,width,1); % horz dist from trans
            sqrt_xr2_zk2=sqrt(x_r2+z_k2);
            sqrt_xt2_zk2=sqrt(x_t2+z_k2);
            %apodr = (z_k)./sqrt_xr2_zk2; % directly from appendix ...
                                                %(reasonable propigation assumption)
            %apodt = (z_k)./sqrt_xt2_zk2;
            %clear -global apod dist;
            %apod(:,:,j)=apodr.*apodt;
            apod(:,:,j)=((z_k)./sqrt_xr2_zk2).*((z_k)./sqrt_xt2_zk2);
            
            % takes in to account send and rec
            dist(:,:,j) = (sqrt_xr2_zk2+sqrt_xt2_zk2); %dist from pt to t/r
        end
    end
    b1=zeros(settings.imagesize, settings.imagesize, 66,'single');

    for j=1:66
        xyindx = round(dist(:,:,j).*(10^3/Est_Vel_Shear(1))); % dist to time usec
        S = reshape(Z_noSurface(xyindx(:),j), width, width); % time to approx. signal 
        b1(:,:,j) = S.*apod(:,:,j); % x-y fit to propigation estimate apod
    end
    bsum = sum(b1,3); % sum all by 3rd axis 
    Amplitude_DepthShift = round(0.5*(1/50000)*Est_Vel_Shear(1)*1000);
    bsum = bsum(Amplitude_DepthShift:end, :);
    Z_bscan = fliplr(bsum); 
    imagesc(abs(hilbert(Z_bscan)));
    toc
%end

