%% Get the Data

% Load the RunDataLibrary object that you generated with the beam trawler
% (or otherwise). You'll obviously need to change these paths.
data_dir = 'G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_data_loading\Data';
data_file = '15-Dec-2020_23-Dec-2020.mat';
data_path = fullfile(data_dir,data_file);

if ~exist('DATA','var')
    load( data_path );
    DATA = Data; % rename this because I'm going to overwrite Data later.
end

%% Sort the Data
% Uncomment whichever chunks of data you want to look at. 
% Uncomment only one condition.

clear condition varied_var heldvars_each legendvars_each heldvars_all legendvars_each

%%%%%%%%%%%%%%%%%%%%%
%%% Disorder Runs %%%

% condition = {'RunID','12_14','RunNumber',{'27' '28' '29' '30' '31' '32'}};
% 
% varied_var = 'VVA915_Er';
% heldvars_each = {'LatticeHold','TOF','VVA1064_Er'};
% legendvars_each = varied_var;
% heldvars_all = {'LatticeHold','TOF'};
% legendvars_all = heldvars_each;

%%%%%%%%%%%%%%%%%%%%%%%%
%%% LatticeHold Runs %%%

% condition = {'RunID', '12_09', 'RunNumber', ...
%     makeRunNumberList([23 24 26 27 29 30 32:41])};

% condition = {'RunID', '12_09', 'RunNumber', ...
%     makeRunNumberList([25 28 31 32:36 40 41])};
% 
% varied_var = 'LatticeHold';
% heldvars_each = {'VVA915_Er','VVA1064_Er'};
% legendvars_each = {varied_var};
% heldvars_all = {};
% legendvars_all = heldvars_each;

%%%%%%%%%%%%%%%%%%%%%%%
%%% Slow Drive Runs %%%

% condition = {'RunID', '12_15', 'RunNumber',...
%     makeRunNumberList([23:42])};

% condition = {'RunID', '12_15', 'RunNumber',...
%     makeRunNumberList([32:37])};
% 
% varied_var = 'LatticeHold';
% heldvars_each = 
% legendvars_each = 
% heldvars_all = {};
% legendvars_all = 
% piezo_freq_tag = 1;

%%%%%%%%%%%%%%%%%%%%%%%%
%%% Later Drive Runs %%%

% Still need to write out the vars for these

condition = {'RunID', '12_16', 'RunNumber',...
    makeRunNumberList([9:12])};

varied_var = 'PiezoModFreq';
heldvars_each = {'LatticeHold','VVA1064_Er','VVA915_Er','PiezoAmp'};
legendvars_each = {varied_var};
heldvars_all = {'LatticeHold'};
legendvars_all = heldvars_each;
piezo_freq_tag = 1;

% condition = {'RunID', '12_18', 'RunNumber',...
%     makeRunNumberList([19:30])};
% condition = {'RunID', '12_19', 'RunNumber',...
%     makeRunNumberList([7:30])};

%%%%%%%%%%%%%%%%%%%%%%%

% This part takes in the condition from above and filters out the relevant
% runDatas. Note that at the end I just pull out the runDatas part of the
% Data structure -- this is the cell array of RunDatas that you'll feed to
% the plot functions.
Data = RunDataLibrary();
Data = Data.libraryConstruct(DATA,condition);
runDatas = Data.RunDatas;

if isempty(runDatas)
   error("runDatas is empty. Are your conditions right?"); 
end

%% Now you can call your plotfunctions!

%% Stacked Expansion Plots 

% Here I loop over the runDatas and make an expansion plot for each (since
% I don't want multiple runs on each plot)

% specify which density you want
plotted_density = 'summedODy';

for j = 1:length(runDatas)
    [expansion_plot{j}, expansion_plot_filename{j}] = stackedExpansionPlot(runDatas{j},1,...
        varied_var,legendvars_each,heldvars_each,...
        'PlottedDensity',plotted_density);
end

%% Width Evolution Plot
% Plots fractional width vs varied_var, computed from the specified
% PlottedDensity. The SmoothWindow option smooths the data (movmean) over
% the specified number of points, which helps fracWidth not pick out widths
% from noisy peaks.

[width_evo_plot, width_evo_filename] = widthEvolutionPlot(runDatas,...
    varied_var,legendvars_all,heldvars_all,...
    'WidthFraction',0.3,...
    'PlottedDensity','summedODy',...
    'yLim',[0,200],...
    'SmoothWindow',10);

%% Center Positions Plot

% specify which density you want
plotted_density = 'summedODx';

[centers_plot, centers_plot_filename] = ...
    centersPlot(runDatas,...
    varied_var,legendvars_all,heldvars_all,...
    'PlottedDensity',plotted_density,...
    'yLim',[78,90],...
    'SmoothWindow',10,...
    'WidthFraction',0.65);

%% Save the Figures

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

if ispc
    winopen(analysis_output_dir);
end