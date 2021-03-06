% This .m file "view_x
% maxz.m" plots the maxz LTA values calculated
% with maxzlta.m or other similar values as a color map
% needs re3, gx, gy, stri
%
% define size of the plot etc.
%
if isempty(name) >  0
    name = '  '
end
think
report_this_filefun(mfilename('fullpath'));
co = 'w';


% Find out of figure already exists
%
[existFlag,figNumber]=figure_exists('b-value cross-section',1);
newbmapcWindowFlag=~existFlag;

% This is the info window text
%
ttlStr='The Z-Value Map Window                        ';
hlpStr1zmap= ...
    ['                                                '
    ' This window displays seismicity rate changes   '
    ' as z-values using a color code. Negative       '
    ' z-values indicate an increase in the seismicity'
    ' rate, positive values a decrease.              '
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
if newbmapcWindowFlag
    bmapc = figure_w_normalized_uicontrolunits( ...
        'Name','b-value cross-section',...
        'NumberTitle','off', ...
        'MenuBar','none', ...
        'backingstore','on',...
        'Visible','off', ...
        'Position',[ (fipo(3:4) - [600 400]) ZmapGlobal.Data.map_len]);
    % make menu bar
    matdraw
    lab1 = 'b-value';

    add_symbol_menu('eqc_plot');

    uicontrol('Units','normal',...
        'Position',[.0 .93 .08 .06],'String','Print ',...
         'Callback','myprint')

    callbackStr= ...
        ['f1=gcf; f2=gpf; set(f1,''Visible'',''off'');close(bmapc);', ...
        'if f1~=f2, figure_w_normalized_uicontrolunits(map);done; end'];

    uicontrol('Units','normal',...
        'Position',[.0 .75 .08 .06],'String','Close ',...
         'Callback','eval(callbackStr)')

    uicontrol('Units','normal',...
        'Position',[.0 .85 .08 .06],'String','Info ',...
         'Callback','zmaphelp(ttlStr,hlpStr1zmap,hlpStr2zmap)')


    options = uimenu('Label',' Select ');
    uimenu(options,'Label','Refresh ', 'Callback','view_bv2')
    uimenu(options,'Label','Select EQ in Circle',...
         'Callback',' h1 = gca;ho=false;cist;')
    uimenu(options,'Label','Select EQ in Circle - Overlay existing plot',...
         'Callback','h1 = gca;ho=true;cicros;')
    uimenu(options,'Label','Select Eqs in Polygon - new',...
         'Callback','ho=false;polyb;');
    uimenu(options,'Label','Select Eqs in Polygon - hold',...
         'Callback','ho=true;polyb;');

    op1 = uimenu('Label',' Tools ');
    uimenu(op1,'Label','Fix color (z) scale', 'Callback','fixax2 ')
    uimenu(op1,'Label','Histogram of b-values', 'Callback','zhist')
    uimenu(op1,'Label','Show  b-value Map',...
         'Callback','lab1=''b-value''; re3 = old; view_bv2')
    uimenu(op1,'Label','Show  b(mean) map',...
         'Callback',' lab1=''b-value'';re3 = 0.4343./(meg-min(newa(:,6))); view_bv2')
    uimenu(op1,'Label','Show  mean magnitude map',...
         'Callback',' lab1=''M'';re3 = meg; view_bv2')
    uimenu(op1,'Label','Show Probability Map',...
         'Callback','lab1=''Probability''; re3 = pro; view_bv2')
    uimenu(op1,'Label','Show  mag of completness map',...
         'Callback','lab1=''Mcomp''; re3 = old1; view_bv2')
    uimenu(op1,'Label','Show Resolution Map',...
         'Callback','lab1=''Radius in [km]'';re3 = r; view_bv2')
    uimenu(op1,'Label','Show Grid ',...
         'Callback',' [X,Y] = meshgrid(gx,gy);hold on;plot(X,Y,''+m'')')
    uimenu(op1,'Label','Show Circles ',...
         'Callback','plotcirc')
    uimenu(op1,'Label','Colormap InvertGray',...
         'Callback','g=gray; g = g(64:-1:1,:);colormap(g);brighten(.4)')
    uimenu(op1,'Label','shading flat',...
         'Callback','axes(hzma); shading flat')
    uimenu(op1,'Label','shading interpolated',...
         'Callback','axes(hzma); shading interp')

    uicontrol('Units','normal',...
        'Position',[.92 .80 .08 .05],'String','set ni',...
         'Callback','ni=str2num(get(set_nia,''String''));''String'',num2str(ni);')


    set_nia = uicontrol('style','edit','value',ni,'string',num2str(ni));
    set(set_nia,'Callback',' ');
    set(set_nia,'units','norm','pos',[.94 .85 .06 .05],'min',10,'max',10000);
    nilabel = uicontrol('style','text','units','norm','pos',[.90 .85 .04 .05]);
    set(nilabel,'string','ni:','background',[.7 .7 .7]);

    % tx = text(0.07,0.95,[name],'Units','Norm','FontSize',18,'Color','k','FontWeight','bold');

    tresh = max(max(r)); re4 = re3;
    nilabel2 = uicontrol('style','text','units','norm','pos',[.60 .92 .25 .06]);
    set(nilabel2,'string','MinRad (in km):','background',color_fbg);
    set_ni2 = uicontrol('style','edit','value',tresh,'string',num2str(tresh),...
        'background','y');
    set(set_ni2,'Callback','tresh=str2double(get(set_ni2,''String'')); set(set_ni2,''String'',num2str(tresh))');
    set(set_ni2,'units','norm','pos',[.85 .92 .08 .06],'min',0.01,'max',10000);

    uicontrol('Units','normal',...
        'Position',[.95 .93 .05 .05],'String','Go ',...
         'Callback','think;pause(1);re4 =re3; view_bv2')

end   % This is the end of the figure setup

% Now lets plot the color-map of the z-value
%
figure_w_normalized_uicontrolunits(bmapc)
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

% set values greater tresh = nan
%
re4 = re3;
l = r > tresh;
re4(l) = NaN(1,length(find(l)));

%l = re4 > min(bvgr(:,1)) &  re4 < max(bvgr(:,1)) ;
%l = re4 > mean(bvgr(:,1))-2*std(bvgr(:,1)) &  re4 <  mean(bvgr(:,1))+2*std(bvgr(:,1));
%re4(l) = NaN(1,length(find(l)));
%re4(l) = zeros(1,length(find(l)))+ mean(bvgr(:,1));

% plot image
%
orient portrait
%set(gcf,'PaperPosition', [2. 1 7.0 5.0])

axes('position',rect)
hold on
pco1 = pcolor(gx,gy,re4);

axis([ min(gx) max(gx) min(gy) max(gy)])
axis image
hold on
if exist('pro', 'var')
    %l = pro < 0;
    %pro2 = pro;
    %pro2(l) = pro2(l)*nan;
    %cs =contour(gx,gy,pro,[95 99.9],'k');
    %cs =contour(gx,gy,pro,[ 99 100],'w--');
    % clabel(cs)
    %l = pro > 0;
    %pro2 = pro;
    %pro2(l) = pro2(l)*nan;
    %cs =contour(gx,gy,pro2,[-95 -99 -99.9],'w');
    %clabel(cs)
end % if exist pro
shading flat
h = hsv(64);
    h = h(57:-1:1,:);
    colormap(jet);
if fre == 1
    caxis([fix1 fix2])
end

title2([name ';  '   num2str(t0b) ' to ' num2str(teb) ],'FontSize',ZmapGlobal.Data.fontsz.m,...
    'Color','r','FontWeight','bold')

xlabel('Distance in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)
ylabel('depth in [km]','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

% plot overlay
%
ploeqc = plot(newa(:,length(newa(1,:))),-newa(:,7),'.w');
set(ploteqc,'Tag','eqc_plot');

if exist('vox', 'var')
    plovo = plot(vox,voy,'*b');
    set(plovo,'MarkerSize',6,'LineWidth',1)
end

if exist('maix', 'var')
    pl = plot(maix,maiy,'*k');
    set(pl,'MarkerSize',12,'LineWidth',2)
end

if exist('maex', 'var')
    pl = plot(maex,-maey,'xk');
    set(pl,'MarkerSize',10,'LineWidth',2)
end
%overlay


set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
h1 = gca;
hzma = gca;

% Create a colobar
%
h5 = colorbar('horiz');
set(h5,'Pos',[0.25 0.05 0.5 0.05],...
    'FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m)

%  Text Object Creation
txt1 = text(...
    'Color',[ 0 0 0 ],...
    'EraseMode','normal',...
    'Units','normalized',...
    'Position',[ -0.20 -0.2 0 ],...
    'Rotation',[ 0 ],...
    'FontSize',ZmapGlobal.Data.fontsz.m,....
    'FontWeight','bold',...
    'String',lab1);

% Make the figure visible
%
set(gca,'visible','on','FontSize',ZmapGlobal.Data.fontsz.m,'FontWeight','bold',...
    'FontWeight','bold','LineWidth',1.5,...
    'Box','on','TickDir','out')
figure_w_normalized_uicontrolunits(bmapc);
%sizmap = signatur('ZMAP','',[0.01 0.04]);
%set(sizmap,'Color','k')
axes(h1)
watchoff(bmapc)
done
