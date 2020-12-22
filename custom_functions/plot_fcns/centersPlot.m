function [centers_plot, figure_filename] = centersPlot(RunDatas,varied_variable_name,varargin,options)

arguments
    RunDatas
    varied_variable_name
end
arguments (Repeating)
    varargin
end
arguments
    %
    options.SmoothWindow = 5
    %
    options.PlottedDensity = "summedODy"
    %
    options.WidthFraction (1,1) double = 0.5
    %
    options.LineWidth (1,1) double = 1.5
    %
    %
    %
    options.yLabel string = ""
    options.yUnits string = ""
    %
    options.xLabel string = varied_variable_name
    options.xUnits string = ""
    %
    options.FontSize (1,1) double = 20
    options.LegendFontSize (1,1) double = 16
    options.TitleFontSize (1,1) double = 20
    %
    options.Interpreter (1,1) string = "latex"
    %
    options.LegendLabels = []
    options.LegendTitle string = "1064 Depth (Er)"
    options.Position (1,4) double = [2561, 27, 1920, 963];
    %
    options.PlotTitle = ""
    %
    options.xLim (1,2) double = [0,0]
    options.yLim (1,2) double = [0,0]
    %
    options.PlotPadding = 0;
    %
end

plottedDensity = options.PlottedDensity;

if varied_variable_name ~= "VVA915_Er"
    options.LegendTitle = "1064-915 Depth (Er)";
    add_915_tag = 1;
else
    add_915_tag = 0;
end

%% Camera Params

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
[~,~,pixelsize,mag] = paramsfnc('ANDOR');
xConvert = pixelsize/mag * 1e6;

%% Avg Atomdata entries for same varied_variable_value

if ~rdclass(RunDatas)
    RunDatas = {RunDatas};
end

for j = 1:length(RunDatas)
    [avg_ads{j}, varied_var_values{j}] = avgRepeats(...
        RunDatas{j}, varied_variable_name, plottedDensity);
    depth1064{j} = unique( arrayfun( @(x) x.vars.VVA1064_Er, RunDatas{j}.Atomdata ));
    depth915{j} = unique( arrayfun( @(x) x.vars.VVA915_Er, RunDatas{j}.Atomdata )); 
end

%% Compute Widths

for j = 1:length(RunDatas)
    
    X{j} = ( 1:size( avg_ads{j}(1).(plottedDensity),2 ) ) * xConvert;
    
    for ii = 1:size(avg_ads{j},2)
       [widths{j}(ii), center{j}(ii)] = fracWidth( X{j}, avg_ads{j}(ii).(plottedDensity), options.WidthFraction, ...
           'PeakRadius',5,'SmoothWindow',5);
    end
    
end

%% Make Figure

centers_plot = figure();

cmap = colormap( jet( length(RunDatas)));

for j = 1:length(RunDatas)
   
    plot( varied_var_values{j}, center{j} , 'o-',...
        'LineWidth', options.LineWidth,...
        'Color',cmap(j,:));
    
    hold on;
    
end

hold off;

%% Setup

labels = [];

for ii = 1:length(depth1064)
    if ii == 1
        labels = [strcat(RunDatas{ii}.RunNumber, ": ", string( depth1064(ii) ))];
        if add_915_tag
            labels(ii) = strcat(labels(ii), "-", string(depth915(ii)));
        end
    else
        labels = [labels; strcat(RunDatas{ii}.RunNumber, ": ", string( depth1064(ii) ))];
        if add_915_tag
            labels(ii) = strcat(labels(ii), "-", string(depth915(ii)));
        end
    end
end

options.LegendLabels = labels;

plot_title = setupPlot( centers_plot, RunDatas, ...
        strcat('Center Position (',options.PlottedDensity,')'), ...
        varied_variable_name, ...
        varargin, ...
        'yLabel', options.yLabel, ...
        'yUnits', options.yUnits, ...
        'xLabel', options.xLabel,...
        'xUnits', options.xUnits,...
        'FontSize', options.FontSize, ...
        'LegendLabels', options.LegendLabels, ...
        'LegendFontSize', options.LegendFontSize,...
        'LegendTitle',options.LegendTitle,...
        'TitleFontSize',options.TitleFontSize,...
        'PlotPadding', options.PlotPadding,...
        'Position', options.Position,...
        'PlotTitle', options.PlotTitle,...
        'yLim',options.yLim,...
        'xLim',options.xLim);

figure_filename = filenameFromPlotTitle(plot_title);

end