% This plot a DEM map plus eq on top...
% Benoetigt gtopo302 Modifikation von gtopo30

import zmaptopo.TopoToFlag

report_this_filefun(mfilename('fullpath'));


gtopo30s([46 47],[6 7])
s4_south=20;
s3_north=50;
s2_west=30;
s1_east=50;


cegt=gtopo30s([s4_south s3_north],[s2_west s1_east]);
disp('GTOPO30 files')
disp(cegt)


%     try
%         l  = get(h1,'XLim');
%     catch
%         update(mainmap())
%         pltopo
%     end

% VON ZMAP WIEDER BENOETIGT

%     s1_east = l(2); s2_west = l(1);
%     l  = get(h1,'YLim');
%     s3_north = l(2); s4_south = l(1);
%     fac = 1;

if abs(s4_south-s3_north) > 10 | abs(s1_east-s2_west) > 10 
    def = {'3'};
    ni2 = inputdlg('Decimation factor for DEM data?','Input',1,def);
    l = ni2{:};
    fac = str2double(l);
end


%     do = ['cd  ' hodi]; ; eval(do);
%     do = ['cd ' hodi fs 'dem' fs 'gtopo30']; eval(do);



%     if exist('gtopo30s2') == 2
%         fname = gtopo30s([s4_south s3_north],[ s2_west s1_east])
%         do = [' [tmap, tmapleg] = gtopo30(fname,fac,[s4_south s3_north],[ s2_west s1_east]); '];
%     else
%         do = [' [tmap, tmapleg] = gtopo30(''test'',fac,[s4_south s3_north],[ s2_west s1_east]); '];
%     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% fname=gtopo30s([s4_south s3_north],[ s2_west s1_east])
% fname=upper(fname{1})
% [tmap, tmapleg] = gtopo30(fname,fac,[s4_south s3_north],[ s2_west s1_east]);
[tmap, tmapleg] = gtopo302('c:\ZMAP6\dem\gtopo30',fac,[s4_south s3_north],[s2_west s1_east]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


my = s4_south:1/tmapleg(1):s3_north+0.1;
mx = s2_west:1/tmapleg(1):s1_east+0.1;
vlon = mx;
vlat = my;
[m,n] = size(tmap);
toflag = TopoToFlag.five;

% entspricht pltopo mitplt='plo'

[existFlag,figNumber]=figure_exists('Topographic Map',1);

if existFlag == 0;  ac3 = 'new'; overtopo;   end
if existFlag == 1
    figure_w_normalized_uicontrolunits(to1)
    delete(gca); delete(gca);delete(gca)
end

hold on; axis off

axes('position',[0.13,  0.13, 0.65, 0.7]);
pcolor(mx(1:n),my(1:m),tmap); shading flat
demcmap(tmap);
hold on
h1topo = gca;
set(gca,'color',[ 0.341 0.776 1.000 ]')
%whitebg(gcf,[0 0 0]);

set(gca,'FontSize',12,'FontWeight','bold','TickDir','out','Ticklength',[0.02 0.02])
set(gcf,'Color','w','InvertHardcopy','off')
set(gcf,'renderer','zbuffer')
