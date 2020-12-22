%% Define things

%% Get the Data

data_dir = 'G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_data_loading\Data\';
if ~exist('DATA','var')
    load([data_dir filesep 'Data_21-Dec-2020.mat']);
    DATA = Data;
end

%% Sort the Data

% % % Disorder Runs
% condition = {'RunID','12_14','RunNumber',{'27' '28' '29' '30' '31' '32'}};
% varied_var = 'VVA915_Er';
% heldvars_each = {'LatticeHold','TOF','VVA1064_Er'};
% heldvars_all = {'LatticeHold','TOF'};

% % % LatticeHold Runs
% condition = {'RunID', '12_09', 'RunNumber', ...
%     makeRunNumberList([23 24 26 27 29 30 32:41])};
% condition = {'RunID', '12_09', 'RunNumber', ...
%     makeRunNumberList([25 28 31 32:36 40 41])};
% varied_var = 'LatticeHold';
% heldvars_each = {'VVA915_Er','VVA1064_Er'};
% heldvars_all = {};

% % % Slow Drive Runs
% condition = {'RunID', '12_15', 'RunNumber',...
%     makeRunNumberList([23:42])};

condition = {'RunID', '12_15', 'RunNumber',...
    makeRunNumberList([32:37])};
varied_var = 'LatticeHold';
heldvars_each = {'PiezoModFreq'};
heldvars_all = {};
piezo_freq_tag = 1;
widthYLim = [0,400];

% condition = {'RunID', '12_16', 'RunNumber',...
%     makeRunNumberList([9:16])};
% condition = {'RunID', '12_18', 'RunNumber',...
%     makeRunNumberList([19:30])};
% condition = {'RunID', '12_19', 'RunNumber',...
%     makeRunNumberList([7:30])};


Data = RunDataLibrary();
Data = Data.libraryConstruct(DATA,condition);
runDatas = Data.RunDatas;

%% 

%%

for j = 1:length(runDatas)
    [expansion_plot{j}, expansion_plot_filename{j}] = stackedExpansionPlot(runDatas{j},1,...
        varied_var,heldvars_each,...
        'PlottedDensity','summedODx');
end

%%

[width_evo_plot, width_evo_filename] = widthEvolutionPlot(runDatas,...
    varied_var,heldvars_all,...
    'WidthFraction',0.3,...
    'IncludeSDPlot',0,...
    'PlottedDensity','summedODy',...
    'yLim',widthYLim,...
    'SmoothWindow',10,...
    'PiezoFreqTag',piezo_freq_tag);

%%

[centers_plot, centers_plot_filename] = ...
    centersPlot(runDatas,...
    varied_var,heldvars_all,...
    'PlottedDensity','summedODx',...
    'yLim',[78,90],...
    'SmoothWindow',10,...
    'WidthFraction',0.65);

%% Save the Figures

analysis_output_dir = "G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_out";
expansion_plot_dir = strcat( analysis_output_dir, filesep, "expansion_plots");

saveFigure(expansion_plot, expansion_plot_filename, expansion_plot_dir);
saveFigure(width_evo_plot, width_evo_filename, analysis_output_dir);
saveFigure(centers_plot, centers_plot_filename, analysis_output_dir);

%% Open the Ouput Directory

winopen(analysis_output_dir);