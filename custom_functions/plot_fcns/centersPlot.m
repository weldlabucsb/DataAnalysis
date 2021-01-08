function [centers_plot, figure_filename] = centersPlot(RunDatas,varied_variable_name,legendvars,varargin,options)
% CENTERSPLOT [multi-run plot] plots the position of the center of the
% cloud (can specify summedODy or summedODx) versus the varied variable.

arguments
    RunDatas
    varied_variable_name string
    legendvars cell
end
arguments (Repeating)
    varargin
end
arguments
    %
    options.GaussFitCenter (1,1) logical = 0 % switches from fracwidth width finding to using gaussian fit center
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
    options.yLabel string = "Center Position ($\mu$m)"
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
    options.PlotPadding = 0
end

plottedDensity = options.PlottedDensity;

%% Camera Params

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
[~,~,pixelsize,mag] = paramsfnc('ANDOR');
xConvert = pixelsize/mag * 1e6;

%% Avg Atomdata entries for same varied_variable_value

if ~rdclass(RunDatas)
    RunDatas = {RunDatas};
end

if plottedDensity == "summedODy"
    cloudCenterVar = 'cloudCenter_y';
elseif plottedDensity == "summedODx"
    cloudCenterVar = 'cloudCenter_x';
end

avgd_vars = {plottedDensity,cloudCenterVar};
for j = 1:length(RunDatas)
    [avg_ads{j}, varied_var_values{j}] = avgRepeats(...
        RunDatas{j}, varied_variable_name, avgd_vars); 
end

%% Compute Widths

for j = 1:length(RunDatas)
    
    X{j} = ( 1:size( avg_ads{j}(1).(plottedDensity),2 ) ) * xConvert;
    
    if ~options.GaussFitCenter
        center_type = 'FracWidth';
        for ii = 1:size(avg_ads{j},2)
           [widths{j}(ii), center{j}(ii)] = fracWidth( X{j}, avg_ads{j}(ii).(plottedDensity), options.WidthFraction, ...
               'PeakRadius',5,'SmoothWindow',5);
        end
    else
        center_type = 'Gauss Fit';
        for ii = 1:size(avg_ads{j},2)
            center{j}(ii) = avg_ads{j}(ii).(cloudCenterVar) * 1e6;
        end
    end
    
end

%% Make Figure

centers_plot = figure();
dependent_var = strcat('Center Position (',options.PlottedDensity,') [',center_type,']');

cmap = colormap( jet( length(RunDatas)));

for j = 1:length(RunDatas)
   
    plot( varied_var_values{j}, center{j} , 'o-',...
        'LineWidth', options.LineWidth,...
        'Color',cmap(j,:));
    
    hold on;
    
end

hold off;

%% Setup
    
[plot_title, figure_filename] = ...
    setupPlotWrap( ...
        centers_plot, ...
        options, ...
        RunDatas, ...
        dependent_var, ...
        varied_variable_name, ...
        legendvars, ...
        varargin);

end