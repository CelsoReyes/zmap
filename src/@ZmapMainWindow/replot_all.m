function replot_all(obj,metaProp,eventData)
    % REPLOT all the windows
    %
    % REPLOT_ALL(obj)
    % REPLOT_ALL(obj, metaProp, eventData) when called from listener
    % REPLOT_ALL(obj, eventName) when called elsewhere
    narginchk(1,3)
    eventName = 'ReplotAll'; %default event name
    switch nargin
        case 1
            % called with obj only
            % msg.dbdisp(['Replotting because:', eventName]);
        case 2
            % called elsewhere with an EventName
            eventName = metaProp;
            % msg.dbdisp(['Replotting because:', eventName]);
        case 3
            % called by listener, with metaProp and eventData
             if eventData.EventName ~= "PostSet"
                 eventName = eventData.EventName;
             end
             if isprop(metaProp,'Name')
                 % msg.dbdisp(['Replotting because:', eventName, ' (', metaProp.Name, ')' ]);
             else
                 % msg.dbdisp(['Replotting because:', eventName, ' [', class(metaProp) ']' ]);
             end
    end
    
    obj.AllAxes=findobj(obj.fig,'Type','axes');
    
    md=[];
    k={};
    obj.set_figure_name();
    
    s=sprintf('Created by: ZMAP %s , %s',ZmapData.zmap_version, char(datetime));
    set(findobj(obj.fig,'Tag','zmap_watermark','-and','Type','uicontrol','-and','Style','text'),...
        'String',s);
    
    obj.replotting=true;
    switch eventName
        case 'XsectionAdded'
            % msg.dbdisp('add a cross section to plots')
            k=obj.XSectionTitles;
            if numel(k) > 1
                k = k(~ismember(k,get(obj.xsgroup.Children,'Title')));
            end
            
        case {'XsectionRemoved'}
            % msg.dbdisp('remove cross section from plots')
            
        case {'XsectionChanged'}
            % msg.dbdisp('replot cross sections')
            k=obj.XSectionTitles;
            
        case 'XsectionEmptied'
            
        case {'CatalogChanged','ReplotAll','DateRangeChanged','ShapeChanged'}
            % msg.dbdisp('replot everything touched by catalog')
            k=obj.XSectionTitles;
            
            obj.undohandle.Enable=tf2onoff(~isempty(obj.prev_states));
            [md, ~, mall]=obj.filter_catalog(); %md:mask date, ms:mask shape   % only show events if they aren't all selected
            evs=findobj(obj.maintab,'Tag','all events');
            if all(mall)
                evs.Visible='off';
            else
                if numel(evs.XData)==numel(obj.rawcatalog.Count)
                    evs.XData(mall)=nan;
                    evs.XData(~mall)=obj.rawcatalog.X(~mall);
                else
                    % catalog is out of sync. replot
                    evs.XData       = obj.rawcatalog.X;
                    evs.YData       = obj.rawcatalog.Y;
                    evs.ZData       = obj.rawcatalog.Z;
                    evs.XData(mall) = nan;
                end
                evs.Visible=get(findobj(obj.fig,'Label','Show unselected events'),'Checked');
                
            end
            ZG = ZmapGlobal.Data;
            obj.bigEvents = obj.catalog.subset(ZG.CatalogOpts.BigEvents.MinMag < obj.catalog.Magnitude);
            obj.CatalogManager.ChangeFilter('big events', @(c) c.Magnitude > ZmapGlobal.Data.CatalogOpts.BigEvents.MinMag);
            obj.plotmainmap();
        otherwise
            k=obj.XSectionTitles;
            fprintf('uncaught event: [%s]\n',eventName);
    end
    
    if ~isvalid(obj.fig)
        errordlg('Figure associated with this ZmapMainWindow has been deleted!');
        return
    end
    
    for j=1:numel(k)
        plot_xsection(obj,k{j},md);
    end
    
    obj.fmdplot('Upper Right panel');
    obj.plothist('Magnitude','Upper Right panel');
    obj.cumplot('Lower Right panel');
    
    obj.cummomentplot('Lower Right panel');
    obj.timedepthplot('Lower Right panel');
    obj.timemagplot('Lower Right panel');
    
    obj.replotting=false;
    drawnow nocallbacks
    
    rearrange_axes_items(obj)
end

function rearrange_axes_items(obj)
    % rearrange main axes items into specific order
    ch=obj.map_axes.Children;
    tags = get(ch,'Tag');
    items.map = startsWith(tags,'mainmap_');
    items.grid = startsWith(tags,'grid_');
    items.bgevents = tags == "all events";
    items.fgevents = tags == "active quakes";
    items.bigevents = tags == "big events";
    items.shape = startsWith(tags,'shape');
    items.crosssec = startsWith(tags,'Xsection ');
    items.topos = startsWith(tags,'topographic_');
    
    
    items.other = ~(items.map | items.grid | items.shape |...
        items.bgevents | items.fgevents | items.bigevents |...
        items.crosssec | items.topos);
    obj.map_axes.SortMethod='childorder';
    obj.map_axes.Children = [ ... from top to bottom
        ch(items.shape);...
        ch(items.crosssec); ...
        ch(items.bigevents); ...
        ch(items.fgevents); ...
        ch(items.other); ...
        ch(items.bgevents); ...
        ch(items.map);...
        ch(items.grid);...
        ch(items.topos)];   
end

function [mytab] = plot_xsection(obj, mytitle, md)
    % plot into the xsection tab area
    set(gca,'NextPlot','add')
    idx = strcmp(obj.XSectionTitles, mytitle);
    
    % only reproject if the catalog is changed since memorizing
    if ~isequal(obj.rawcatalog.summary(), obj.xscatinfo(mytitle))
        
        % store the projected catalog. only events within the strip [ignoring shape] are stored
        if ~isempty(md)
            tempCatalog = obj.CrossSections(idx).project(obj.rawcatalog.subset(md));
        else
            tempCatalog = obj.CrossSections(idx).project(obj.rawcatalog);
        end
        obj.append_xsec_to_catalog_name(tempCatalog, mytitle);
        obj.xscats(mytitle) = tempCatalog;
        
        % store the information about the current catalog used to project
        obj.xscatinfo(mytitle) = obj.rawcatalog.summary();
        
        % plot
        mytab=findobj(obj.xsgroup,'Title', mytitle,'-and','Type','uitab');
        if isempty(mytab)
            % we lost the tab somehow.
        end
        myax = findobj(mytab,'Type','axes');
        obj.CrossSections(idx).plot_events_along_strike(myax,obj.xscats(mytitle),true);
        myax.Title = [];
    end
end

