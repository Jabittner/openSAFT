function [Z] = a_filereader(filename)
%clear; close all;
% Extract file type from extension, assumes only one period present
fileNameSplit = strsplit(filename,'.');
fileExtension = fileNameSplit{2};
    %% to read the lbv file
    if strcmp(fileExtension, 'lbv') 
       fin= fopen(filename, 'r');
       header=fread(fin,32,'int32', 'l'); 
       data=fread(fin,inf, 'int16', 'b');
       fclose(fin);
       Z = reshape(data, header(12), header(11));
    end

    
    %% to read the config file
    if strcmp(fileExtension, 'cfg')
        fin = fopen(filename, 'r');
        config = fscanf(fin, '%i:%i');
        config = transpose(reshape(config, 2, length(config)/2));
    end
    
    % % To read the .bin File to a plot
    if strcmp(fileExtension,'bin')
        % row=1024;  col=1024;
        row = 216;
        col = 432;
        fin=fopen(filename,'r');
        I=fread(fin,row*col,'uint32=>uint32', 'l'); 
        Z=reshape(I,row,col);
        Z=Z';
        contourf(Z), shading flat
        set(gca,'YDir','reverse');
    end


end

