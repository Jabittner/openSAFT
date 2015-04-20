function [] = a_plotAscan(Z,curscan)
    % INPUT is Z matrix from a_filereader.m
    % Generate Plot
    l=0;
    cmap = hsv(14);
    iymin=min(min(Z)); iymax=max(max(Z));
    for k=11:-1:1
        figure;
        %subplot(2,6,k);
        for j=1:k
              data = double(Z(:,j+l));
              offset=double(abs(iymin)+abs(iymax))/2;
              plot(j*offset+(data),'Color', cmap(j,:)); hold on
              plot(curscan.surf_arrival_index(j+l), j*offset+data(curscan.surf_arrival_index(j+l)), 'o', 'Color', cmap(j,:));
              plot([0,length(data)],j*offset+[0 0], 'b-.');
              title(strcat('R=', num2str(12-k), ' T=',num2str(12-k+1), '(bottom)-12(top) ', num2str(k), 'total'));
              xlim([0 500]);
        end
        xlabel('Time usec'); ylabel('Amplitude');
       l=k+l;
    end
end