function varargout = PTUcontroller(varargin)
% PTUCONTROLLER MATLAB code for PTUcontroller.fig
%      PTUCONTROLLER, by itself, creates a new PTUCONTROLLER or raises the existing
%      singleton*.
%
%      H = PTUCONTROLLER returns the handle to a new PTUCONTROLLER or the handle to
%      the existing singleton*.
%
%      PTUCONTROLLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PTUCONTROLLER.M with the given input arguments.
%
%      PTUCONTROLLER('Property','Value',...) creates a new PTUCONTROLLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PTUcontroller_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PTUcontroller_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PTUcontroller

% Last Modified by GUIDE v2.5 31-Aug-2019 14:59:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PTUcontroller_OpeningFcn, ...
                   'gui_OutputFcn',  @PTUcontroller_OutputFcn, ...
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


% --- Executes just before PTUcontroller is made visible.
function PTUcontroller_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PTUcontroller (see VARARGIN)

% Choose default command line output for PTUcontroller
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PTUcontroller wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PTUcontroller_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit_PanPos_Goal_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PanPos_Goal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PanPos_Goal as text
%        str2double(get(hObject,'String')) returns contents of edit_PanPos_Goal as a double


% --- Executes during object creation, after setting all properties.
function edit_PanPos_Goal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PanPos_Goal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_TiltPos_Goal_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TiltPos_Goal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TiltPos_Goal as text
%        str2double(get(hObject,'String')) returns contents of edit_TiltPos_Goal as a double


% --- Executes during object creation, after setting all properties.
function edit_TiltPos_Goal_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TiltPos_Goal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Pos_Goal_GO.
function pushbutton_Pos_Goal_GO_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Pos_Goal_GO (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Enable', 'off');
set(handles.pushbutton_Pos_Limit_Set, 'Enable', 'off');
pause(0.1);
% 'Out of range'
P_degree = str2num(get(handles.edit_PanPos_Goal, 'String'));
T_degree = str2num(get(handles.edit_TiltPos_Goal, 'String'));
if ~isempty(P_degree) && ~isempty(T_degree)
    if strcmp(handles.PTU.gotoPT(P_degree, T_degree), 'Out of range')
        set(handles.text_Pos_Status, 'String', 'Out of range');
    else
        set(handles.text_Pos_Status, 'String', 'Going');
        err = 999;
        threshold = handles.PTU.Pan_Resolution + handles.PTU.Tilt_Resolution;
         while err > threshold
            pause(0.2);
            [Pos, Speed] = handles.PTU.getPS()
            Pos = round(Pos*10)/10;
            Speed = round(Speed*10)/10;
            set(handles.text_PanPos_Current, 'String', num2str(Pos(1)));
            set(handles.text_TiltPos_Current, 'String', num2str(Pos(2)));
            set(handles.text_PanSpeed_Current, 'String', num2str(Speed(1)));
            set(handles.text_TiltSpeed_Current, 'String', num2str(Speed(2)));
            err = abs((P_degree - Pos(1)) + (T_degree - Pos(2)));
         end
         set(handles.text_PanSpeed_Current, 'String', '0');
         set(handles.text_TiltSpeed_Current, 'String', '0');
         set(handles.text_Pos_Status, 'String', 'Arrived');
    end
end
set(hObject, 'Enable', 'on');
set(handles.pushbutton_Pos_Limit_Set, 'Enable', 'on');


function edit_PanPos_Limit_User_Min_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PanPos_Limit_User_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PanPos_Limit_User_Min as text
%        str2double(get(hObject,'String')) returns contents of edit_PanPos_Limit_User_Min as a double


% --- Executes during object creation, after setting all properties.
function edit_PanPos_Limit_User_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PanPos_Limit_User_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_PanPos_Limit_User_Max_Callback(hObject, eventdata, handles)
% hObject    handle to edit_PanPos_Limit_User_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_PanPos_Limit_User_Max as text
%        str2double(get(hObject,'String')) returns contents of edit_PanPos_Limit_User_Max as a double


% --- Executes during object creation, after setting all properties.
function edit_PanPos_Limit_User_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_PanPos_Limit_User_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_TiltPos_Limit_User_Min_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TiltPos_Limit_User_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TiltPos_Limit_User_Min as text
%        str2double(get(hObject,'String')) returns contents of edit_TiltPos_Limit_User_Min as a double


% --- Executes during object creation, after setting all properties.
function edit_TiltPos_Limit_User_Min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TiltPos_Limit_User_Min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_TiltPos_Limit_User_Max_Callback(hObject, eventdata, handles)
% hObject    handle to edit_TiltPos_Limit_User_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_TiltPos_Limit_User_Max as text
%        str2double(get(hObject,'String')) returns contents of edit_TiltPos_Limit_User_Max as a double


% --- Executes during object creation, after setting all properties.
function edit_TiltPos_Limit_User_Max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_TiltPos_Limit_User_Max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_Pos_Limit_Set.
function pushbutton_Pos_Limit_Set_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Pos_Limit_Set (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Enable', 'off');
set(handles.pushbutton_Pos_Goal_GO, 'Enable', 'off');
pause(0.1);
PNU = str2num(get(handles.edit_PanPos_Limit_User_Min, 'String'));
PXU = str2num(get(handles.edit_PanPos_Limit_User_Max, 'String'));
TNU = str2num(get(handles.edit_TiltPos_Limit_User_Min, 'String'));
TXU = str2num(get(handles.edit_TiltPos_Limit_User_Max, 'String'));
handles.PTU.SetUserLimit(PNU, PXU, TNU, TXU)
PN = num2str(fix(handles.PTU.Pan_Limit(1)*10)/10);
PX = num2str(fix(handles.PTU.Pan_Limit(2)*10)/10);
TN = num2str(fix(handles.PTU.Tilt_Limit(1)*10)/10);
TX = num2str(fix(handles.PTU.Tilt_Limit(2)*10)/10);
PLimit = [PN ' ~ ' PX];
TLimit = [TN ' ~ ' TX];
set(handles.text_PanPos_Limit, 'String', PLimit);
set(handles.text_TiltPos_Limit, 'String', TLimit);
set(hObject, 'Enable', 'on');
set(handles.pushbutton_Pos_Goal_GO, 'Enable', 'on');


% --- Executes on button press in pushbutton_Connect.
function pushbutton_Connect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Connect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Enable', 'off');
pause(0.1);
PTU_IP = get(handles.edit_IP, 'String');
if length(strfind(PTU_IP, '.')) == 3 %IP為正確格式
    PTU = ptu(PTU_IP, 4000);
    if strcmp(PTU.Status, 'Connection successed')
        handles.PTU = PTU;
        guidata(hObject, handles)
        Connection_Status = ['PTU:' PTU_IP];
        % display current position
        [Pos, Speed] = PTU.getPS();
        Pos = round(Pos*10)/10;
        set(handles.text_PanPos_Current, 'String', num2str(Pos(1)));
        set(handles.text_TiltPos_Current, 'String', num2str(Pos(2)));
        % display position Limit
        PN = num2str(fix(PTU.Pan_Limit(1)*10)/10);
        PX = num2str(fix(PTU.Pan_Limit(2)*10)/10);
        TN = num2str(fix(PTU.Tilt_Limit(1)*10)/10);
        TX = num2str(fix(PTU.Tilt_Limit(2)*10)/10);
        PLimit = [PN ' ~ ' PX];
        TLimit = [TN ' ~ ' TX];
        set(handles.text_PanPos_Limit, 'String', PLimit);
        set(handles.text_TiltPos_Limit, 'String', TLimit);
        
        set(handles.edit_PanPos_Limit_User_Min, 'String', PN);
        set(handles.edit_PanPos_Limit_User_Max, 'String', PX);
        set(handles.edit_TiltPos_Limit_User_Min, 'String', TN);
        set(handles.edit_TiltPos_Limit_User_Max, 'String', TX);
        
        % Enable the buttons
        set(handles.pushbutton_Disconnect, 'Enable', 'on');
        set(handles.pushbutton_Pos_Goal_GO, 'Enable', 'on');
        set(handles.pushbutton_Pos_Limit_Set, 'Enable', 'on');
    else
        PTU.delete();
        Connection_Status = 'Connection Failed.'
    end
    set(handles.text_ConnectionStatus, 'String', Connection_Status);
else
    set(handles.text_ConnectionStatus, 'String', 'Wrong IP formate.');
    set(hObject, 'Enable', 'on');
end

% --- Executes on button press in pushbutton_Disconnect.
function pushbutton_Disconnect_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_Disconnect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(hObject, 'Enable', 'off');
pause(0.1);
handles.PTU.delete();
set(handles.text_ConnectionStatus, 'String', 'Disconnected.');
set(handles.pushbutton_Connect, 'Enable', 'on');
set(handles.pushbutton_Pos_Goal_GO, 'Enable', 'off');
set(handles.pushbutton_Pos_Limit_Set, 'Enable', 'off');


function edit_IP_Callback(hObject, eventdata, handles)
% hObject    handle to edit_IP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_IP as text
%        str2double(get(hObject,'String')) returns contents of edit_IP as a double


% --- Executes during object creation, after setting all properties.
function edit_IP_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_IP (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
try
    handles.PTU.delete();
end
delete(hObject);
