function [width_evo_plot,figure_filename] = widthEvolutionPlot(RunDatas,varied_variable_name,varargin,options)
% WIDTHEVOLUTIONPLOT makes a plot of how the width of the evolution evolves
% with respect to {varied_variable_name}. Inherits optional arguments from
% setupPlot.

arguments
    RunDatas
    varied_variable_name
end
arguments (Repeating)
    varargin
end
arguments
    options.IncludeSDPlot (1,1) logical = 0
    %
    options.WidthFraction (1,1) double = 0.5
    %
    options.LineWidth (1,1) double = 1.5
    %
    %
    %
    options.yLabel string
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

options.yLabel = strcat("Width at ", num2str(options.WidthFraction), " of Max Density");

%% Camera Params

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
[~,~,pixelsize,mag] = paramsfnc('ANDOR');
xConvert = pixelsize/mag * 1e6;

%% Avg Atomdata entries for same varied_variable_value

if ~rdclass(RunDatas)
    RunDatas = {RunDatas};
end

for j = 1:length(RunDatas)
    [density{j}, varied_var_values{j}, ywidths{j}] = avg_repeats(RunDatas{j}, varied_variable_name);
    depth1064{j} = unique( arrayfun( @(x) x.vars.VVA1064_Er, RunDatas{j}.Atomdata ));
end

%%

%% Compute Widths

for j = 1:length(RunDatas)
    
    X{j} = 1:size( density{j},2 ) * xConvert;
    
    for ii = 1:size(density{j},1)
       widths{j}(ii) = frac_width( X{j}, density{j}(ii,:), options.WidthFraction);
    end
    
end

%% Make Figure

width_evo_plot = figure();

cmap = colormap(lines( length(RunDatas) ));

for j = 1:length(RunDatas)
   
    plot( varied_var_values{j}, widths{j} , 'o-',...
        'LineWidth', options.LineWidth,...
        'Color',cmap(j,:));
    
    hold on;
    
    if options.IncludeSDPlot
        plot( varied_var_values{j}, ywidths{j}*1e6 , '--',...
        'LineWidth', options.LineWidth,...
        'Color',cmap(j,:));
    end
    
end

hold off;

%% Setup

labels = [];
for ii = 1:length(depth1064)
    if ii == 1
        labels = [strcat("Frac: ", string( depth1064(ii) ))];
    else
        labels = [labels; strcat("Frac: ", string( depth1064(ii) ))];
    end
    
    if options.IncludeSDPlot
        labels = [labels; strcat("SD: ", string( depth1064(ii) ))];
    end
end
options.LegendLabels = labels;

figname = setupPlot( width_evo_plot, RunDatas, ...
        'FracWidth', varied_variable_name, ...
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

for j = 1:length(figname)
   if j == 1
       figure_filename = figname{j};
   else
       figure_filename = strcat( figure_filename, ", ", figname{j});
   end
   figure_filename = strcat(figure_filename,".png");
end

end