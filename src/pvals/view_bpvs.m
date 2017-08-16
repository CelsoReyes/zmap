function view_bpvs() % autogenerated function wrapper
% This .m file "view_x
% maxz.m" plots the maxz LTA values calculated
% with maxzlta.m or other similar values as a color map
% needs re3, gx, gy, stri
%
% define size of the plot etc.
%
 % turned into function by Celso G Reyes 2017
 
ZG=ZmapGlobal.Data; % used by get_zmap_globals
if isempty(name)
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
%co = 'w';


% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('b and p -value cross-section',1);
newbpmapcsWindowFlag=~existFlag;

% This is the info window text
%
ttlStr='The b and p -Value Map Window                 ';
hlpStr1zmap= ...
    ['                                                '
    ' This window displays the b and p maps by       '
    ' using a color code.                            '
    ' Some of the menu-bar options are               '
    ' described below:                               '
    '                                                '
    ' Threshold: You can set the maximum size that   '
    '   a volume is allowed to have in order to be   '
    '   displayed in the map. Therefore, areas with  '
    '   a low seismicity rate are not displayed.     '
    '   edit the size (in km) and click the mouse    '
    '   outside the edit window.                     '
    'FixAx: You can chose the minimum and maximum    '
    '        values of the color-legend used.        '
    'Polygon: You can select earthquakes in a        '
    ' polygon either by entering the coordinates or  '
    ' defining the corners with the mouse            '];
hlpStr2zmap= ...
    ['                                                '
    'Circle: Select earthquakes in a circular volume:'
    '      Ni, the number of selected earthquakes can'
    '      be edited in the upper right corner of the'
    '      window.                                   '
    ' Refresh Window: Redraws the figure, erases     '
    '       selected events.                         '

    ' zoom: Selecting Axis -> zoom on allows you to  '
    '       zoom into a region. Click and drag with  '
    '       the left mouse button. type <help zoom>  '
    '       for details.                             '
    ' Aspect: select one of the aspect ratio options '
    ' Text: You can select text items by clicking.The'
    '       selected text can be rotated, moved, you '
    '       can change the font size etc.            '
    '       Double click on text allows editing it.  '
    '                                                '
    '                                                '];

% Set up the Seismicity Map window Enviroment
%
if newbpmapcsWindowFlag
    bpmapcs = figure_w_normalized_uicontrolunits( ...
        'Name','b and p -value cross-section',...
        'NumberTitle','off', ...
        ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    
    create_menu();
    lab1 = 'b-value';


    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Print ',...
         'callback',@callbackfun_001)

    callbackStr= ...
        ['f1=gcf; f2=gpf; set(f1,''Visible'',''off'');close(bpmapc);', ...
        'if f1~=f2, figure_w_normalized_uicontrolunits(map);done; end'];

    uicontrol('Units','normal',...
        'Position',[.0 .75 .08 .06],'String','Close ',...
         'callback',@callbackfun_002)

    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'callback',@callbackfun_003)

    uicontrol('Units','normal',...
        'Position',[.0 .02 .08 .06],'String','zoom ',...
         'callback',@callbackfun_004)

    uicontrol('Units','normal',...
        'Position',[.92 .80 .08 .05],'String','set ni',...
         'callback',@callbackfun_028)


    set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
    set(set_nia,'callback',@callbackfun_029);
    set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
    nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
    set(nilabel,'string','ni:','background',[.7 .7 .7]);

    %tx = text(0.07,0.95,[name],'Units','Norm','FontSize',18,'Color','k','FontWeight','bold');

    tresh = max(max(r)); re4 = re3;

    colormap(jet)

end   % This is the end of the figure setup

% Now lets plot the color-map of the b and p -value.
%
figure_w_normalized_uicontrolunits(bpmapcs)
delete(gca)
delete(gca)
delete(gca)
dele = 'delete(sizmap)';er = 'disp('' '')'; eval(dele,er);
reset(gca)
cla
hold off
watchon;
set(gca,'visible','off','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','SortMethod','childorder')

rect = [0.18,  0.10, 0.7, 0.75];
rect1 = rect;

% find max and min of data for automatic scaling
ZG.maxc = max(max(re3));
ZG.maxc = fix(ZG.maxc)+1;
ZG.minc = min(min(re3));
ZG.minc = fix(ZG.minc)-1;


% set values greater tresh = nan
%
re4 = re3;
l = r > tresh;
re4(l) = NaN(1,length(find(l)));
l = Prmap < minpe;
re4(l) = NaN(1,length(find(l)));
l = old1 <  Mmin;
re4(l) = NaN(1,length(find(l)));
l = pvstd >  minsd;
re4(l) = NaN(1,length(find(l)));


% plot image
%
orient landscape
%set(gcf,'PaperPosition', [2. 1 7.0 5.0])

axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis image
hold on
if sha == 'fl'
    shading flat
else
    shading interp
end


%If the colorbar is freezed
if fre == 1
    caxis([fix1 fix2])
end

title([name ';  '   num2str(t0b,4) ' to ' num2str(teb,4) ],'FontSize',ZmapGlobal.Data.fontsz.m,...
    'Color','w','FontWeight','bold')

xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('Depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

% plot overlay
%
hold on
ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.k');
set(ploeqc,'Tag','eqc_plot','MarkerSize',ZG.ms6,'Marker',ty,'Color',co,'Visible',vi)

if exist('vox', 'var')
    plovo = plot(vox,voy,'*b');
    set(plovo,'MarkerSize',6,'LineWidth',1)
end

if exist('maix', 'var')
    pl = plot(maix,maiy,'*k');
    set(pl,'MarkerSize',12,'LineWidth',2)
end

if exist('maex', 'var')
    pl = plot(maex,-maey,'hm');
    set(pl,'LineWidth',1.5,'MarkerSize',12,...
        'MarkerFaceColor','w','MarkerEdgeColor','k')
end

if exist('wellx', 'var')
    hold on
    plwe = plot(wellx,-welly,'w')
    set(plwe,'LineWidth',2);
end

set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colorbar
%

h5 = colorbar('horiz');
%apo = get(h1,'pos');
set(h5,'Pos',[0.35 0.05 0.4 0.02],...
    'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m,'TickDir','out')

rect = [0.00,  0.0, 1 1];
axes('position',rect)
axis('off')
%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Position',[ 0.33 0.06 0 ],...
    'HorizontalAlignment','right',...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.m,....
    'FontWeight','bold',...
    'String',lab1);

% Make the figure visible
%
axes(h1)
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
%whitebg(gcf,[0 0 0])
%set(gcf,'Color',[ 0 0 0 ])
figure_w_normalized_uicontrolunits(bpmapcs);
%axes(h1);
watchoff(bpmapcs);
done

%% ui functions
function create_my_menu()
	add_menu_divider();

    add_symbol_menu('eqc_plot');

    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'callback',@callbackfun_005)
    uimenu(options,'Label','Select EQ in Circle (const N)',...
         'callback',@callbackfun_006)
    uimenu(options,'Label','Select EQ in Circle (const R)',...
         'callback',@callbackfun_007)
    uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
         'callback',@callbackfun_008)
    uimenu(options,'Label','Select Eqs in Polygon - new',...
         'callback',@callbackfun_009);
    uimenu(options,'Label','Select Eqs in Polygon - hold',...
         'callback',@callbackfun_010);

    op1 = uimenu('Label',' Maps ');

    %Meniu for adjusting several parameters.
    adjmenu =  uimenu(op1,'Label','Adjust Map Display Parameters'),...
        uimenu(adjmenu,'Label','Adjust Mmin cut',...
         'callback',@callbackfun_011)
    uimenu(adjmenu,'Label','Adjust Rmax cut',...
         'callback',@callbackfun_012)
    uimenu(adjmenu,'Label','Adjust goodness of fit cut',...
         'callback',@callbackfun_013)
    uimenu(adjmenu,'Label','Adjust p-value st. dev. cut',...
         'callback',@callbackfun_014)

    uimenu(op1,'Label','b-value map (WLS)',...
         'callback',@callbackfun_015)
    uimenu(op1,'Label','b(max likelihood) map',...
         'callback',@callbackfun_016)
    uimenu(op1,'Label','mag of completness map',...
         'callback',@callbackfun_017)
    uimenu(op1,'Label','max magnitude map',...
         'callback',@callbackfun_018)
    uimenu(op1,'Label','magnitude range map (Mmax - Mcomp)',...
         'callback',@callbackfun_019)

    uimenu(op1,'Label','p-value',...
         'callback',@callbackfun_020)
    uimenu(op1,'Label','p-value standard deviation',...
         'callback',@callbackfun_021)


    uimenu(op1,'Label','Goodness of fit to power law map',...
         'callback',@callbackfun_022)

    uimenu(op1,'Label','a-value map',...
         'callback',@callbackfun_023)
    uimenu(op1,'Label','standard error map',...
         'callback',@callbackfun_024)
    uimenu(op1,'Label','(WLS-Max like) map',...
         'callback',@callbackfun_025)


    uimenu(op1,'Label','resolution Map',...
         'callback',@callbackfun_026)
    uimenu(op1,'Label','Histogram ', 'callback',@callbackfun_027)

    add_display_menu(3)

end

%% callback functions

function callbackfun_001(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_001');
  myprint;
end
 
function callbackfun_002(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_002');
  eval(callbackStr);
end
 
function callbackfun_003(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_003');
  zmaphelp(ttlStr,hlpStr1zmap,hlpStr2zmap);
end
 
function callbackfun_004(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_004');
  zoomrb;
end
 
function callbackfun_005(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_005');
  view_bpvs;
end
 
function callbackfun_006(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_006');
   h1 = gca;
  ZG=ZmapGlobal.Data;
  ZG.hold_state=false;
  cicros(1);
end
 
function callbackfun_007(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_007');
   h1 = gca;
  ZG=ZmapGlobal.Data;
  ZG.hold_state=false;
  cicros(2);
end
 
function callbackfun_008(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_008');
  h1 = gca;
  ZG=ZmapGlobal.Data;
  ZG.hold_state=true;
  cicros(0);
end
 
function callbackfun_009(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_009');
  ZG=ZmapGlobal.Data;
  ZG.hold_state=false;
  polyb;
end
 
function callbackfun_010(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_010');
  ZG=ZmapGlobal.Data;
  ZG.hold_state=true;
  polyb;
end
 
function callbackfun_011(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_011');
  asel = 'mag';
   adju2;
   view_bpvs ;
end
 
function callbackfun_012(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_012');
  asel = 'rmax';
   adju2;
   view_bpvs;
end
 
function callbackfun_013(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_013');
  asel = 'gofi';
   adju2;
   view_bpvs ;
end
 
function callbackfun_014(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_014');
  asel = 'pstdc';
   adju2;
   view_bpvs ;
end
 
function callbackfun_015(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_015');
  lab1 ='b-value';
   re3 = old;
   view_bpvs;
end
 
function callbackfun_016(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_016');
  lab1='b-value';
   re3 = meg;
   view_bpvs;
end
 
function callbackfun_017(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_017');
  lab1 = 'Mcomp';
   re3 = old1;
   view_bpvs;
end
 
function callbackfun_018(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_018');
   lab1='Mmax';
  re3 = maxm;
   view_bpvs;
end
 
function callbackfun_019(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_019');
   lab1='dM ';
  re3 = maxm-magco;
   view_bpvs;
end
 
function callbackfun_020(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_020');
   lab1='p-value';
  re3 = pvalg;
   view_bpvs;
end
 
function callbackfun_021(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_021');
   lab1='p-valstd';
  re3 = pvstd;
   view_bpvs;
end
 
function callbackfun_022(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_022');
  lab1 = ' % ';
   re3 = Prmap;
   view_bpvs;
end
 
function callbackfun_023(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_023');
  lab1='a-value';
  re3 = avm;
   view_bpvs;
end
 
function callbackfun_024(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_024');
   lab1='error in b';
  re3 = pro;
   view_bpvs;
end
 
function callbackfun_025(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_025');
   lab1='difference in b';
  re3 = old-meg;
   view_bpvs;
end
 
function callbackfun_026(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_026');
  lab1='Radius in [km]';
  re3 = r;
   view_bpvs;
end
 
function callbackfun_027(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_027');
  zhist;
end
 
function callbackfun_028(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_028');
  ni=str2num(set_nia.String);
  'String';
  num2str(ni);
end
 
function callbackfun_029(mysrc,myevt)
  % automatically created callback function from text
  callback_tracker(mysrc,myevt,mfilename('fullpath'),'callbackfun_029');
end
 
end
