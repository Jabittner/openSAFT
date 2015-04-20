function varargout = qgui(varargin)
% QGUI MATLAB code for qgui.fig
%      QGUI, by itself, creates a new QGUI or raises the existing
%      singleton*.
%
%      H = QGUI returns the handle to a new QGUI or the handle to
%      the existing singleton*.
%
%      QGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in QGUI.M with the given input arguments.
%
%      QGUI('Property','Value',...) creates a new QGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before qgui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to qgui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help qgui

% Last Modified by GUIDE v2.5 05-Oct-2014 21:12:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @qgui_OpeningFcn, ...
                   'gui_OutputFcn',  @qgui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before qgui is made visible.
function qgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to qgui (see VARARGIN)

% Choose default command line output for qgui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using qgui.
if strcmp(get(hObject,'Visible'),'off')
%     curscan.Z_raw = a_filereader('../MIRA Scans/JAB4.lbv');
%     % Apply signal filters 
%     curscan = a_sig_filters(curscan);
%     curscan = a_plotBscan(curscan.Z_done,curscan);
%     handles.curscan=curscan;
%     guidata(hObject,handles);
end


% --- Outputs from this function are returned to the command line.
function varargout = qgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file path] = uigetfile('*.lbv');
if ~isequal(file, 0)
    curscan.Z_raw = a_filereader(strcat(path,file));
    % Apply signal filters 
    curscan = a_sig_filters(curscan);
    curscan = a_plotBscan(curscan.Z_done,curscan);
    handles.curscan=curscan;
    guidata(hObject,handles); 
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.curscan.gain=get(hObject,'Value');
bmax=max(max(handles.curscan.Z_bscan));
bmin=min(min(handles.curscan.Z_bscan));
imagesc(handles.curscan.Z_bscan, [bmin bmax*handles.curscan.gain]);
title('B-Scan Estimation');

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
