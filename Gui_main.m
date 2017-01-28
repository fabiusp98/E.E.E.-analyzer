%E.E.E.-analyzer - Gui_main by Fabio Pinciroli
%Copyright 2017 Fabio Pinciroli DISTRIBUTED UNDER GPL V3 LICENSE

% Start initialization code - DO NOT EDIT - AUTOGENERATED
function varargout = Gui_main(varargin)
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @Gui_main_OpeningFcn, ...
                       'gui_OutputFcn',  @Gui_main_OutputFcn, ...
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
end
function varargout = Gui_main_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;
end
function txt_Filepath_CreateFcn(hObject, eventdata, handles)

    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function txt_WgetPath_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function txt_V20Path_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
function ppmen_GraphFormat_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
end
% End initialization code - DO NOT EDIT - AUTOGENERATED

%CALLBACKS-----------------------------------------------------------------
% Initialization callback(executes when window is shown)
function Gui_main_OpeningFcn(hObject, eventdata, handles, varargin)
    handles.output = hObject;   %autogenerated
    CheckOk = true;
    
    %Check if other matlab files exist
    if exist('EEEanalyzer_bin.m', 'file') ~= 2
        CheckOk = false;
    end
    
    if exist('GraphStats.m', 'file') ~= 2
        CheckOk = false;
    end
    
    if exist('Gui_main.fig', 'file') ~= 2
        CheckOk = false;
    end
    
    if CheckOk == false
        errordlg('Integrity control failed.');
        quit();
    end
    
    handles.GraphFormat = 'png'; %create default values
    handles.StatsEnable = 0;
    handles.DqmEnable = 0;
    handles.wGetName = '';
    
    %handle preferences
    try    %try to load preferences
        handles.wGetName = getpref('EEEanalyzer','wGetName');   %get data
        handles.wGetDir = getpref('EEEanalyzer','wGetDir');
        set(handles.txt_WgetPath, 'String', strcat(handles.wGetDir, handles.wGetName)); %udate gui
    
        handles.v20Name = getpref('EEEanalyzer','v20Name');
        handles.v20Dir = getpref('EEEanalyzer','v20Dir');
        set(handles.txt_V20Path, 'String', strcat(handles.v20Dir, handles.v20Name));
        
    catch A	%if failed
        %do nothing
    end
    
    guidata(hObject, handles); %update preferences
    
    
end

% Go button
function btn_Go_Callback(hObject, eventdata, handles)
    isDataValid = true %data valid flag
    
    try    %check if variable is good by trying to read it
        tmp = handles.fName;
    catch A    %if it isn't
        errordlg('Data file path is incorrect.'); %alert
        isDataValid = false;    %set flag to false
    end
    
    try    %check if variable is good by trying to read it
        tmp = handles.fDir;
    catch A    %if it isn't
        errordlg('Data file path is incorrect.'); %alert
        isDataValid = false;    %set flag to false
    end
    
    
    try    %check if variable is good by trying to read it
        tmp = handles.wGetName;
    catch A    %if it isn't
        errordlg('Wget executable path is incorrect.'); %alert
        isDataValid = false;    %set flag to false
    end
    
    try    %check if variable is good by trying to read it
        tmp = handles.wGetDir;
    catch A    %if it isn't
        errordlg('Wget executable path is incorrect.'); %alert
        isDataValid = false;    %set flag to false
    end
    
    
    try    %check if variable is good by trying to read it
        tmp = handles.v20Name;
    catch A    %if it isn't
        errordlg('EEE_V20.exe executable path is incorrect.'); %alert
        isDataValid = false;    %set flag to false
    end
    
    try    %check if variable is good by trying to read it
        tmp = handles.v20Dir;
    catch A    %if it isn't
        errordlg('EEE_V20.exe executable path is incorrect.'); %alert
        isDataValid = false;    %set flag to false
    end
    
    if(isDataValid == true)    %if all data is valid
        EEEanalyzer_bin(handles.GraphFormat, handles.fName, handles.fDir, handles.wGetName, handles.wGetDir, handles.v20Name, handles.v20Dir);  %run analysis
    end
    
    %save preferences
    setpref('EEEanalyzer','wGetName', handles.wGetName);
    getpref('EEEanalyzer','wGetDir', handles.wGetDir);
    getpref('EEEanalyzer','v20Name', handles.v20Name);
    getpref('EEEanalyzer','v20Dir', handles.v20Dir);
    guidata(hObject, handles);  %update global handle
end

%Choose File button
function btn_ChooseFile_Callback(hObject, eventdata, handles)
    [fName, fDir] = uigetfile('*.bin', 'Select data file'); %spawn choose file dialog and get data into local variables
    
    handles.fName = fName; %move variables to matlab handle
    handles.fDir = fDir;
    
    guidata(hObject,handles); %update global handle
    
    set(handles.txt_Filepath, 'String', strcat(fDir, fName));   %Update the the filepath text
end

%Filepath text modified
function txt_Filepath_Callback(hObject, eventdata, handles)
    
    str = get(handles.txt_Filepath, 'String');  %get string into local variable
    cnt = length(str);  %set counter to string length
    
    while(str((cnt - 1) : cnt) ~= '\') %go backwards from the end of the string until you find \
        cnt = cnt - 1;
    end
    
    fName = str(cnt : length(str)); %from the next character to the last \ to the end of the string is the file name
    fDir = str(1 : (cnt - 1));  %from the beginning of the string to the last \ is the directory
    
    handles.fName = fName; %move variables to matlab handle
    handles.fDir = fDir;
    
    guidata(hObject,handles); %update global handle
end

%Wget button pressed
function btn_ChooseWget_Callback(hObject, eventdata, handles)
    [wGetName, wGetDir] = uigetfile('*.exe', 'Select Wget utility'); %spawn choose file dialog and get data into local variables
    
    handles.wGetName = wGetName; %move variables to matlab handle
    handles.wGetDir = wGetDir;
    
    guidata(hObject,handles); %update global handle
    
    set(handles.txt_WgetPath, 'String', strcat(wGetDir, wGetName));   %Update the the filepath text
end

%Wget text changed
function txt_WgetPath_Callback(hObject, eventdata, handles)
    str = get(handles.txt_WgetPath, 'String');  %get string into local variable
    cnt = length(str);  %set counter to string length
    
    while(str((cnt - 1) : cnt) ~= '\') %go backwards from the end of the string until you find \
        cnt = cnt - 1;
    end
    
    wGetName = str(cnt : length(str)); %from the next character to the last \ to the end of the string is the file name
    wGetDir = str(1 : (cnt - 1));  %from the beginning of the string to the last \ is the directory
    
    handles.wGetName = wGetName; %move variables to matlab handle
    handles.wGetDir = wGetDir;
    
    guidata(hObject,handles); %update global handle
end

%V20 button pressed
function btn_ChooseV20_Callback(hObject, eventdata, handles)
    [v20Name, v20Dir] = uigetfile('*.exe', 'Select EEE_V20.exe'); %spawn choose file dialog and get data into local variables
    
    handles.v20Name = v20Name; %move variables to matlab handle
    handles.v20Dir = v20Dir;
    
    guidata(hObject,handles); %update global handle
    
    set(handles.txt_V20Path, 'String', strcat(v20Dir, v20Name));   %Update the the filepath text
end

%V20 text changed
function txt_V20Path_Callback(hObject, eventdata, handles)
    str = get(handles.txt_V20Path, 'String');  %get string into local variable
    cnt = length(str);  %set counter to string length
    
    while(str((cnt - 1) : cnt) ~= '\') %go backwards from the end of the string until you find \
        cnt = cnt - 1;
    end
    
    v20Name = str(cnt : length(str)); %from the next character to the last \ to the end of the string is the file name
    v20Dir = str(1 : (cnt - 1));  %from the beginning of the string to the last \ is the directory
    
    handles.v20Name = v20Name; %move variables to matlab handle
    handles.v20Dir = v20Dir;
    
    guidata(hObject,handles); %update global handle
end

%Dqm enable checkbox changed
function cbx_DqmEnable_Callback(hObject, eventdata, handles)
    var = get(handles.cbx_DqmEnable, 'Value'); %get checkbox value into local variable
    
    if(var == 0)    %if variable 0
        var = false;    %result is false
    else   %else
        var = true; %result is true
    end

    handles.DqmEnable = var;    %move variable to matlab handle
    
    guidata(hObject,handles); %update global handle
end

%Statistics enable checkbox changed
function cbx_StatsEnable_Callback(hObject, eventdata, handles)
    var = get(handles.cbx_StatsEnable, 'Value'); %get checkbox value into local variable
    
    if(var == 0)    %if variable 0
        var = false;    %result is false
    else   %else
        var = true; %result is true
    end

    handles.StatsEnable = var;    %move variable to matlab handle
    guidata(hObject,handles); %update global handle
end

%Graphs save mode changed
function ppmen_GraphFormat_Callback(hObject, eventdata, handles)
    handles.GraphFormat = get(handles.ppmen_GraphFormat, 'String');;    %get data and move it to matlab handle
    guidata(hObject,handles); %update global handle
end
