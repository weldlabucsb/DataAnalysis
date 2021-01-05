function [fig_handle, fig_filename] = plotFunctionTemplate(RunDatas,varied_variable_name,legendvars,varargin,options)
% PLOTFUNCTIONTEMPLATE makes a plot from the given RunDatas against the
% dependent variable {varied_variable_name}. Optional arguments are passed
% to setupPlot, which automatically puts axes and a legend on the plot,
% resizes the axes, etc.
% 
%         I recommend starting out by not touching the optional arguments.
%
% The RunDatas input can either be a single RunData object, or a cell array
% of RunData objects.
%
% varied_variable_name is the cicero variable name (as a string) of the
% independent variable for the RunDatas you've provided.
%
% legendvars must be specified as a cell array of strings. The names of
% the variables are used as the title of the legend, and their values for
% each plotted RunData are added to the legend.
%
% varargin can be provided as a cell array of cicero variable names which
% are held constant across ALL RunDatas provided in the set. These
% variables (and their values) are added to the plot title. 
%
%       For variables held constant in just one RunData out of the provided
%       set (such as the 915 depth when plotting widths of many runs vs.
%       time on the same axes), specify those variables in legendvars so
%       that the runs will be labeled in the legend.

% Just copy-paste this arguments list. You can of course add more arguments
% to your own functions.
arguments
    RunDatas
    varied_variable_name
    legendvars
end
arguments (Repeating)
    varargin
end
arguments
    options.LineWidth (1,1) double = 1.5
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
    options.Interpreter (1,1) string = "latex" % alt: 'none', 'tex'
    %
    options.LegendLabels = [] % leave as is if you want auto-labels
    options.LegendTitle string = "" % leave as is if you want auto-title
    options.Position (1,4) double = [2561, 27, 1920, 963];
    %
    options.PlotTitle = "" % leave as is if you want auto-title
    %
    options.xLim (1,2) double = [0,0]
    options.yLim (1,2) double = [0,0]
    %
    options.PlotPadding = 0;
end

    % Use avgRepeats on your RunDatas to extract repeat-averaged values of
    % whichever cicero variables (vars_to_be_averaged) you want to work
    % with. Here I wanted those values associated with each RunData
    % individually, so I looped over the RunDatas and repeat-averaged each
    % one.
    vars_to_be_averaged = {'summedODy','cloudSDy'};
    for j = 1:length(RunDatas)
        [avg_atomdata{j}, varied_var_values{j}] = avgRepeats(...
            RunDatas{j}, varied_variable_name, vars_to_be_averaged);
    end
    % Work is in progress to make it easier to repeat-average subsets of
    % RunDatas while only repeat-averaging other individual RunDatas.
    %
    % The output, avg_atomdata will be a struct which will have fields of
    % the averaged values. I recommend you look at how this is structured
    % before writing the rest of the plot function.
    
    % You could also feed avgRepeats a cell array of RunDatas, as done
    % below. If you do, it will try to repeat-average all of them together.
    % Careful here -- I haven't put in error messages for if you feed it
    % RunDatas that shouldn't be repeat-averaged, and will yield unexpected
    % results. Better handling is in development.
    
%         [avg_atomdata, varied_var_values] = avgRepeats(...
%             RunDatas, varied_variable_name, vars_to_be_averaged);
        
    % Obviously I would not do both of the above. They are applicable in
    % different cases.
    
    % Now that you have the repeat-averaged values for each RunData (or for
    % the averaged set, if you averaged all of them together), you can
    % compute and plot whichever quantities you want to plot.
    %
    % The output of plotFunctions should include a figure handle and a
    % filename to which the figure can be saved. Define the handle when you
    % make the figure. The filename will be generated later.
    %
    % I also define a colormap here to get good contrast between the
    % different traces (with default, more than 5 traces will start
    % repeating colors).
    
    fig_handle = figure();
    cmap = colormap( jet( length(RunDatas) ) );
    
    % I also typically define here the dependent variable string that will
    % appear in my plot title. "vs. {varied_variable_name}" will be
    % appended. As an example, I'll use the specific case of plotting the
    % fractional widths based on the summedODy:
    
    figure_title_dependent_var = 'FracWidth (summedODy)';
    
    % As an example of doing things with the repeat-averaged output, here I
    % use the averaged atomdata to compute the fractional widths of each
    % RunData. To get these, I used the first option above, and just
    % repeat-averaged each set within itself.
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%% Data manipulation ex. %%%
    for j = 1:length(RunDatas)
        % Since fracWidth wants an x-axis, I generated one here for the jth
        % RunData. The details aren't important.
        X{j} = ( 1:size( avg_atomdata{j}(1).summedODy, 2 ) ) * xConvert;
        
        % Here I compute each fracWidth from the repeat-averaged densities
        % for the iith entry in each RunData, which are stored in
        % avg_atomdata{j}(ii).summedODy
        for ii = 1:size(avg_atomdata{j}, 2)
            widths{j}(ii) = fracWidth( X{j}, avg_atomdata{j}(ii).(plottedDensity), 0.5);
        end
    end
    %%% End Data Manipulation %%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Then plot things, just looping over the values I computed above.
    
    for j = 1:length(RunDatas)
        plot( varied_var_values{j}, widths{j}, 'o-',...
            'LineWidth', options.LineWidth,...
            'Color',cmap(j,:));
        hold on;
    end
    hold off;
    
    % Finally, to take advantage of a lot of the automation I've built
    % around the RunData objects, you need to copy-paste the following. You
    % shouldn't have to change anything here, unless (obviously) you used
    % different variable names for the figure_title_dependent_var or
    % fig_handle.
    
    [plot_title, figure_filename] = ...
        setupPlotWrap( ...
            figure_handle, ...
            options, ...
            RunDatas, ...
            dependent_var, ...
            varied_variable_name, ...
            legendvars, ...
            varargin);
    
    % Note that the setupPlot function outputs a figure filename to be used
    % when saving the figure. It will include the run numbers, dates, and
    % the independent variable and held variable names/values.
    
end