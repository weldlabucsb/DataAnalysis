function [oort_zoom_plot, fig_filename] = oortZoomPlot(RunDatas,varied_variable_name,legendvars,varargin,options)
% OORTZOOMPLOT [one plot per run] creates a vertically-zoomed gif and shadow plot of the
% densities in RunDatas versus the varied variable. Repeat-averages all
% RunDatas here.

arguments
    RunDatas
    varied_variable_name
    legendvars
end
arguments (Repeating)
    varargin
end
arguments
    options.SmoothWindow = 7; % movmean smoothing window
    %
    options.PlottedDensity = "summedODy"
    %
    options.GIFFrameTime (1,1) double = 0.1 % frame time in seconds
    %
    options.ShadowOffset (1,1) double = 4 % offsets the lightest trace from white
    options.PlotEvery (1,1) double = 4 % cleaner to only plot every 3 or so densities
    %
    options.LineWidth (1,1) double = 1
    %
    options.yLabel string = "Density (Zoomed)"
    options.yUnits string = ""
    %
    options.xLabel string = "Position ($\mu$m)"
    options.xUnits string = ""
    %
    options.FontSize (1,1) double = 20
    options.LegendFontSize (1,1) double = 16
    options.TitleFontSize (1,1) double = 20
    %
    options.Interpreter (1,1) string = "latex"
    %
    options.LegendLabels = [] % don't specify this if you want auto-labels
    options.LegendTitle string = "" % don't specify if you want auto-title
    options.Position (1,4) double = [2561, 27, 1920, 963];
    %
    options.PlotTitle = "" % don't specify this if you want the auto-title
    %
    options.xLim (1,2) double = [0,0]
    options.yLim (1,2) double = [0,0]
    %
    options.PlotPadding = 0;
end

%% Camera Params

% requires paramsfnc (found in StrontiumData/ImageAnalysisSoftware/v6/)
    [~,~,pixelsize,mag] = paramsfnc('ANDOR');
    xConvert = pixelsize/mag * 1e6;
    
%%

    plotted_dens = options.PlottedDensity;

    [avg_atomdata, ~] = avgRepeats(...
        RunDatas, varied_variable_name, plotted_dens);
    
    X = ( 1:length(avg_atomdata(1).(plotted_dens)) ) * xConvert;
    
%%
    
    oort_zoom_plot = figure();
    N_shadow_traces = round(length(avg_atomdata) / options.PlotEvery);
    offset = options.ShadowOffset;
    cmap = flip(bone( N_shadow_traces + offset ));
    
    figure_title_dependent_var = 'Density (Zoomed)';
    
    %% Make the Shadow Plot
    
    idx_to_plot = 1:options.PlotEvery:length(avg_atomdata);
    for ii = 1:length(idx_to_plot)
        toplot = movmean(...
            avg_atomdata(idx_to_plot(ii)).(plotted_dens),...
            options.SmoothWindow);
        plot(X, toplot,...
            'Color', cmap( ii + offset - 1 ,:),...
            'LineWidth',options.LineWidth);
        hold on;
    end
    
    %% Get the bounds from fracheight
    
    [~,~,~,~,theheight] = fracWidth(X,avg_atomdata(1).(plotted_dens),0.125);
    theminheight = min( min( avg_atomdata(1).(plotted_dens) ), -50);
    options.yLim = [theminheight theheight];
    
    %%
    
    [oort_zoom_title, fig_filename] = ...
        setupPlotWrap( ...
            oort_zoom_plot, ...
            options, ...
            RunDatas, ...
            figure_title_dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);

end