%% Get the Data

% Load the RunDataLibrary object containing all the data that you generated
% with autoLibGen (or otherwise). You'll obviously need to change
% these paths.
data_dir = 'G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_data_loading\Data';
data_file = '15-Dec-2020_23-Dec-2020.mat';
data_path = fullfile(data_dir,data_file);

if ~exist('DATA','var')
    load( data_path );
    DATA = Data; % rename this because I'm going to overwrite Data later.
end

%% Sort the Data

%%% Select Runs to use for Plotting %%%
% Select which runs you'll be plotting from the large library. Uses Max's
% selectRuns GUI.

selectRuns(DATA);
% Added pause so that you can select your data before continuing. Just
% press any key in the MatLab command window to continue once you're done.
pause; 

% selectRuns saves a cell array ("RunDatas") of the selected runDatas to
% the workspace, as well as the variable selections ("RunVars") (for which
% variable is varied, which are held, etc) you made in the GUI.
%
% Also saves the full RunDataLibrary ("runDataLib") of the selected runs,
% in case you are a pro-gamer and want to use that.
%
% RunVars also contains the generating condition for this set of runs, in
% case you want to save it and generate the same subset of runs from DATA
% in the future (without using the GUI).

%%
%%% unpack the runvars: %%%
% You'll use these as the arguments to your plotFunctions to specify how
% the title and legend should be labeled.

[varied_var, ...
 heldvars_each, ...
 heldvars_all, ...
 legendvars_each, ...
 legendvars_all] = unpackRunVars(RunVars);
 
% Use the "each" variables for plots which only contain a single run from
% your selected runs (such as stackedExpansionPlot), and the "all"
% variables for plots which contain multiple runs (such as
% widthEvolutionPlot).

%% Now you can call your plotfunctions!

%% Stacked Expansion Plots 

% Here I loop over the runDatas and make an expansion plot for each (since
% I don't want multiple runs on each plot)

% specify which density you want
plotted_density = 'summedODy';

for j = 1:length(runDatas)
    [expansion_plot{j}, expansion_plot_filename{j}] = stackedExpansionPlot(RunDatas{j},1,...
        varied_var,legendvars_each,heldvars_each,...
        'PlottedDensity',plotted_density);
end

%% Width Evolution Plot
% Plots fractional width vs varied_var, computed from the specified
% PlottedDensity. The SmoothWindow option smooths the data (movmean) over
% the specified number of points, which helps fracWidth not pick out widths
% from noisy peaks.

[width_evo_plot, width_evo_filename] = widthEvolutionPlot(RunDatas,...
    varied_var,legendvars_all,heldvars_all,...
    'WidthFraction',0.3,...
    'PlottedDensity','summedODy',...
    'yLim',[0,200],...
    'SmoothWindow',10);

%% Center Positions Plot

% specify which density you want
plotted_density = 'summedODx';

[centers_plot, centers_plot_filename] = ...
    centersPlot(RunDatas,...
    varied_var,legendvars_all,heldvars_all,...
    'PlottedDensity',plotted_density,...
    'yLim',[78,90],...
    'SmoothWindow',10,...
    'WidthFraction',0.65);

%% Specify Output Directories and Save the Figures

analysis_output_dir = "G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_out";

% I want to put the expansion plots in their own subdirectory.
expansion_plot_dir = strcat( analysis_output_dir, filesep, "expansion_plots");

% This saveFigure function takes in the figure handle, filename, and the
% directory you'd like to save it in. Automatically handles filesep. Saves
% the figure with that filename to the specified path.
saveFigure(expansion_plot, expansion_plot_filename, expansion_plot_dir);
saveFigure(width_evo_plot, width_evo_filename, analysis_output_dir);
saveFigure(centers_plot, centers_plot_filename, analysis_output_dir);

%% Open the Ouput Directory
% Because I am lazy and don't want to navigate to the directory where the
% plots were saved.

if ispc
    winopen(analysis_output_dir);
end