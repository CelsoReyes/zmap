function inmisfit(catalog) 
    % make dialog interface for misfit calculation
    %
    % S. Wiemer/Zhong Lu/Alex Allmann
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    global mi2
    %
    report_this_filefun();
    
    %if isunix ~= 1
    %  errordlg('Misfit laculation only implemented for UNIX version, sorry');
    %  return
    %end
    
    ZG.newcat = copy(catalog);
    
    %{
    if size(a(1,:)) < 12
        errordlg('You need 12 columns of Input Data to calculate misfit!');
        return
    end
    %}
    
    sig = 1;
    az = 180.;
    plu = 35.;
    R = 0.5;
    phi = 16;
    

    bev=find(catalog.Magnitude==max(catalog.Magnitude)); %biggest events in catalog
    
    
    %default values of input parameters
    %ldx=100; %for seislap
    %tlap=100; %for seislap
    latt=catalog.Latitude(bev(1));
    longt=catalog.Longitude(bev(1));
    binlength=1;
    Mmin=3;
    ldepth=catalog.Depth(bev(1));
    
    % creates a dialog box to input some parameters
    
    zdlg = ZmapDialog();
    sigChoices = {'1','3'};
    sigDefault = strcmp(string(sig),sigChoices);
    zdlg.AddPopup('sig','Choose Sigma',sigChoices,find(sigDefault),'Choose Sigma');
    zdlg.AddEdit('plu','Plunge',plu,'Choose plunge');
    zdlg.AddEdit('az','Azimuth',az,'Choose Azimuth');
    zdlg.AddEdit('r','R value',R,'R-value');
    zdlg.AddEdit('phi','Phi',phi,'Phi');
    if ~isempty(mi2)
    zdlg.AddCheckbox('doComparative','Compare misfits of different stress models',false,[],...
        'add this model to list of existing models, and then plot them all');
    end
    [res,okPressed]=zdlg.Create('Name', 'Misfit Calculation Parameters');
    if ~okPressed,return,end
    
    res.sig = str2double(sigChoices{res.sig});
    sig=res.sig;
    plu=res.plu;
    az=res.az;
    R=res.r;
    phi=res.phi;
    
    if ~isempty(mi2) && res.doComparative
        compMisfit(mi2, res);
    end
    
    domisfit(catalog, sig,plu,az,phi,R);
    
end


function compMisfit(mi2, stressParams) 
    %  COMPMISFIT Compare Misfits of Different Stress Models
    % adds the stress parameters to a growing list of misfits
    % August 95 by Zhong Lu and Alex Allmann
    % turned into function by Celso G Reyes 2017
    
    ZG=ZmapGlobal.Data; % used by get_zmap_globals
    
    report_this_filefun();
    
    persistent xNumber yMisfit cumuMisfit loopNumber obsNum StressPara
    mif99=findobj('Type','Figure','-and','Name','Compare Misfits of Different Stress Models');
    
    
    
    if isempty(mif99)
        mif99 = figure_w_normalized_uicontrolunits( ...
            'Name','Compare Misfits of Different Stress Models',...
            'NumberTitle','off', ...
            'backingstore','on',...
            'NextPlot','add', ...
            'Visible','off', ...
            'Position',position_in_current_monitor(ZG.map_len(1), ZG.map_len(2)));
        
        
        set(gca,'NextPlot','add')
        
        %initiate variables
        loopNumber = 0;
        xNumber = [];
        yMisfit = [];
        cumuMisfit = [];
        stressPara =[];
        xNumber = [1:length(mi2(:,1))]';
        obsNum = length(mi2);
    else
        delete(findobj(mif99,'Type','axes'));
    end
    
    figure(mif99)
    
    set(gca,'NextPlot','add')
    
    loopNumber = loopNumber + 1;
    yMisfit(:,loopNumber) = mi2(:,2);
    cumuMisfit(:,loopNumber) = cumsum(yMisfit(:,loopNumber));
    
    % save the parameters of the stress model
    stressPara(loopNumber,:) = [stressParams.sig,...
        stressParams.plu,...
        stressParams.az,...
        stressParams.R,...
        stressParams.phi];
    
    increment = 100;  % offset between curves.
    
    lineattributes = {'ro','yo','mo','c.','b.','r.','y*','m*','c+','b+'};
    markersizes = [4 7 10 7 12 17 5 8 5 8];
    ax=gca;
    
    [lastRow,colI] = sort(cumuMisfit(obsNum,:));
    for i = 1 : loopNumber
        plot(ax,xNumber, cumuMisfit(:,colI(i)) + increment * (i-1) , lineattributes{i}, ...
            'MarkerSize', markersizes(i) );
        set(gca,'NextPlot','add')
    end
    
    stress = stressPara.subset(colI);
    grid(ax,'on');
    
    xlabel('Number of Earthquake','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    ylabel('Cumulative Misfit ','FontWeight','bold','FontSize',ZmapGlobal.Data.fontsz.m);
    set(gca,'NextPlot','replace');
end
