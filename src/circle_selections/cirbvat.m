function cirbvat() 
    %   This subroutine "circle"  selects the Ni closest earthquakes
    %   around a interactively selected point.  Resets ZG.newcat and ZG.newt2
    %   Operates on "primeCatalog".
    %
    % axis: h1
    % figure bmap
    % plots to: plos1 as ow
    % inCatalog: a
    % outCatalog: newt2, newcat
    % mouse controlled
    % closest events
    % two date ranges
    % calls: bdiff
    %
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    %  Input Ni:
    %
    report_this_filefun();
    ZG=ZmapGlobal.Data;

    delete(findobj('Tag','plos1'));
    
    axes(h1)
    %zoom off
    
    titStr ='Selecting EQ in Circles                         ';
    messtext= ...
        ['                                                '
        '  Please use the LEFT mouse button              '
        ' to select the center point.                    '
        ' The "ni" events nearest to this point          '
        ' will be selected and displayed in the map.     '];
    
    msg.dbdisp(messtext, titStr);
    
    % Input center of circle with mouse
    %
    [xa0,ya0]  = ginput(1);
    
    stri1 = [ 'Circle: ' num2str(xa0,5) '; ' num2str(ya0,4)];
    stri = stri1;
    pause(0.1)
    %  calculate distance for each earthquake from center point
    [ZG.newt2, max_km] = ZG.primeCatalog.selectClosestEvents(ya0, xa0, [], ni);
    messtext = ['Radius of selected Circle:' num2str(max_km)  ' km' ];
    disp(messtext)
    %
    R2 = max_km;
    global t1 t2 t3 t4
    
    lt =  ZG.newt2.Date >= t1 &  ZG.newt2.Date <t2 ;
    bdiff(ZG.newt2.subset(lt));
    ZG.hold_state=true;
    lt =  ZG.newt2.Date >= t3 &  ZG.newt2.Date <t4 ;
    bdiff(ZG.newt2.subset(lt));
    
    % end % <- A random END that either doesn't belong here or is meant to suppress the rest. -CGR
    [st,ist] = sort(ZG.newt2);
    ZG.newt2.sort('Date');
    
    %
    % plot Ni clostest events on map as 'x':
    
    figure(bmap);
    set(gca,'NextPlot','add')
    plot(ZG.newt2.Longitude,ZG.newt2.Latitude,'ow','MarkerSize',3,'Tag','plos1');
    
    % plot circle containing events
    x = -pi-0.1:0.1:pi;
    plot(xa0+sin(x)*R2/(cosd(ya0)*111), ya0+cos(x)*R2/(cosd(ya0)*111),'k')
    
    
    set(gcf,'Pointer','arrow')
    
    
end
