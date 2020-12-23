# Data Analysis Package

The idea was to package together a bunch of functions that make building plots and analyzing data from RunDatas much easier. Includes a tool (GetRunDatas) for streamlining pulling a RunDataLibrary from a datatable.csv using DataManager.

## Getting Started
Check out exampleAnalysis_QC.m to see how to set up and use the plot functions. Most of this is just sorting/manipulating the DataManager objects to pare them down to the runs we want.

For a tutorial in writing plot functions using this architecture, read plotFunctionTemplate.m.

## DataManager
The GetRunData function in _data_loading requires dataManager to be on MatLab path. See [the dataManager GitHub](https://github.com/weldlabucsb/dataManager) to get dataManager. GetRunData will eventually move to the dataManager repository, and its use will soon be made much easier by a GUI solution.

As seen in exampleAnalysis_QC.m, the process of picking out the runs you want can be a bit cumbersome. We are working on a GUI solution to streamline this process and make it much more user-friendly.
## Useful functions:
- plotTitle: takes in a RunData object or a cell array of RunData objects, and outputs a multi-line plotTitle. First line specifies the dependent variable being plotted and the varied variable (a cicero variable). Varargs (cell array of cicero variable names (strings)) optionally adds a line of cicero variables that were held constant and their values. Next line specifies the dates and run numbers that were present in the provided RunData(s). Function outputs title as a cell array of strings which can be passed to title().

- filenameFromPlotTitle: takes in cell array (of strings) output from plotTitle and outputs a .png filename which can be used to save the figure.

- setupPlot: an absolute beast of a function with a billion optional arguments. Call the same way as plotTitle. Passes several of its arguments to plotTitle. Uses this plotTitle and the other optional arguments to adjust x/y labels, x/ylims, etc. See docstring for optional arguments. Also outputs the figure title output of plotTitle.
    - Automatically outputs a figure filename as its second argument, to be used when saving the figure. It includes the same information as the plot title: run dates and numbers, dependent and independent variables, and values of held variables.
    - legendvars is a cell array of variable names whose names should be included in the legend title, and whose values should be associated with each entry in the legend. Example: legendvars = {'VVA1064_Er','VVA915_Er'} produces a legend where each entry is labeled by the 1064 depth and 915 depth.
        - Leave the LegendLabels and LegendTitle options unspecified to automatically generate the legends this way. If you specify them as options to setupPlot, you will respectively override the automatic generation of the legend labels/title.
    - If calling setupPlot in a plot function, I generally give the plot function the same optional arguments that are to be passed to setupPlot and adjust the default values according to the plot function I'm writing. Then at the end of the plot function, call it through its wrapper function, setupPlotWrap (see below).

- setupPlotWrap: a wrapper function for setupPlot that allows you to feed it the full options struct of your plot function, so that the copy/pasted block doesn't end up being quite so obnoxious. Call it like this:

```matlab
[plot_title, figure_filename] = setupPlotWrap( figure_handle, options, RunDatas, dependent_var, varied_variable_name, legendvars, varargin);
```

- avgRepeats averages the repeats in the provided RunData for each value of the specified varied cicero variable. Can average repeats over multiple RunDatas if provided as a cell array of RunDatas. Outputs an averaged atomdata-like structure with averaged values for the variable names provided as a cell array (of strings) as its third argument.

## Current State of Affairs
I've so far built a couple plotting functions based on this functionality, such as stackedExpansionPlot and widthEvolutionPlot. More will follow.

The custom functions also include a few of my fitting functions that are holdovers from an older version of my analysis code. fracWidth works reasonably well (to find the width at which a function hits a fraction of its maximum value), but still chokes on noisy distributions. I would not expect the rest to work well until I update them.