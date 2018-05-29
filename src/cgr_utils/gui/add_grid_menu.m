function add_grid_menu(obj)
    % add grid menu for modifying grid in a ZmapMainWindow
    parent = uimenu(obj.fig,'Label','Sampling');
    uimenu(parent,'Label','Quick-Grid (auto)',Futures.MenuSelectedFcn,@cb_autogrid);
    uimenu(parent,'Label','Define Grid',Futures.MenuSelectedFcn,@cb_gridfigure);
    uimenu(parent,'Label','Redraw Grid',Futures.MenuSelectedFcn,@cb_refresh);
    uimenu(parent,'Label','Clear Grid (Delete)',Futures.MenuSelectedFcn,@cb_clear);
    uimenu(parent,'Separator','on','Label','Create Auto Sample Radius',Futures.MenuSelectedFcn,@cb_autoradius);
    uimenu(parent,'Label','Choose Sample Radius',Futures.MenuSelectedFcn,@cb_manualradius);
    uimenu(parent,'Separator','on','Label','Select events in CIRCLE',...
        Futures.MenuSelectedFcn,@cb_makecircle);
    uimenu(parent,'Label','Select events in BOX',...
        Futures.MenuSelectedFcn,@cb_makebox);
    uimenu(parent,'Label','Select events in POLYGON',...
        Futures.MenuSelectedFcn,@cb_makepolygon);
    uimenu(parent,'Label','Clear shape selection',...
        Futures.MenuSelectedFcn,@cb_clear_shape)
    
    function cb_makecircle(src,ev)
        bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh=ShapeCircle.selectUsingMouse(obj.map_axes);
        set_my_shape(obj,sh);
    end
    
    function cb_makebox(src,ev)
        bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh=ShapePolygon('box');
        set_my_shape(obj,sh);
    end
    
    function cb_makepolygon(src,ev)
        bringToForeground(findobj(obj.fig,'Tag','mainmap_ax'));
        sh=ShapePolygon('polygon');
        set_my_shape(obj,sh);
    end
    
    
    
    function cb_autogrid(~,~)
        % following assumes grid from main map
        
        if ~isempty(obj.Grid)
            todel=findobj(obj.map_axes,'Tag',['grid_', obj.Grid.Name]);
        else
            todel=[];
        end
        delete(todel);
        
        [tmpgrid,obj.gridopt]=autogrid(obj.catalog,...
            false,... % plot histogram
            true... % put on map
            );
        obj.Grid = tmpgrid.MaskWithShape(obj.shape);
        obj.Grid.plot(obj.map_axes,'ActiveOnly');

    end
    
    function cb_gridfigure(src,ev)
        [obj.Grid, obj.gridopt] = GridOptions.fromDialog(obj.gridopt);
        
        obj.Grid.plot(obj.map_axes,'ActiveOnly');
    end
    
    function cb_autoradius(~,~)
        ZG=ZmapGlobal.Data;
        sdlg.prompt='Required Number of Events:'; sdlg.value=ZG.ni;
        sdlg(2).prompt='Percentile:'; sdlg(2).value=50;
        sdlg(3).prompt='reach:' ; sdlg(3).value=1.5;
        [~,cancelled,minNum,pct,reach]=smart_inputdlg('automatic radius',sdlg);
        if cancelled
            beep
            return
        end
        [r, evselch] = autoradius(obj.catalog, obj.Grid, minNum, pct, reach);
        ZG.ra=r;
        ZG.ni=minNum;
        ZG.GridSelector=evselch;
        obj.set_event_selection(evselch);
        
    end
    function cb_manualradius(~,~)
        ev = obj.get_event_selection;
        if isempty(ev)
            [evselch, okpressed] = EventSelectionChoice.quickshow(true);
        else
            [evselch, okpressed] = EventSelectionChoice.quickshow(false,ev.numNearbyEvents,ev.maxRadiusKm,ev.requiredNumEvents);
        end
        if okpressed
            obj.set_event_selection(evselch);
        end
        
        % send message that global grid changed
    end

    function cb_refresh(~,~)
        if isempty(obj.Grid)
            warning('no grid exists to refresh')
            warndlg('no grid exists to refresh')
            return
        end
        delete(findobj(obj.fig,'Tag',['grid_',obj.Grid.Name]))
        obj.Grid=obj.Grid.MaskWithShape(obj.shape);
        obj.Grid.plot(obj.map_axes,'ActiveOnly');
    end
    
    function cb_clear(~,~)
        try
            obj.Grid = obj.Grid.delete();
        catch ME
            warning(ME.message)
        end
    end
        
end