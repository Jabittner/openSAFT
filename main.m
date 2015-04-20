% MIRA Data File Processor
% 2014 (c) JAB
%
% a_plotAscan(Z,curscan) - Plots all A-Scans for extracted Z matrix
% a_sig_filters(curscan) - Apply and Generate Filtered set of data
% a_plotBscan(Z,curscan) - Apply distance and integration to a xy data set
% a_filereader(filename) - Extract raw signal matrix (Z) from .lbv files

close all;
clear;
curscan.Z_raw = a_filereader('JAB4.lbv');
% Load Data
% Apply signal filters 
curscan = a_sig_filters(curscan);

% Plot A Scans
a_plotAscan(curscan.Z_raw, curscan);

% Plot B Scan 
figure; 
curscan = a_plotBscan(curscan.Z_done,curscan);


