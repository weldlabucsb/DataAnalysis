function [expansion_plot, figure_filename] = stackedExpansionPlot(RunDatas,offset_tag,varied_variable_name,legendvars, varargin,options)
% STACKEDEXPANSIONPLOT [one plot per run]. Generate stacked expansion plot
% from avg'd RunDatas.
%
%   offset_tag toggles whether the plots should be offset or overlaid.
%
%   legendvars is a cell array of the variable names (and corresponding values)
%   that should be associated with each trace in the plot.
%
%   varargin can be any number of held variable names.
%  
%   Passes its optional arguments to setupPlot.

arguments
    RunDatas
    offset_tag (1,1) logical
    varied_variable_name string
    legendvars cell
end
arguments (Repeating)
    varargin
end
arguments
    options.PlottedDensity = "summedODy"
    %
    options.yLabel string = "Density"
    options.yUnits string = "(a.u.)"
    %
    options.xLabel string = "Position"
    options.xUnits string = "(um)"
    %
    options.FontSize (1,1) double = 20
    options.LegendFontSize (1,1) double = 16
    options.TitleFontSize (1,1) double = 20
    %
    options.Interpreter (1,1) string = "latex"
    %
    options.LegendLabels = []
    options.LegendTitle string = ""
    options.Position (1,4) double = [53, 183, 1331, 829];
    %
    options.PlotTitle = ""
    %
    options.xLim (1,2) double = [0,0]
    options.yLim (1,2) double
    %
    options.PlotPadding = 15;
    %
end

%% Camera Params

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
    [~,~,pixelsize,mag] = paramsfnc('ANDOR');
    xConvert = pixelsize/mag * 1e6;
    
    %% Avg Atomdata entries for same varied_variable_value
    
    [ad, varied_var_values] = avgRepeats(...
        RunDatas, varied_variable_name, options.PlottedDensity);
    
    for ii = 1:length(ad)
       density(ii,:) = [ad(ii).(options.PlottedDensity)]; 
    end
    
    %% Make the Plot
    
    N = length(varied_var_values);
    offset = zeros(N,1);
    plotMe = [];
    
    expansion_plot = figure();
    
    for ii = 1:N
        if offset_tag
            offset(ii+1) = offset(ii) + max( density(ii,:) ) - min( density(ii,:) ) - 200;
        end
        plotMe(ii,:) = density(ii,:) + offset(ii);
    end
    
    clf;
    hold on
    for ii = 1:N
        x = 1:length(plotMe(ii,:));
        h = plot( xConvert * x, plotMe(ii,:) );
        h.LineWidth = 2;
    end
    
    %%
    
    options.yLim = [ min(min(plotMe)), max(max(plotMe)) ];
    
    dependent_var = options.PlottedDensity;

    %% Setup Plot
    
    [expansion_title, figure_filename] = ...
        setupPlotWrap( ...
            expansion_plot, ...
            options, ...
            RunDatas, ...
            dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
    
end