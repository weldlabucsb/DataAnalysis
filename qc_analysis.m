%% Define things

%% Get the Data

data_dir = 'G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_data_loading\Data\';
if ~exist('DATA','var')
    load([data_dir filesep 'Data_18-Dec-2020.mat']);
    DATA = Data;
end

%% Sort the Data

% Disorder Runs
% condition = {'RunID','12_14','RunNumber',{'27' '28' '29' '30' '31' '32'}};
% varied_var = 'VVA915_Er';
% heldvars_each = {'LatticeHold','TOF','VVA1064_Er'};
% heldvars_all = {'LatticeHold','TOF'};

% LatticeHold Runs
% condition = {'RunID', '12_09', 'RunNumber', ...
%     makeRunNumberList([23 24 26 27 29 30 32:41])};
condition = {'RunID', '12_09', 'RunNumber', ...
    makeRunNumberList([25 28 31 32:41])};
varied_var = 'LatticeHold';
heldvars_each = {'VVA915_Er','VVA1064_Er'};
heldvars_all = {};

Data = RunDataLibrary();
Data = Data.libraryConstruct(DATA,condition);
runDatas = Data.RunDatas;

%% Get data subset

% runNumber = 32;
%
% idx = contains(Data.RunIDs,['Run-' num2str(runNumber)]);
% runData = Data.RunDatas{idx};

%%

for j = 1:length(runDatas)
    [expansion_plot{j}, expansion_plot_filename{j}] = stackedExpansionPlot(runDatas{j},1,...
        varied_var,heldvars_each,...
        'PlottedDensity','summedODy');
end

[width_evo_plot, width_evo_filename] = widthEvolutionPlot(runDatas,...
    varied_var,heldvars_all,...
    'WidthFraction',0.75,...
    'IncludeSDPlot',1,...
    'PlottedDensity','summedODy',...
    'yLim',[0,200]);

%% Save the Figures

analysis_output_dir = "G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_out";
expansion_plot_dir = strcat( analysis_output_dir, filesep, "expansion_plots");

saveFigure(expansion_plot, expansion_plot_filename, expansion_plot_dir);
saveFigure(width_evo_plot, width_evo_filename, analysis_output_dir);

%% Open the Ouput Directory

winopen(analysis_output_dir);