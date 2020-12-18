function plot_title = setupPlot(figure_handle, RunDatas, plotted_dependent_var, varied_variable_name, varargin, options)
% SETUPPLOT sets axes labels, title, legend, etc. Also outputs the plot
% title in case it is useful for figure saving, etc.
%
% SETUPPLOT will use default values from RunData if optional arguments are
% not given.
%
% varargin can be used for any number of variables held constant that you
% want included in a pre-generated title. Does nothing if PlotTitle option
% is specified.
%
% SETUPPLOT optional arguments:
% yLabel, yUnits, xLabel, xUnits ( strings )
% FontSize, LegendFontSize, TitleFontSize ( doubles )
% Interpreter (ex: 'latex', 'none')
% LegendLabels (list of values)
% LegendTitle (string to title the legend)
% Position ( (1,4) double )
% PlotTitle (default: plotTitle(...))
% PlotPadding ( adds [-1,1]*PlotPadding to x,ylims IFF xlims, ylims
% specified )

arguments
    figure_handle matlab.ui.Figure
    RunDatas
    plotted_dependent_var string
    varied_variable_name string
end
arguments (Repeating)
    varargin
end
arguments
    options.yLabel string = plotted_dependent_var
    options.yUnits string = ""
    %
    options.xLabel string = ""
    options.xUnits string = ""
    %
    options.FontSize (1,1) double = 20
    options.LegendFontSize (1,1) double = 16
    options.TitleFontSize (1,1) double = 20
    %
    options.Interpreter (1,1) string = "latex"
    %
    options.LegendLabels = []
    options.LegendTitle string = varied_variable_name
    options.Position (1,4) double = [0, 0, 1280, 720];
    %
    options.PlotTitle = ""
    %
    options.xLim (1,2) double = [0,0]
    options.yLim (1,2) double = [0,0]
    %
    options.PlotPadding = 0;
    %
end

%% VargHandling

if ~isempty(varargin)
    pass_vargs = varargin{1};
else
    pass_vargs = {};
end

%% Title

if options.PlotTitle == ""
    plot_title = plotTitle(RunDatas,plotted_dependent_var,varied_variable_name,pass_vargs);
else
    plot_title = options.PlotTitle;
end

%% Parsing

% set y label (add units if specified)
if options.yUnits == ""
    yLabel = options.yLabel;
else
    yLabel = strcat( options.yLabel, " ", options.yUnits );
end

% set x label (add units if specified)
if options.xUnits == ""
    xLabel = options.xLabel;
else
    xLabel = strcat( options.xLabel, " ", options.xUnits );
end

%% Plot Legend

if class(options.LegendLabels) == "string" || class(options.LegendLabels) == "char"
    % Legend Labeling
    lgd = legend( options.LegendLabels , ...
        'FontSize',options.LegendFontSize,...
        'Interpreter',options.Interpreter);
    LegendTitle = strrep(options.LegendTitle,'_','');
    title(lgd,LegendTitle,'FontSize',options.LegendFontSize);
end

%% Plot Labeling

% Title, Axes Labeling
title(plot_title,'FontSize',options.TitleFontSize,'Interpreter',options.Interpreter);
ylabel(fix(options.yLabel),'FontSize',options.FontSize,'Interpreter',options.Interpreter);
xlabel(fix(options.xLabel),'FontSize',options.FontSize,'Interpreter',options.Interpreter);

% Axes Handling
if any(options.xLim ~= [0 0])
    options.xLim = options.xLim + [-1,1]*options.PlotPadding;
    xlim([options.xLim]);
end

if any(options.yLim ~= [0 0])
    options.yLim = options.yLim + [-1,1]*options.PlotPadding;
    ylim([options.yLim]);
end

% Resizing
set(figure_handle,'Position',options.Position);

    function out = fix(in)
        out = strrep(in,'_','');
    end

end