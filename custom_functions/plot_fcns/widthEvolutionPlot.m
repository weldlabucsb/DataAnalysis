function [width_evo_plot, figure_filename] = widthEvolutionPlot(RunDatas,varied_variable_name,legendvars,varargin,options)
% WIDTHEVOLUTIONPLOT [multi-run plot] makes a plot of how the width of the
% evolution of runs evolve with respect to {varied_variable_name}. Plots
% evolution of multiple runs on same axes.
%
% legendvars must be specified as a cell array of strings. The names of
% the variables are used as the title of the legend, and their values for
% each plotted RunData are added to the legend.

arguments
    RunDatas
    varied_variable_name
    legendvars
end
arguments (Repeating)
    varargin
end
arguments
    options.SmoothWindow (1,1) double = 5
    options.PeakRadius (1,1) double = 5
    %
    options.PlottedDensity = "summedODy"
    %
    options.IncludeSDPlot (1,1) logical = 0
    %
    options.WidthFraction (1,1) double = 0.5
    %
    options.LineWidth (1,1) double = 1.5
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
    options.LegendTitle string = ""
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

options.yLabel = strcat("Width at ", num2str(options.WidthFraction), " of Max Density");
%%

plottedDensity = options.PlottedDensity;

if plottedDensity == "summedODy"
    SD = 'cloudSD_y';
elseif plottedDensity == "summedODx"
    SD = 'cloudSD_x';
end

%% Camera Params

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
[~,~,pixelsize,mag] = paramsfnc('ANDOR');
xConvert = pixelsize/mag * 1e6; % converts the x-axis to um.

%% Avg Atomdata entries for same varied_variable_value

if ~rdclass(RunDatas)
    RunDatas = {RunDatas};
end

for j = 1:length(RunDatas)
    [avg_ads{j}, varied_var_values{j}] = avgRepeats(...
        RunDatas{j}, varied_variable_name, {plottedDensity, SD});
end

%% Compute Widths

for j = 1:length(RunDatas)
    
    X{j} = ( 1:size( avg_ads{j}(1).(plottedDensity),2 ) ) * xConvert;
    
    for ii = 1:size(avg_ads{j},2)
       widths{j}(ii) = fracWidth( X{j}, avg_ads{j}(ii).(plottedDensity), options.WidthFraction, ...
           'PeakRadius',options.PeakRadius,'SmoothWindow',options.SmoothWindow);
    end
     
end

%% Make Figure

width_evo_plot = figure();

dependent_var = strcat('FracWidth (',options.PlottedDensity,')');

cmap = colormap( jet( length(RunDatas)));

for j = 1:length(RunDatas)
   
    plot( varied_var_values{j}, widths{j} , 'o-',...
        'LineWidth', options.LineWidth,...
        'Color',cmap(j,:));
    
    hold on;
    
    if options.IncludeSDPlot
        plot( varied_var_values{j}, [avg_ads{j}.(SD)]*1e6 , '--',...
        'LineWidth', options.LineWidth,...
        'Color',cmap(j,:));
    end
    
end

hold off;

%% Setup
    
[plot_title, figure_filename] = setupPlotWrap( ...
    width_evo_plot, ...
    options, ...
    RunDatas, ...
    dependent_var, ...
    varied_variable_name, ...
    legendvars, ...
    varargin);

end