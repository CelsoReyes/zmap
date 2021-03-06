function varargout = fdsn_param_dialog(varargin)
    % FDSN_PARAM_DIALOG MATLAB code for fdsn_param_dialog.fig
    %      FDSN_PARAM_DIALOG, by itself, creates a new FDSN_PARAM_DIALOG or raises the existing
    %      singleton*.
    %
    %      H = FDSN_PARAM_DIALOG returns the handle to a new FDSN_PARAM_DIALOG or the handle to
    %      the existing singleton*.
    %
    %      FDSN_PARAM_DIALOG('CALLBACK',hObject,eventData,handles,...) calls the local
    %      function named CALLBACK in FDSN_PARAM_DIALOG.M with the given input arguments.
    %
    %      FDSN_PARAM_DIALOG('Property','Value',...) creates a new FDSN_PARAM_DIALOG or raises the
    %      existing singleton*.  Starting from the left, property value pairs are
    %      applied to the GUI before fdsn_param_dialog_OpeningFcn gets called.  An
    %      unrecognized property name or invalid value makes property application
    %      stop.  All inputs are passed to fdsn_param_dialog_OpeningFcn via varargin.
    %
    %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
    %      instance to run (singleton)".
    %
    % See also: GUIDE, GUIDATA, GUIHANDLES
    
    % Edit the above text to modify the response to help fdsn_param_dialog
    
    % Last Modified by GUIDE v2.5 29-Jun-2018 16:25:23
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @fdsn_param_dialog_OpeningFcn, ...
        'gui_OutputFcn',  @fdsn_param_dialog_OutputFcn, ...
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
    
    
    % --- Executes just before fdsn_param_dialog is made visible.
function fdsn_param_dialog_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to fdsn_param_dialog (see VARARGIN)
    
    % Choose default command line output for fdsn_param_dialog
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    
    % UIWAIT makes fdsn_param_dialog wait for user response (see UIRESUME)
    % uiwait(handles.fdsn_import_dialog);
    
    
    % --- Outputs from this function are returned to the command line.
function varargout = fdsn_param_dialog_OutputFcn(hObject, eventdata, handles)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    
    % --- Executes on selection change in data_provider.
function data_provider_Callback(hObject, eventdata, handles)
    % Hints: contents = cellstr(get(hObject,'String')) returns data_provider contents as cell array
    %        contents{get(hObject,'Value')} returns selected item from data_provider
    
    currprovider = hObject.UserData(hObject.Value);
    set(handles.provider_details,'String',...
        sprintf('%s\n%s\n%s',...
        currprovider.description,...
        currprovider.location,...
        currprovider.serviceURLs.eventService));
    if hObject.Value==1
        hObject.BackgroundColor = [1.0 0.95 0.95];
        msg.infodisp('Importing FDSN data - First choose a data provider...','FDSN Fetch');
        
    else
        hObject.BackgroundColor = [0.95 1.0 0.95];
        msg.infodisp('Importing FDSN data - Choose the desired catalog constraints (time, magnitude, etc..)','FDSN Fetch');
        
    end
     if ~ handles.catalog_name.UserData.touched 
         handles.catalog_name.String = [currprovider.name,'_fdsn']
     end
    
    % --- Executes during object creation, after setting all properties.
function data_provider_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    datacenter_details = webread('http://service.iris.edu/irisws/fedcatalog/1/datacenters');
    
    %dump datacenters with no event catalog access
    i=1;
    while i <= numel(datacenter_details)
        fldnm = fieldnames(datacenter_details(i).serviceURLs);
        if ~ismember('eventService',fldnm)
            datacenter_details(i)=[];
        else
            i=i+1;
        end
    end
    datacenter_details(2:end+1) = datacenter_details;
    datacenter_details(1).name = '<none>';
    datacenter_details(1).description = 'choose a datacenter';
    datacenter_details(1).website = ' ';
    datacenter_details(1).location = ' ';
    datacenter_details(1).lastUpdate = ' ';
    datacenter_details(1).serviceURLs.eventService = '';
    
    if exist('fdsnservices.json','file')
        try
            %TODO add a way to modify data centers
            % this is the datacenter_details structure, saved as a json file in the resrc directory
            jj=jsondecode(fileread('fdsnservices.json')); % get additional services
            for i=1:numel(jj)
                % only include datacenters that are not already retrieved by the querying fedcatalog
                if ~ismember(jj(i).name,{datacenter_details.name})
                    datacenter_details(end+1)=jj(i);
                end
            end
        catch ME
            disp(['unable to access additional datacenter information: ', ME.message]);
        end
    end
    hObject.UserData = datacenter_details;
    currprovider = datacenter_details(hObject.Value);
    set(hObject,'string',{datacenter_details.name});
    
    
    % --- Executes on button press in rect_geoselect.
function rect_geoselect_Callback(hObject, eventdata, handles)
    % Hint: get(hObject,'Value') returns toggle state of rect_geoselect
    set([handles.minlatitude, handles.maxlatitude, ...
        handles.minlongitude, handles.maxlongitude],'enable','on');
    
    set([handles.latitude,handles.longitude,...
        handles.minradius,handles.maxradius],'enable','off');
    
    enforce_gt_edit_relationship(handles.minlatitude, handles.maxlatitude);
    
    
    % --- Executes on button press in rad_geoselect.
function rad_geoselect_Callback(hObject, eventdata, handles)
    % Hint: get(hObject,'Value') returns toggle state of rad_geoselect
    set([handles.minlatitude, handles.maxlatitude, ...
        handles.minlongitude, handles.maxlongitude],'enable','off');
    set([handles.latitude,handles.longitude,...
        handles.minradius,handles.maxradius],'enable','on');
    enforce_gt_edit_relationship(handles.minradius, handles.maxradius);
    
    
    
function maxlatitude_Callback(hObject, eventdata, handles)
    
    update_editfield_value(hObject);
    enforce_gt_edit_relationship(handles.minlatitude, hObject);
    
    
    % --- Executes during object creation, after setting all properties.
function maxlatitude_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value = nan;
    
    
    
function minlatitude_Callback(hObject, eventdata, handles)
    update_editfield_value(hObject);
    enforce_gt_edit_relationship(hObject, handles.maxlatitude);
    
    % --- Executes during object creation, after setting all properties.
function minlatitude_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value = nan;
    
    
    
function minlongitude_Callback(hObject, eventdata, handles)
    update_editfield_value(hObject);
    if isnan(hObject.Value) || isempty(hObject.Value)
        set(hObject,'BackgroundColor',[1.0 1.0 1.0]);
    else
        set(hObject, 'BackgroundColor',[0.95 1.0 0.95]);
    end
    
    % --- Executes during object creation, after setting all properties.
function minlongitude_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value = nan;
    
    
function maxlongitude_Callback(hObject, eventdata, handles)
    
    update_editfield_value(hObject);
    if isnan(hObject.Value) || isempty(hObject.Value)
        set(hObject,'BackgroundColor',[1.0 1.0 1.0]);
    else
        set(hObject, 'BackgroundColor',[0.95 1.0 0.95]);
    end
    
    % --- Executes during object creation, after setting all properties.
function maxlongitude_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value=nan;
    
    
    
function starttime_Callback(hObject, eventdata, handles)
    
    try
        d = datetime(get(hObject,'String'));
        set(hObject,'backgroundcolor',[0.95 1.0 0.95]);
        set(hObject,'Value',datenum(d));
    catch
        d = str2double(get(hObject,'String'));
        if d >= 1800 && d < 3000
            %treat as year
            set(hObject,'String',[get(hObject,'String'), '-01-01']);
            starttime_Callback(hObject, eventdata, handles);
            return
        end
        
        set(hObject,'backgroundcolor',[1.0 0.95 0.95]);
        set(hObject,'Value',nan);
    end
    
    
    
    % --- Executes during object creation, after setting all properties.
function starttime_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value = nan;
    
    
function endtime_Callback(hObject, eventdata, handles)
    try
        d = datetime(get(hObject,'String'));
        set(hObject,'backgroundcolor',[0.95 1.0 0.95]);
        set(hObject,'Value',datenum(d));
    catch
        d = str2double(get(hObject,'String'));
        if d >= 1800 && d < 3000
            %treat as year
            set(hObject,'String',[get(hObject,'String'), '-01-01']);
            endtime_Callback(hObject, eventdata, handles);
            return
        end
        set(hObject,'backgroundcolor',[1.0 0.95 0.95]);
        set(hObject,'Value',nan);
    end
    
    
    % --- Executes during object creation, after setting all properties.
function endtime_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value = nan;
    
    
function mindepth_Callback(hObject, eventdata, handles)
    
    update_editfield_value(hObject);
    enforce_gt_edit_relationship(hObject, handles.maxdepth);
    
    % --- Executes during object creation, after setting all properties.
function mindepth_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value = nan;
    
    
    
function maxdepth_Callback(hObject, ~, handles)
    
    update_editfield_value(hObject);
    enforce_gt_edit_relationship(handles.mindepth, hObject);
    
    % --- Executes during object creation, after setting all properties.
function maxdepth_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value = nan;
    
    
    
function minmagnitude_Callback(hObject, ~, handles)
    
    update_editfield_value(hObject);
    enforce_gt_edit_relationship(hObject, handles.maxmagnitude)
    
    % --- Executes during object creation, after setting all properties.
function minmagnitude_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value = nan;
    
    
    
function maxmagnitude_Callback(hObject, ~, handles)
    update_editfield_value(hObject);
    enforce_gt_edit_relationship(handles.minmagnitude, hObject)
    
    % --- Executes during object creation, after setting all properties.
function maxmagnitude_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    hObject.Value = nan;
    
    
function magnitudetype_Callback(~, ~, ~)
    
    
    % --- Executes during object creation, after setting all properties.
function magnitudetype_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function latitude_Callback(hObject, ~, ~)
    
    update_editfield_value(hObject);
    % --- Executes during object creation, after setting all properties.
function latitude_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function longitude_Callback(hObject, ~, ~)
    
    update_editfield_value(hObject);
    % --- Executes during object creation, after setting all properties.
function longitude_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function minradius_Callback(hObject, ~, handles)
    update_editfield_value(hObject);
    enforce_gt_edit_relationship(hObject, handles.maxradius);
    
    % --- Executes during object creation, after setting all properties.
function minradius_CreateFcn(hObject, ~, ~)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function maxradius_Callback(hObject, ~, handles)
    
    update_editfield_value(hObject);
    enforce_gt_edit_relationship(handles.minradius, hObject);
    
    % --- Executes during object creation, after setting all properties.
function maxradius_CreateFcn(hObject, eventdata, handles)
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    % --- Executes on button press in ignore_geo.
function ignore_geo_Callback(~, ~, handles)
    % hObject    handle to ignore_geo (see GCBO)
    
    % Hint: get(hObject,'Value') returns toggle state of ignore_geo
    set([handles.minlatitude, handles.maxlatitude, ...
        handles.minlongitude, handles.maxlongitude],'enable','off');
    set([handles.latitude,handles.longitude,...
        handles.minradius,handles.maxradius],'enable','off');
    
    
    % --- Executes on button press in Fetch.
function Fetch_Callback(~, ~, handles)
    % hObject    handle to Fetch (see GCBO)
    % assemble the actual query
    % TODO: do this
    ZG=ZmapGlobal.Data;
    if (handles.data_provider.Value == 1)
        % no datacenter has been chosen
        beep;
        h=errordlg('Incomplete Request: You must first choose a data provider.', ...
            ['Error:', get(get(gco,'Parent'),'Name')],'modal');
        waitfor(h);
        errorflash(handles.data_provider);
        return
    end
    queryset=handles.data_provider.String{handles.data_provider.Value};
    
    queryset = add_datetime(handles, queryset, 'starttime');
    queryset = add_datetime(handles, queryset, 'endtime');
    if get(handles.rect_geoselect,'Value')
        queryset = add_numeric(handles, queryset, 'minlatitude');
        queryset = add_numeric(handles, queryset, 'maxlatitude');
        queryset = add_numeric(handles, queryset, 'minlongitude');
        queryset = add_numeric(handles, queryset, 'maxlongitude');
        
    elseif get(handles.rad_geoselect,'Value')
        queryset = add_numeric(handles, queryset, 'latitude');
        queryset = add_numeric(handles, queryset, 'longitude');
        queryset = add_numeric(handles, queryset, 'minradius');
        queryset = add_numeric(handles, queryset, 'maxradius');
    end
    
    queryset = add_numeric(handles, queryset, 'minmagnitude');
    queryset = add_numeric(handles, queryset, 'maxmagnitude');
    queryset = add_numeric(handles, queryset, 'mindepth');
    queryset = add_numeric(handles, queryset, 'maxdepth');
    queryset = add_string(handles, queryset, 'magnitudetype');
    
    msg.infodisp('Importing FDSN data from the web. This might take a minute','FDSN Fetch');
    
    set(handles.fdsn_import_dialog,'Visible','off');
    drawnow;
    % FETCH THE DATA
    if ~iscell(queryset)
        h=errordlg('Incomplete Request: You must first choose some filter constraints', ...
            ['Error:', get(get(gco,'Parent'),'Name')],'modal');
        waitfor(h)
        set(handles.fdsn_import_dialog,'Visible','on');
        return
    end
    watchon;
    whos queryset
    
    m=msgbox_nobutton('Please wait while requested data is downloaded','Downloading');
    m.ButtonString='wait';
    %% do the import
    tmp=import_fdsn_event(1, queryset{:});
    
    %%
    % make it OK to close dialog box.
    if isvalid(m)
        m.Name='Done';
        m.String=sprintf('Done Downloading. Found %d events',tmp.Count);
        m.delay_for_close(1);
        delete(m);
    end
    watchoff;
    
    % CONVERT
    msg.infodisp('Converting to a ZmapCatalog','FDSN Fetch');
    if ~isa(tmp,'ZmapCatalog')
        ZG.primeCatalog=ZmapCatalog.from(tmp);
    else
        ZG.primeCatalog=tmp;
    end
    ZG.primeCatalog.sort('Date')
    assert(ZG.primeCatalog.Date(1)<=ZG.primeCatalog.Date(end));
    % provider_details=handles.data_provider.UserData(handles.data_provider.Value);
    if isempty(ZG.primeCatalog.Name) %TODO move this functionality into import_fdsn_event
        ZG.primeCatalog.Name = handles.catalog_name.String;
    end
    pause(.1)
    
    %name catalog
    %sdlg.prompt='Provide a catalog name (used in plots, files)';
    assert(ZG.primeCatalog.Date(1)<=ZG.primeCatalog.Date(end));
    
    if isvalid(m)
        close(m)
    end
    clear tmp
    
    uimemorize_catalog();
    
    % close(hObject.Parent); % or set Visibility to 'off' ?
    
function [val] = getvalue(handles, label)
    val = get(handles.(label),'Value');
    
function [optlist] = add_numeric(handles, optlist, label)
    % optlist = add_numeric(handles, optlist, 'something')
    % adds only if 'something is not nan or empty
    val = get(handles.(label),'Value');
    if ~isempty(val) && ~isnan(val)
        optlist = [optlist, {label, val}];
    end
    
function [optlist] = add_string(handles, optlist, label)
    % optlist = add_numeric(handles, optlist, 'something')
    % adds only if 'something is not nan or empty
    val = get(handles.(label),'String');
    if ~isempty(val) && ~any(val==' ')
        optlist = [optlist, {label, val}];
    end
    
function [optlist] = add_datetime(handles, optlist, label)
    % optlist = add_numeric(handles, optlist, 'something')
    % adds only if 'something is not nan or empty
    val = get(handles.(label),'Value');
    if ~isempty(val) && ~isnan(val)
        val=datestr(val,'yyyy-mm-dd hh:MM:SS');
        val(val==' ') = 'T';
        optlist = [optlist, {label, val}];
    end
    
function enforce_gt_edit_relationship(hSmaller, hBigger)
    nan_bgcolor = [1.0 1.0 1.0];
    good_bgcolor = [0.95 1.0 0.95];
    bad_bgcolor = [1.0 0.95 0.95];
    hasSmaller = ~isnan(hSmaller.Value) && ~isempty(hSmaller.Value);
    hasBigger = ~isnan(hBigger.Value) && ~isempty(hBigger.Value);
    if hasBigger && ~hasSmaller
        hSmaller.BackgroundColor = nan_bgcolor;
        hBigger.BackgroundColor = good_bgcolor;
        %
    elseif hasSmaller && ~hasBigger
        hSmaller.BackgroundColor = good_bgcolor;
        hBigger.BackgroundColor = nan_bgcolor;
    elseif ~hasBigger && ~hasSmaller
        hSmaller.BackgroundColor = nan_bgcolor;
        hBigger.BackgroundColor = nan_bgcolor;
    else
        if hBigger.Value >= hSmaller.Value
            hSmaller.BackgroundColor = good_bgcolor;
            hBigger.BackgroundColor = good_bgcolor;
        else
            hSmaller.BackgroundColor = bad_bgcolor;
            hBigger.BackgroundColor = bad_bgcolor;
        end
    end



function catalog_name_Callback(hObject, ~, ~)
% Hints: get(hObject,'String') returns contents of catalog_name as text
%        str2double(get(hObject,'String')) returns contents of catalog_name as a double
hObject.UserData.touched = true;

% --- Executes during object creation, after setting all properties.
function catalog_name_CreateFcn(hObject, ~, ~)
hObject.UserData.touched = false;


% --- Executes on button press in cancelbutton.
function cancelbutton_Callback(hObject, eventdata, handles)
delete(handles.fdsn_import_dialog);

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over cancelbutton.
function cancelbutton_ButtonDownFcn(hObject, eventdata, handles)
