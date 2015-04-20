% OpenSAFT - MIRA Data File Processor
% 
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
%	
% a_plotAscan(Z,curscan) - Plots all A-Scans for extracted Z matrix
% a_sig_filters(curscan) - Apply and Generate Filtered set of data
% a_plotBscan(Z,curscan) - Apply distance and integration to a xy data set
% a_filereader(filename) - Extract raw signal matrix (Z) from .lbv files

% Setup A Clean Workspace
close all;
clear;

% Load Data
curscan.Z_raw = a_filereader('JAB4.lbv');

% Apply signal filters 
curscan = a_sig_filters(curscan);

% Plot A Scans (11 plots)
a_plotAscan(curscan.Z_raw, curscan);

% Plot B Scan (1 plot)
figure; 
curscan = a_plotBscan(curscan.Z_done,curscan);


