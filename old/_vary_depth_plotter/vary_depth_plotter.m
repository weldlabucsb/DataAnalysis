%% Initialize data:

test = 1;
holdTimeSelect = 0; % in seconds

if ~exist('allData','var')
    load('allData.mat')
end

%% Select Data
% Note that latticeDepthRanges can't be specified exactly, due to some
% weird decimal problems with how the RunDatas store the lattice depth
% values. Just give it windows (non-overlapping) around the lattice values
% you know are in each run.

if test
   theseRuns = RunDataLibrary('Test');
   condition = {'RunID','03_17','RunNumber',{'16','17','18'}};
   
   if holdTimeSelect ~= 0
       condition{end+1} = 'LatticeHold';
       condition{end+1} = num2str( holdTimeSelect * 1000 );
   end
   
   theseRuns = theseRuns.libraryConstruct(allData, condition);
   Data = theseRuns;
%    latticeDepths = ...
%    {'0.0080','0.0160','0.0400','0.0800',...
%        '0.1600','0.4000','0.8000','1.2000','1.6000'};
end

%% Boolean Plot Options

fig_folder = ...
    'G:\My Drive\_WeldLab\Code\Analysis\quasicrystal_transport\new_figs\new';

lattice_ramp_in_title = 0; % adds or removes from second line of title. Makes titles super long.

fontsize = 30; % Legends for expansion plots are by default at fontsize/2
titleFontSize = 24;
dotSize = 8; % marker sizes
 
%% Averaging  

latticeDepths = Data.RunProperties.vars.VVA915_Er;
numDepths = size(latticeDepths,1);

averagedQuantities = {'summedODy','summedODx','cloudSD_y','cloudSD_x'};

for depthIndex = 1:numDepths
    
    setsWithThisDepth = Data.libraryConstruct( Data, ...
        {'VVA915_Er', num2str( latticeDepths(depthIndex) ) } );
    
    holdTimes = setsWithThisDepth.RunProperties.vars.LatticeHold;
    numHoldTimes = size(holdTimes,1);
    
    for holdIndex = 1:numHoldTimes
        
        thisSet = setsWithThisDepth.libraryConstruct(...
            setsWithThisDepth, ...
            {'LatticeHold', num2str( holdTimes(holdIndex) ) } );
        
        ad{holdIndex,depthIndex} = struct(...
            "Atomdata", cell(1),...
            "RunProperties", thisSet.RunProperties);
        
        for k = 1:size(thisSet.RunDatas,1)
            ad{holdIndex,depthIndex}.Atomdata = ...
                [ad{holdIndex,depthIndex}.Atomdata; thisSet.RunDatas{k}.Atomdata];
        end
    end
end

for holdIndex = 1:size(ad, 1)
    for depthIndex = 1:size(ad, 2)
        % averaging
        
        for q = 1:length(averagedQuantities)
        
            try
            quantity = cell2mat(arrayfun(@(x)...
                x.(averagedQuantities{q}),...
                ad{holdIndex,depthIndex}.Atomdata,...
                'UniformOutput', false'));
            end

            avgQuantity = mean(quantity,1);
            
            ad{holdIndex,depthIndex}.(averagedQuantities{q}) = ...
                avgQuantity;
        
        end
    end
end

%% Density Plot

offsets = zeros(size(ad,2),1);
colors = cmap(  );

for depthIndex = 1:size(ad,2)
    
    thisDensity = ad{holdIndex, depthIndex}.summedODy;
    
    offsets( depthIndex + 1 ) = ...
        offsets(depthIndex) ...
        + max(thisDensity) - min(thisDensity) ...
        - shift;
    
    axis tight
    
    for holdIndex = 1:size(ad,1)
    
        plot( ad{holdIndex, depthIndex}.summedODy + offsets(depthIndex) )
        
        hold on
    
    end
    
    holdIndex = 1;
    
end

%% functions

function save_figure(fig_folder,Title1,Title2,save_figures)
    set(gcf,'Position',[6         151        1365        1199]);
    filename = strcat(fig_folder, Title1,", ", Title2,".png");
    if save_figures
        saveas(gcf,filename);
    end
end

function [fitresult, gof, excludedPoints] = expfit(x, y, endIndicesExcluded, startIndicesExcluded)
% EXPFIT fits data to a*x^b + c.

% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
lastIndex = length(yData);
ft = fittype( 'a*x^b + c', 'independent', 'x', 'dependent', 'y' );

excludedPoints = excludedata( xData, yData, 'range', [0,Inf]);

if startIndicesExcluded == 0
    exclStartIndices = [];
else
    exclStartIndices = 1:(startIndicesExcluded);
end

excludedPoints = excludedPoints | excludedata( xData, yData, 'indices', exclStartIndices);

exclEndInidices = (lastIndex - endIndicesExcluded + 1):lastIndex;
excludedPoints = excludedPoints | excludedata( xData, yData, 'indices', exclEndInidices);

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Upper = [Inf 10 Inf];
opts.StartPoint = [0.360739563468973 0.506056149075752 0.703688323247359];
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
end