classdef ZmapFunctionDlg < handle
    % ZmapFunctionDlg Helper, used to generate dialog boxes while keeping code clean
    %
    % can be called in 2 ways.
    % EXAMPLE USAGE IN A SCRIPT
    %     zdlg = ZmapFunctionDlg();
    %     zdlg.AddBasicHeader('Say something for each thing');
    %     zdlg.AddBasicPopup('lifechoice','life choice',{'Eat','Drink','Be Merry'},2,...
    %         'Choose what is most important to you');
    %     zdlg.AddGridParameters('grid',0,'deg',3,'deg',5,'km');
    %     zdlg.AddBasicEdit('noiselevel','Noise level', 1,...
    %         'how much noise should?');
    %     zdlg.AddBasicCheckbox('usenoise','use noise level', false,{'noiselevel','noiselevel_label'},...
    %         'Should noise be applied to the data?');
    %     zdlg.AddBasicCheckbox('cleverness','be clever', false,[],...
    %         'if checked, then plot is cleverly drawn');
    %     zdlg.AddEventSelectionParameters('evtparams', 100, 5)
    %     [myans,okpressed] = zdlg.Create('my example');
    %
    %         myans = 
    % 
    %       struct with fields:
    % 
    %         lifechoice: 2
    %               grid: [1×1 struct]
    %         noiselevel: 1
    %           usenoise: 0
    %         cleverness: 0
    %          evtparams: [1×1 struct]
    %
    %
    % EXAMPLE USAGE IN A CLASS
    % classdef myclass < ZmapFunction
    %   properties
    %     grid
    %     lifechoice
    %     noiselevel
    %     usenoise
    %     cleverness
    %   end
    %
    %   methods
    %     ...
    %   function interact(obj)
    %     zdlg = ZmapFunctionDlg(obj, @doit)
    %
    %     zdlg.AddBasicHeader('Say something for each thing');
    %     zdlg.AddBasicPopup('lifechoice','life choice',{'Eat','Drink','Be Merry'},2,...
    %                 'Choose what is most important to you');
    %     zdlg.AddGridParameters('grid',0,'deg',3,'deg',5,'km');
    %     zdlg.AddBasicEdit('noiselevel','Noise level', obj.noiselevel,...
    %                   'how much noise should?');
    %     zdlg.AddBasicCheckbox('usenoise','use noise level', false,{'noiselevel','noiselevel_label'},...
    %                   'Should noise be applied to the data?');
    %     zdlg.AddBasicCheckbox('cleverness','be clever', false,...
    %                   'if checked, then plot is cleverly drawn');
    %     zdlg.AddEventSelectionParameters('evtparams', 100, 5)
    %     zdlg.Create('my dialog title');
    %
    %   end
    %
    %  function doit(obj)
    %       obj.CheckPreconditions();
    %       obj.Calculate();
    %       obj.plot();
    %  end
    %  end % methods
    
    properties
        hCaller; % handle to the caller. Values are written to hCaller.(tag) upon OK
        callerOKFunction=[]; % to be run once values are copied back to caller and dialog disappears
        hDialog; % handle to the dialog box
        parts={}; % ui details go here
        okPressed=false;
    end
    
    methods
        function obj=ZmapFunctionDlg(hCaller,okevent)
            % hCaller is the handle to the calling Function.
            % output values are returned to hCaller.(tag) for each uicontrol
            % once the OK button is pressed. if the OK button is not pressed, no changes are made
            % okevent (a function handle) will be executed if OK is pressed
            if ~exist('hCaller','var') || isempty(hCaller)
                obj.hCaller=struct();
            else
                obj.hCaller=hCaller;
            end
            %if isempty(hCaller)
            %    warning('values cannot be saved to the calling function. they''l be written to base');
            %end
            if exist('okevent','var')
                obj.callerOKFunction=okevent;
            else
                if ishandle(obj.hCaller)
                    obj.callerOKFunction=@(src,~) fprintf('ZmapFunctionDialog: no OK function was specified for the %s object, so it will not be notified\n',class(obj.hCaller));
                end
            end
        end
        
        function [results,okPressed]=Create(obj, dlgTitle)
            % creates a dialog box based on a cell description of types within.
            obj.okPressed=false;
            assert(~isempty(obj.parts),'Dialog cannot be created unless there are parts to add to it');
            hasGrid=false;
            hasEvSel=false;
            for n=1:numel(obj.parts)
                hasGrid= hasGrid || strcmp(obj.parts{n}.Style,'gridparameterbox');   
                hasEvSel= hasEvSel || strcmp(obj.parts{n}.Style,'eventselectparameterbox'); 
            end
            %hasGridGroup=any(strcmp(inFields(:,1),'gridparameterbox'));
            didGrid=false;
            didEvSel=false;
            
            nFields=numel(obj.parts);
            buttonSpace=60;
            rowH=35;
            dlgH=(nFields+1) * rowH + buttonSpace ...
                + hasGrid * GridParameterChoice.GROUPHEIGHT ...
                + hasEvSel * EventSelectionChoice.GROUPHEIGHT;
            
            dlgW=330;
            
            labelX=10;
            labelW=150;
            labelY=@(n,didGridParam,didEvSelParam) dlgH - rowH*(n+1) ...
                - didGridParam * GridParameterChoice.GROUPHEIGHT ...
                - didEvSelParam * EventSelectionChoice.GROUPHEIGHT;
            
            editX = labelX+labelW +20;
            editW = dlgW - editX - 15;
            
            setOnCompletion={}; % uicontrols that require further setting after all items created
            
            
            obj.hDialog=figure('Name',dlgTitle,...
                'MenuBar', 'none',...
                'InnerPosition',[10 10 dlgW dlgH],...
                'NumberTitle','off'...
                );
            
            for i=1:nFields
                details=obj.parts{i};
                switch lower(details.Style)
                    case 'gridparameterbox'
                        didGrid=true;
                        obj.parts{i}.handle = GridParameterChoice(obj.hDialog,details.Tag,...
                            [labelX labelY(i,didGrid,didEvSel) dlgW-labelX rowH-10],...
                            details.dx, details.dy, details.dz);
                        
                    case 'eventselectparameterbox'
                        didEvSel=true;
                        obj.parts{i}.handle = EventSelectionChoice(obj.hDialog,details.Tag,...
                            [labelX labelY(i,didGrid,didEvSel) dlgW-labelX rowH-10],...
                            details.maxnum, details.maxrad, details.minvalid);
                        
                    case 'header'
                        obj.parts{i}.handle=uicontrol('Style','text',...
                            'String',[details.String, ' : '],...
                            'FontWeight','bold',...
                            'Position',[labelX labelY(i,didGrid,didEvSel) dlgW-labelX rowH-10]);
                        
                    case 'checkbox'
                        obj.parts{i}.handle=uicontrol('Style','checkbox',...
                            'Value',details.Value,...
                            'String',details.String,...
                            'Callback',details.Callback,...
                            'Tag',details.Tag,...
                            'ToolTipString',details.ToolTipString,...
                            'Position',[labelX labelY(i,didGrid,didEvSel) labelW+30 rowH-10]);
                        if ~isempty(details.Callback)
                            setOnCompletion=[setOnCompletion; {details.Tag}];
                        end
                    case 'popupmenu'
                        uicontrol('Style','text',...
                            'String',[details.Label, ' : '],...
                            'HorizontalAlignment','right',...
                            'Position',[labelX labelY(i,didGrid,didEvSel) labelW-50 rowH-10]);
                        obj.parts{i}.handle=uicontrol('Style','popupmenu',...
                            'Value',details.Value,...
                            'String',details.String,...
                            'Callback',details.Callback,...
                            'Tag',details.Tag,...
                            'ToolTipString',details.ToolTipString,...
                            'Position',[editX-50 labelY(i,didGrid,didEvSel) editW+50 rowH-10]);
                    case 'edit'
                        uicontrol('Style','text',...
                            'String',[details.Label, ' : '],...
                            'HorizontalAlignment','right',...
                            'Position',[labelX labelY(i,didGrid,didEvSel) labelW rowH-10],...
                            'ToolTipString',details.ToolTipString,...
                            'Tag',[details.Tag '_label']);
                        
                        % this handles special cases, such as durations and datetime
                        [userData, mystr] = value2String(details.ClassName, details.Label, details.Value);
                        try
                        obj.parts{i}.handle=uicontrol('Style','edit',...
                            'Value',details.Value,...
                            'String',mystr,...
                            'Callback',details.Callback,...
                            'Tag',details.Tag,...
                            'UserData',userData,...
                            'ToolTipString',details.ToolTipString,...
                            'Position',[editX labelY(i,didGrid,didEvSel) editW rowH-10]);
                        catch
                            %messy way.  should check for datetime
                        obj.parts{i}.handle=uicontrol('Style','edit',...
                            'String',mystr,...
                            'Callback',details.Callback,...
                            'Tag',details.Tag,...
                            'UserData',userData,...
                            'ToolTipString',details.ToolTipString,...
                            'Position',[editX labelY(i,didGrid,didEvSel) editW rowH-10]);
                        end
                        
                    otherwise
                        error('unknown control');
                end
            end
            
            obj.addCancelButton([dlgW-200 10 70 buttonSpace/2]);
            obj.addOKButton([dlgW-90 10 70 buttonSpace/2]);
            
            % checkboxes may have callbacks that affect other uicontrols' Enable status.
            % now that all uicontrols have been created, disable/enable as dictated by the
            % checkbox state
            
            for n=1:numel(setOnCompletion)
                src=obj.findDlgTag(setOnCompletion{n});
                src.Callback(src,[]);
            end
            
            results=[];
            
            % if we are expecting an answer, wait until dialog is finished.
            if nargout > 0
                uiwait(obj.hDialog)
                if isstruct(obj.hCaller)
                    results=obj.hCaller;
                end
            end
            okPressed = obj.okPressed;
        end
        
        %% methods to declare uicontrols
        
        function AddBasicHeader(obj, String)
            % add a simple header to the dialog box
            % AddBasicHeader(text)
            details=struct(...
                'Style','header',...
                'Tag','',...
                'String',String);
            obj.parts(end+1)={details};
        end
        
        function AddBasicPopup(obj,tag, label, choices, defaultChoice,tooltip)
            %AddBasicPopup represents a pop-up menu
            % AddBasicPopup(obj,tag, label, choices, defaultChoice,tooltip)
            details=struct(...
                'Style','popupmenu',...
                'Tag',tag,...
                'Label',label,...
                'String',{choices},...
                'Value',defaultChoice,...
                'Callback',[],...
                'ToolTipString',tooltip);
            obj.parts(end+1)={details};
        end
        
        function AddBasicEdit(obj,tag, label, value,tooltip)
            % AddBasicEdit adds an edit-box & text label combo
            % AddBasicEdit(obj,tag, label, value,tooltip)
            %
            % callback is determined by the value's type
            if isnumeric(value)
                % put num2str(value) into String
                callback=@cb_str2numeric;
                
            elseif isduration(value)
                callback=@cb_str2duration;
            elseif isdatetime
                callback=@cb_str2datetime;
            elseif ischar(value)
                callback=@cb_str2str;
            else
                callback=str2func(['cb_str2', class(value)]);
            end
            
            details=struct(...
                'Style','edit',...
                'Tag',tag,...
                'Label',label,...
                'ClassName',class(value),...
                'Value',value,...
                'Callback',callback,...
                'ToolTipString',tooltip);
            obj.parts(end+1)={details};
        end
        
        function AddBasicCheckbox(obj,tag, String, isOn,dependentTags,tooltip)
            % AddBasicCheckbox adds a checkbox to the dialog box
            % AddBasicCheckbox(obj,tag, String, isOn,dependentTags,tooltip)
            %
            % dependentTags will be enabled/disabled based on the value of this checkbox
            %convert to type, tag, label, defaultString, defaultValue, callback
            
            if exist('dependentTags','var') && iscell(dependentTags)
                cb=@(src,~)obj.cb_enableDependents(src,dependentTags);
            else
                cb=[];
            end
            details=struct(...
                'Style','checkbox',...
                'Tag',tag,...
                'String',String,...
                'Value',isOn,...
                'Callback',cb,...
                'ToolTipString',tooltip);
            obj.parts(end+1)={details};
        end
        
        function AddGridParameters(obj,tag,dx,dxunits, dy,dyunits, dz,dzunits) 
            % Add a grid parameter widget to the box.
            % AddGridParameters(obj,tag,dx,dxunits, dy,dyunits, dz,dzunits)
            % retrieved values will be found in a structure
            % tag.dx
            % tag.dy
            % tag.dz
            % tag.dx_units
            % tag.dy_units
            % tag.dz_units,
            % tag.gridEntireArea
            % tag.SaveGrid
            % tag.LoadGrid
            % tag.CreateGrid
            %
            % see also GridParameterChoice
            
            details=struct(...
                'Style','gridparameterbox',...
                'Tag',tag,...
                'dx',{{dx, dxunits}},...
                'dy',{{dy, dyunits}},...
                'dz',{{dz, dzunits}});
            obj.parts(end+1)={details};
            
        end
        
        function AddEventSelectionParameters(obj, tag, ni, ra, minvalid)
            %AddEventSelectionParameters Choose between events in a radius, or closest N events
            %AddEventSelectionParameters(obj, tag, ni, ra, minvalid)
            % used to define how each grid point will select events
            %
            % returns structure
            % tag.numNearbyEvent
            % tag.radius_km
            % tag.useNumNearbyEvent
            % tag.useEventsInRadius
            % tag.requiredNumEvents
            % tag.maxRadiusKm
            %
            % see also EventSelectionChoice, EventSelectionChoice.toStruct
            if ~exist('minvalid','var')
                minvalid=0;
            end
            details=struct(...
                'Style','eventselectparameterbox',...
                'Tag',tag,...
                'maxnum',ni,...
                'maxrad',ra,...
                'minvalid',minvalid);
            obj.parts(end+1)={details};
        end
        
        %% uicontrol parts
        
        % if there are other COMMONLY used button behaviors, perhaps they
        %would go here.
        
        function addOKButton(obj,position) % add it to Dialog
            % create "go" button -> modifies properties, closes figure, does calculation
            uicontrol('style','pushbutton','String','go',...
                'Position',position,...
                'Callback',@(src,~)obj.okDlg());
        end
        
        function addCancelButton(obj,position) %add it to Dialog
            % create "cancel" button -> leaves properties unchanged, closes figure
            
            uicontrol('style','pushbutton','String','cancel',...
                'Position',position,...
                'Callback',@(src,~)obj.clearDlg());
        end
        
        
        %% object dependent callbacks
        function cb_enableDependents(obj,src,tags)
            % enables/disables fields with listed tags based on the value of this checkbox
            % tags must be a cell of strings, but can be empty cell
            if src.Value==1
                setting='on';
            else
                setting='off';
            end
            for n=1:numel(tags)
                set(findDlgTag(obj,tags{n}),'Enable',setting);
            end
            
        end
        
        function clearDlg(obj)
            % close the dialog box (without making any changes)
            % this should be the callback for the cancel/clear buttons for
            % the interactive dialog boxes
            obj.okPressed=false;
            close(obj.hDialog);
            obj.hDialog=[];
        end
        
                
        function okDlg(obj)
            % copy values back to caller hCaller, using tags as reference.
            obj.okPressed=true;
            for n=1:numel(obj.parts)
                tag=obj.parts{n}.Tag;
                h = obj.parts{n}.handle;
                if ~isempty(tag) && (~isprop(obj.hCaller,tag) && ~isstruct(obj.hCaller))
                    warning('unable to assign value back to caller because the property %s does not exist',tag);
                end
                switch obj.parts{n}.Style
                    case 'header'
                        % ignore
                    case 'gridparameterbox'
                        obj.hCaller.(tag)=h.toStruct();
                    case 'eventselectparameterbox'
                        obj.hCaller.(tag)=h.toStruct();
                    otherwise
                        if ~isempty(h.UserData)
                            obj.hCaller.(tag)=h.UserData;
                        else
                            obj.hCaller.(tag)=h.Value;
                        end
                end
            end
            close(obj.hDialog);
            
            if ~isempty(obj.callerOKFunction)
                obj.callerOKFunction(); % call the caller's method before quitting
            end
        end
        
        %% helper functions
        function h=findDlgTag(obj,tag)
            % findDlgTag returns handles for this object's dialog box that have a specific tag
            h=findobj(obj.hDialog,'Tag',tag);
        end
    end
    
end

%% helper functions

function [userData, mystr] = value2String(className, label, value)
    userData=[]; % used when interpreting durations
    switch className
        case 'datetime'
            mystr=string(value,'uuuu-MM-dd hh:mm:ss');
        case 'duration'
            if contains(lower(label),{'year','yr'})
                userData=1;
                mystr=years(value);
            elseif contains(lower(label),'day')
                userData=3;
                mystr=days(value);
            elseif contains(lower(label),{'hr','hour'})
                userData=4;
                mystr=hours(value);
            elseif contains(lower(label),'min')
                userData=5;
                mystr=minutes(value);
            elseif contains(lower(label),'sec')
                userData=6;
                mystr=seconds(value);
            else
                error('label for a duration field must contain some indication of the units')
            end
        otherwise
            mystr=string(value);
            if ismissing(mystr)
                mystr='';
            end
    end
end

%% callbacks
function cb_str2numeric(src,~)
    % default callback that updates value for a string
    src.Value=str2double(src.String);
    src.UserData=src.Value;
end

function cb_str2datetime(src,~)
    src.UserData=datetime(src.String);
end

function cb_str2duration(src,~)
    % value encodes the original type
    % 1 year, 3 day, 4 hour, 5 minute, 6 second
    % (
    persistent getduration
    if isempty(getduration)
        getduration = {... to be indexed by type
            @(s) years(str2double(s.String)); ...   1 : years
            @(s) error('not a known function');...  2 : months (not applicable
            @(s) days(str2double(s.String));...     3 : days
            @(s) hours(str2double(s.String));...    4 : hours
            @(s) minutes(str2double(s.String));...  5 : minutes
            @(s) seconds(str2double(s.String)) ...  6 : seconds
            };
    end
    
    src.UserData = getduration{src.Value}(src);
end

function cb_str2str(src,~)
    src.UserData=src.String; % duplicates data, but makes retrieval easy
end

