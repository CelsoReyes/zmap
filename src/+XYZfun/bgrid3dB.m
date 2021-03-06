classdef bgrid3dB < Zmap3DGridFunction
    % This subroutine assigns creates a 3D grid with
    % spacing dx,dy, dz (in degreees). The size will
    % be selected interactiVELY. The pvalue in each
    % volume around a grid point containing ni earthquakes
    % will be calculated as well as the magnitude
    % of completness
    %   Stefan Wiemer 1/98
    % turned into function by Celso G Reyes 2017
    
    properties
        
        R   = 5;
        ni  = ZG.ni;
        Nmin = 50;
        mc_choice   McMethods = McMethods.MaxCurvature % magnitude of completion method 
    end
    
    properties(Constant)
        PlotTag         = 'myplot';
        ReturnDetails   = cell2table({ ... VariableNames, VariableDescriptions, VariableUnits  [bv2 bv rd prf av av2 magco stan stan2];
            'bv2',          'bv2: b-value from bmemmag', '';...     bv2 (?) b-value from calc_bmemag() ->bvg
            'b_value',      'b-value', '';...                       bv ->bvg_wls
            'power_fit',    'Goodness of fit to power-law', '';... prf
            'a_value',      'a-value', '';...                       av
            'av2',          'av2: a-value from bmemmag', '';...     av2 (?) a-value from calc_bmemag() ->avm
            'Mc_value',     'Magnitude of Completion (Mc)', '';...  magco ->mcma
            'b_value_std',  'Std. of b-value', '';...stan
            'stan2',        'stan2: b-value std from calc_bmemag','';... stan2 (?) bvalue std from calc_bmemag()
            ...'Mc_std', 'Std. of Magnitude of Completion', '';...
            ...'a_value_std', 'Std. of a-value', '';...
            ...'Additional_Runs_b_std', 'Additional runs: Std b-value', '';...
            ...'Additional_Runs_Mc_std', 'Additional runs: Std of Mc', '';...
            ... av2 (?) a-value from calc_bmemag() ->avm
            ... bv2 (?) b-value from calc_bmemag() ->bvg
            }, 'VariableNames', {'Names','Descriptions','Units'})
        
        xParameterableProperties = ["mc_choice", "Nmin"];
            
    end
    methods
        function obj=bgrid3dB(zap, varargin)
            
            obj@Zmap3DGridFunction(zap, 'b_value');
            report_this_filefun();
            
            obj.parseParameters(varargin);
                
            obj.StartProcess();
            
            useRadius=false;
            
            
            labelList2={'Automatic Mcomp (max curvature)' ;...
                'Fixed Mc (Mc = Mmin)' ; ...
                'Automatic Mcomp (90% probability)' ;...
                'Automatic Mcomp (95% probability)' ;...
                'Best (?) combination (Mc95 - Mc90 - max curvature)'};
            
            zdlg=ZmapDialog(); %h, okevent
            zdlg.AddHeader('Grid Input Parameters');
            zdlg.AddPopup('mc_choice','Mc Estimation Option:',labelList2,5,'Magnitude of completion option')
            obj.AddDialogOption(zdlg,'EventSelector');
            zdlg.AddGridSpacing('gridopt',.1,'deg',.1,'deg',5,'km')
            zdlg.AddEdit('minz','Shallowest Boundary [km]',min(obj.RawCatalog.Depth),'Shallowest boundary'); %z1
            zdlg.AddEdit('maxz','Deepest Boundary [km]',max(obj.RawCatalog.Depth),'Deepest boundary'); %z2
            zdlg.Create('Name', 'b-value 3D Grid','WriteToObj',obj,'OkFcn',@obj.doIt);
        end
        
        % get the grid-size interactively and
        % calculate the b-value in the grid by sorting
        % the seismicity and selectiong the ni neighbors
        % to each grid point
        
        function results=Calculate(obj)
            zg3=ZmapGrid('bgid3dBGrid',res.gridopt,[res.minz res.maxz]); % create 3d grid
            vol_dimensions=zg3.mesh_size();
            %[t5, gx, gy, gz]=selgp3dB(dx, dy, dz, z1, z2);
            
            %vol_dimensions=[length(gx), length(gy), length(gz)];
            
            
            %  make grid, calculate start- endtime etc.  ...
            %
            [bvg, bvg_wls, ram, go, avm, mcma] = deal(nan(vol_dimensions));
            
            [t0b, teb] = bounds(obj.RawCatalog.Date) ;
            n = obj.RawCatalog.Count;
            tdiff = round((teb-t0b)/ZG.bin_dur);
            loc = zeros(3, length(gx)*length(gy));
            ZG.Rconst = R;
            % loop over  all points
            %
            i2 = 0.;
            i1 = 0.;
            allcount = 0.;
            %
            %
            
            z0 = 0; x0 = 0; y0 = 0; dt = 1;
            % loop over all points
            [bvg,nEvents,maxDists,maxMag, ll]= gridfun(@calculation_function,obj.RawCatalog, zg3, res.evsel);
            %modify answer
            bvg(:,strcmp('x',returnFields))=obj.Grid.X;
            bvg(:,strcmp('y',returnFields))=obj.Grid.Y;
            bvg(:,strcmp('Number_of_Events',returnFields))=nEvents;
            bvg(:,strcmp('Radius_km',returnFields))=maxDists;
            bvg(:,strcmp('max_mag',returnFields))=maxMag;
              
            myvalues = array2table(bvg,'VariableNames', returnFields);
            myvalues.Properties.VariableDescriptions = returnDesc;
            myvalues.Properties.VariableUnits = returnUnits;
            
            kll = ll;
            obj.Result.values=myvalues;
            if nargout
                results=myvalues;
            end
            
            %{
            for il =1:length(zg3)
                
                x = t5(il,1);
                y = t5(il,2);
                z = t5(il,3);
                
                allcount = allcount + 1.;
                
                % calculate distance from center point and sort wrt distance
                l = sqrt(((obj.RawCatalog.X-x)*cosd(y)*111).^2 + ((obj.RawCatalog.Y-y)*111).^2 + ((obj.RawCatalog.Z - z)).^2 ) ;
                [s,is] = sort(l);
                b = a(is(:,1),:) ;       % re-orders matrix to agree row-wise
                
                if useRadius  % take point within r
                    l3 = l <= R;
                    b = obj.RawCatalog.subset(l3);      % new data per grid point (b) is sorted in distanc
                    rd = b.Count;
                else
                    % take first ni points
                    b = b(1:ni,:);      % new data per grid point (b) is sorted in distance
                    l2 = sort(l);
                    rd = l2(ni);
                    
                end
                out=calculation_function(b);
            end
            
            %}
            
            % save data
            %
            gz = -gz;
            zv2 = bvg;
            zvg = bvg;
            
            catsave3('bgrid3dB');
            
            watchoff
            
            sel = 'no';
            
            ButtonName=questdlg('Which viewer would you like to use?', ...
                'Question', ...
                'Slicer - map view','Slicer - 3D ','Help','none');
            
            
            switch ButtonName
                case 'Slicer - map view'
                    slicemap();
                case 'Slicer - 3D '
                    myslicer();
                case 'Help'
                    showweb('3dbgrids')
            end % switch
            
            uicontrol('Units','normal',...
                'Position',[.90 .95 .04 .04],'String','Slicer',...
                'callback',@callbackfun_010);
            
            
            function out=calculation_function(catalog)
                % calculate values at a single point
                
                %estimate the completeness and b-value
                %1: 'Automatic Mcomp (max curvature)'
                %2: 'Fixed Mc (Mc = Mmin)'
                %3: 'Automatic Mcomp (90% probability)'.
                %4: 'Automatic Mcomp (95% probability)'
                %5: 'Best (?) combination (Mc95 - Mc90 - max curvature)'
                
                [bv, bv2, magco, av, av2] = deal(nan);
                %dP=0; %from case 5
                switch obj.mc_choice
                    
                    case 3 % Automatic Mcomp (90% probability)
                        [Mc90, ~, ~, prf]=mcperc_ca3(catalog.Magnitude);
                        l = catalog.Magnitude >= Mc90-0.05;
                        if sum(l) >= Nmin
                            minicat=catalog.subset(l);
                            magco = Mc90;
                            [bv magco0 stan av pr] =  bvalca3(minicat.Magnitude, McAutoEstimate.manual);
                            [bv2 stan2 av2 ] = calc_bmemag(minicat.Magnitude);
                        end
                        
                    case 4 % Automatic Mcomp (95% probability)
                        [~, Mc95, ~, prf]=mcperc_ca3(catalog.Magnitude);
                        l = catalog.Magnitude >= Mc95-0.05;
                        if sum(l) >= Nmin
                            minicat=catalog.subset(l);
                            magco = Mc95;
                            [bv, magco0, stan, av,   pr] =  bvalca3(minicat.Magnitude, McAutoEstimate.manual);
                            [bv2, stan2, av2 ] = calc_bmemag(minicat.Magnitude);
                        end
                        
                    case 5% Best (?) combination (Mc95 - Mc90 - max curvature)
                        [Mc90, Mc95, ~, prf]=mcperc_ca3(catalog.Magnitude);
                        if ~isnan(Mc95)
                            magco = Mc95;
                        elseif ~isnan(Mc90)
                            magco = Mc90;
                        else
                            [~, magco] =  bvalca3(catalog.Magnitude,McAutoEstimate.auto);
                        end
                        l = catalog.Magnitude >= magco-0.05;
                        if sum(l) >= Nmin
                            minicat=catalog.subset(l);
                            [bv, magco0, stan, av, pr] =  bvalca3(minicat.Magnitude, McAutoEstimate.manual);
                            [bv2, stan2,  av2] = calc_bmemag(minicat.Magnitude);
                        else
                            [bv, bv2, magco, av, av2] = deal(nan);
                        end
                        
                    case 1 % Automatic Mcomp (max curvature)
                        [bv magco, stan, av,   pr] =  bvalca3(catalog.Magnitude,McAutoEstimate.auto);
                        l = catalog.Magnitude >= magco-0.05;
                        if  sum(l) >= Nmin
                            [bv2 stan2,  av2] = calc_bmemag(catalog.Magnitude(l));
                        else
                            bv = nan; bv2 = nan, magco = nan; av = nan; av2 = nan;
                        end
                        
                    case 2 % Fixed Mc (Mc = Mmin)
                        [bv, magco, stan, av,   pr] =  bvalca3(catalog.Magnitude, McAutoEstimate.manual);
                        [bv2, stan2, av2 ] = calc_bmemag(catalog.Magnitude);
                        
                    otherwise
                        error('unanticipated choice')
                end

                bvg(t5(il,5),t5(il,6),t5(il,7)) = bv2;
                bvg_wls(t5(il,5),t5(il,6),t5(il,7)) = bv;
                
                ram(t5(il,5),t5(il,6),t5(il,7)) = rd;
                %go(t5(il,5),t5(il,6),t5(il,7)) = prf;
                avm(t5(il,5),t5(il,6),t5(il,7)) = av2;
                mcma(t5(il,5),t5(il,6),t5(il,7)) = magco;
                out=[bv2 bv rd prf av av2 magco stan stan2];
            end
        end
        
        function callbackfun_010(mysrc,myevt)
            callback_tracker(mysrc,myevt,mfilename('fullpath'));
        end
        
    end
    
    methods(Static)
        function h = AddMenuItem(parent, zapFcn, varargin)
            % create a menu item
            label = 'B value grid [3D]';
            h = uimenu(parent, 'Label', label,...
                'MenuSelectedFcn', @(~,~)XYZfun.bgrid3dB(zapFcn()),...
                varargin{:});
        end
    end
end

