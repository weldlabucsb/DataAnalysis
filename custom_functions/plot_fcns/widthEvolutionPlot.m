function [width_evo_plot,figure_filename] = widthEvolutionPlot(RunDatas,varied_variable_name,legendvars,varargin,options)
% WIDTHEVOLUTIONPLOT makes a plot of how the width of the evolution evolves
% with respect to {varied_variable_name}. Inherits optional arguments from
% setupPlot.
%
% legendvars must be specified as a cell array of strings. The names of
% the variables are used as the title of the legend, and their values for
% each plotted RunData are 

arguments
    RunDatas
    varied_variable_name
    legendvars
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
    options.IncludeSDPlot (1,1) logical = 0
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
    options.PiezoFreqTag = 1;
end

options.yLabel = strcat("Width at ", num2str(options.WidthFraction), " of Max Density");
%%

plottedDensity = options.PlottedDensity;

if plottedDensity == "summedODy"
    SD = 'cloudSD_y';
elseif plottedDensity == "summedODx"
    SD = 'cloudSD_x';
end

if varied_variable_name ~= "VVA915_Er"
    options.LegendTitle = "1064-915 Depth (Er)";
    add_915_tag = 1;
else
    add_915_tag = 0;
end

add_piezo_freq_tag = options.PiezoFreqTag;
% if any(contains(string(varargin),"PiezoModFreq"))
%     options.LegendTitle = "1064-915, Piezo";
%     add_piezo_freq_tag = 1;
% else
%     add_piezo_freq_tag = 0;
% end

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
        RunDatas{j}, varied_variable_name, plottedDensity, SD);
    
    for k = 1:length(legendvars)
        legendvars{k}{j} = unique( arrayfun( @(x) x.vars.VVA1064_Er, RunDatas{j}.Atomdata ));
    
        depth1064{j} = unique( arrayfun( @(x) x.vars.VVA1064_Er, RunDatas{j}.Atomdata ));
        depth915{j} = unique( arrayfun( @(x) x.vars.VVA915_Er, RunDatas{j}.Atomdata )); 
        piezomodfreq{j} = unique( arrayfun( @(x) x.vars.PiezoModFreq, RunDatas{j}.Atomdata )); 
end

%% Compute Widths

for j = 1:length(RunDatas)
    
    X{j} = ( 1:size( avg_ads{j}(1).(plottedDensity),2 ) ) * xConvert;
    
    for ii = 1:size(avg_ads{j},2)
       widths{j}(ii) = fracWidth( X{j}, avg_ads{j}(ii).(plottedDensity), options.WidthFraction, ...
           'PeakRadius',5,'SmoothWindow',5);
    end
    
end

%% Make Figure

width_evo_plot = figure();

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

labels = [];

for ii = 1:length(depth1064)
    if ii == 1
        labels = [strcat(RunDatas{ii}.RunNumber, ": ", string( depth1064(ii) ))];
        if add_915_tag
            labels(ii) = strcat(labels(ii), "-", string(depth915(ii)));
        end
        if add_piezo_freq_tag
            labels(ii) = strcat(labels(ii), ", ", string(piezomodfreq(ii)));
        end
    else
        labels = [labels; strcat(RunDatas{ii}.RunNumber, ": ", string( depth1064(ii) ))];
        if add_915_tag
            labels(ii) = strcat(labels(ii), "-", string(depth915(ii)));
        end
        if add_piezo_freq_tag
            labels(ii) = strcat(labels(ii), ", ", string(piezomodfreq(ii)));
        end
    end
    
    if options.IncludeSDPlot
        labels = [labels; strcat("SD: ", string( depth1064(ii) ))];
        if add_915_tag
            labels(ii) = strcat(labels(ii), "-", string(depth915(ii)));
        end
        if add_piezo_freq_tag
            labels(ii) = strcat(labels(ii), ", ", string(piezomodfreq(ii)));
        end
    end
end

options.LegendLabels = labels;

plot_title = setupPlot( width_evo_plot, RunDatas, ...
        strcat('FracWidth (',options.PlottedDensity,')'), ...
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

% for ii = 1:length(depth1064)
%     if ii == 1
%         labels = [strcat("Frac: ", string( depth1064(ii) ))];
%         if add_915_tag
%             labels(ii) = strcat(labels(ii), "-", string(depth915(ii)));
%         end
%     else
%         labels = [labels; strcat("Frac: ", string( depth1064(ii) ))];
%         if add_915_tag
%             labels(ii) = strcat(labels(ii), "-", string(depth915(ii)));
%         end
%     end
%     
%     if options.IncludeSDPlot
%         labels = [labels; strcat("SD: ", string( depth1064(ii) ))];
%         if add_915_tag
%             labels(ii) = strcat(labels(ii), "-", string(depth915(ii)));
%         end
%     end
% end