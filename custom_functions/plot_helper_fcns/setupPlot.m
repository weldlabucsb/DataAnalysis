function [plot_title, figure_filename] = setupPlot(figure_handle, RunDatas, plotted_dependent_var, varied_variable_name, legendvars, varargin, options)
% SETUPPLOT sets axes labels, title, legend, etc. Also outputs the plot
% title and a figure filename (containing the same information as the plot
% title), for use in saving figures.
%
% SETUPPLOT will use default values from RunData if optional arguments are
% not given.
%
% legendvars must be specified as a cell array of strings. The names of
% the variables are used as the title of the legend, and their values for
% each plotted RunData are added to the legend.
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
    legendvars cell
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
    options.LegendTitle string = ""
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

try
    if ~isempty(varargin)
        pass_vargs = varargin{1}{1};
    else
        pass_vargs = {};
    end
catch
    pass_vargs = {};
end

%% Title

if options.PlotTitle == ""
    plot_title = plotTitle(RunDatas,plotted_dependent_var,varied_variable_name,pass_vargs);
else
    plot_title = options.PlotTitle;
end

figure_filename = filenameFromPlotTitle(plot_title);

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

% If LegendTitle not specified manually, generate from list of legend
% variables
if options.LegendTitle == ""
    titleLegendVars = varAlias(legendvars);
    options.LegendTitle = strrep(strjoin(titleLegendVars,", "),'_','');
end

% If LegendLabels were not specified manually, generate them from the list
% of legend variables.
if isempty(options.LegendLabels)
    
    % compute the values of each legend variable and add to legend
    for j = 1:length(RunDatas)
        for k = 1:length(legendvars)
            if legendvars{k} ~= "PiezoModFreq" && isfield(RunDatas{j}.vars,legendvars{k})
            % look at rundata to pull value of legend variables
                legendvals{j}{k} = RunDatas{j}.vars.(legendvars{k});
            elseif ~isfield(RunDatas{j}.vars,legendvars{k}) || legendvars{k} == "PiezoModFreq"
            % if legendvar not part of rundata, look at atomdata
                legendvals{j}{k} = unique( arrayfun( @(x) x.vars.(legendvars{k}), RunDatas{j}.Atomdata ));
            else
            % error if the legendvar is not a field of RunData or atomdata
                legendvals{j}{k} = "Err";
                disp(strcat("The legend variable '",legendvars{k},...
                    "' does not exist in RunData or Atomdata. Did you misspell it?"));
            end
        end
    end

    % stick the values together into proper legend labels.
    for j = 1:length(RunDatas)
        labels(j) = strcat(RunDatas{j}.RunNumber, ": ");

        thisvarval = num2str(legendvals{j}{1});
        labels(j) = strcat(labels(j), thisvarval, ", " );
        for k = 2:(length(legendvars)-1)
            thisvarval = num2str( legendvals{j}{k} );
            labels(j) = strcat(labels(j), thisvarval, ", " );
        end
        labels(j) = strcat(labels(j), num2str( legendvals{j}{end} ));
    end
    
    options.LegendLabels = labels;
    
end

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