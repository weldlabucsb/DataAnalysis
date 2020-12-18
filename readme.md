# Data Analysis Package

The idea was to package together a bunch of functions that make building plots and analyzing data from RunDatas much easier. Includes a tool (GetRunDatas) for streamlining pulling a RunDataLibrary from a datatable.csv using DataManager.

Useful functions:
- plotTitle: takes in a RunData object or a cell array of RunData objects, and outputs a multi-line plotTitle. First line specifies the dependent variable being plotted and the varied variable (a cicero variable). Optionally adds a line of cicero variables that were held constant and their values. Next line specifies the dates and run numbers that were present in the provided RunData(s). Function outputs a cell array of strings which can be passed to title().

- filenameFromPlotTitle: takes in cell array (of strings) output from plotTitle and outputs a .png filename which can be used to save the figure.

- setupPlot: an absolute beast of a function with a billion optional arguments. Call the same way as plotTitle. Passes several of its arguments to plotTitle. Uses this plotTitle and the other optional arguments to adjust x/y labels, x/ylims, etc. See docstring for optional arguments. Also outputs the figure title output of plotTitle.
    - If calling setupPlot in a plot function, I generally give the plot function the same optional arguments that are to be passed to setupPlot and adjust the default values according to the plot function I'm writing. At the end when I call setupPlot, I manually specify each option that is to be passed to setupPlot. I'd like to find a way to just pass setupPlot the entire options struct, but this works for now and isn't too bad to copy/paste. Example:

```matlab
plot_title = setupPlot( width_evo_plot, RunDatas, ...
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
```
- avgRepeats averages the repeats in the provided RunData for each value of the specified varied cicero variable. Can average repeats over multiple RunDatas if provided as a cell array of RunDatas. Currently outputs averaged summedODy, varied_variable_values, and yWidths (SD of gaussian fit), but will later be extended to output the repeat-averaged specified cicero variable name.

I've so far built a couple plotting functions based on this functionality, such as stackedExpansionPlot and widthEvolutionPlot. More will follow.

The custom functions also include a few of my fitting functions that are holdovers from an older version of my analysis code. fracWidth works reasonably well (to find the width at which a function hits a fraction of its maximum value), but still chokes on noisy distributions or distributions that never reach the specified fractional value. I would not expect the rest to work well until I update them.

The GetRunData function in _data_loading requires dataManager to be on MatLab path. See [the dataManager GitHub](https://github.com/weldlabucsb/dataManager) to get dataManager and to read about how it works.