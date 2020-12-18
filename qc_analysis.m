%% Define things

analysis_output_dir = "G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_out";

%% Get the Data

data_dir = "G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_data_loading";
if ~exist('DATA','var')
    load('allData_2020.12.17.mat');
    DATA = Data2020_12_17;
end

%% Sort the Data

condition = {'RunID','12_14','RunNumber',{'27' '28' '29' '30' '31' '32' }}; % Disorder Runs

Data = RunDataLibrary();
Data = Data.libraryConstruct(DATA,condition);
runDatas = Data.RunDatas;

%% Get data subset

% runNumber = 32;
%
% idx = contains(Data.RunIDs,['Run-' num2str(runNumber)]);
% runData = Data.RunDatas{idx};

%%

% for j = 1:length(runDatas)
%     stackedExpansionPlot(runDatas{j},1,'VVA915_Er','LatticeHold','VVA1064_Er');
% end

[width_evo_plot, width_evo_filename] = widthEvolutionPlot(runDatas,'VVA915_Er','LatticeHold',...
    'VVA1064_Er','TOF',...
    'WidthFraction',0.5,...
    'IncludeSDPlot',0,...
    'yLim',[0,200]);

saveas(width_evo_plot, fullfile(analysis_output_dir,width_evo_filename));

%%

winopen(analysis_output_dir);