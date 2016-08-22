function varargout = qgui(varargin)
% QGUI MATLAB code for qgui.fig
% Begin initialization code 
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
% End initialization code

% --- Executes just before qgui is made visible.
function qgui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% varargin   command line arguments to qgui (see VARARGIN)
% Choose default command line output for qgui
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% This sets up the initial plot - only do when we are invisible
% so window can get raised using qgui.
if strcmp(get(hObject,'Visible'),'off')
    set( gcf, 'toolbar', 'none' )
    figure(10);
    imagesc(zeros(800));
    set( gcf, 'toolbar', 'figure' )
    
end


% --- Outputs from this function are returned to the command line.
function varargout = qgui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
[file path] = uigetfile('*.lbv');
if ~isequal(file, 0)
    settings = getSettings(handles);
    h = msgbox({'Please wait..', 'The first run can take a few seconds'} );
    [Z_bscan, vel] = a_FileToImage(strcat(path,file), settings);
    handles.fig = figure();
    handles.filename = strcat(path,file);
    handles.settings = settings;
    handles.Z_bscan = Z_bscan;
    set(handles.edit1,'String',num2str(vel, '%5.0f'));
    delete(h);
    updatePlot(handles);
    guidata(hObject,handles); 
end

% --------------------------------------------------------------------
function updatePlot(handles)
% handles   structure with handles and user data 
Z_bscan = handles.Z_bscan; 
if handles.settings.display.method==1
    Z_bscan = abs(hilbert(Z_bscan));
elseif handles.settings.display.method==2
    [z,x]=size(Z_bscan);
    attfactor = min((1/200)*(1:z), 2);
    attfactor = repmat(attfactor/max(attfactor),x,1)';
    Z_bscan = abs(hilbert(Z_bscan.*attfactor));
elseif handles.settings.display.method==3
    Z_bscan = Z_bscan;
end
bmax=max(max(Z_bscan));
bmin=min(min(Z_bscan));
figure(handles.fig);
imagesc(Z_bscan, [bmin bmax*handles.settings.colorgain]);
title('B-Scan Estimation');

% --------------------------------------------------------------------
function [settings] = getSettings(handles)
% handles   structure with handles and user data 
edit3 = get(handles.edit3);
t = max(0,str2num(edit3.String));
settings.imagesize=t; %width
lb1 = get (handles.listbox1);
settings.velocitymethod=lb1.Value; 
edit1 = get(handles.edit1);
t = max(2000,str2num(edit1.String));
settings.velocitystatic=t; 
lb2 = get (handles.listbox2);
settings.surfacemethod=lb2.Value;
lb3 = get (handles.listbox3);
settings.display.method=lb3.Value;
s1 = get (handles.slider1);
settings.colorgain=s1.Value+.01;

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end
delete(handles.figure1)



% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
handles.settings.colorgain=get(hObject,'Value');
updatePlot(handles)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
    settings = getSettings(handles);
    [Z_bscan vel] = a_FileToImage(handles.filename, settings);
    handles.settings = settings;
    handles.Z_bscan = Z_bscan;
    set(handles.edit1,'String',num2str(vel, '%5.0f'));
    updatePlot(handles);
    guidata(hObject,handles); 

function edit3_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
handles.fig=figure(); 
pushbutton4_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function uipushtool8_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
OpenMenuItem_Callback(hObject, eventdata, handles)

% --------------------------------------------------------------------
function uipushtool9_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uipushtool9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pushbutton4_Callback(hObject, eventdata, handles)


% --------------------------------------------------------------------
function About_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h=msgbox({'OpenSAFT GUI,', ...
    'Written by James Bittner (jbittn2@illinois.edu)', ...
    'This software is open source licensed and is free.', ...
    'Source code can be found on GITHUB as OpenSAFT', ... 
    'Please feel welcome to contribute feedback or new code'},'OK');
