current_dir = pwd;

output_dir = "G:\My Drive\_WeldLab\Code\Analysis\_DataAnalysis\_data_loading";
cd(output_dir);

infoTablePath = '_09-Dec-2020_17-Dec-2020_NoDrive.csv';
numCols = 7; % To load the table as all strings, you must specify the number of columns.
infoTable = readtable(infoTablePath,'Format',repmat('%s',[1,numCols]),'TextType','char','Delimiter',',');

dataDir = 'E:\__Data\StrontiumData';
% dataDir = 'X:\StrontiumData';
    % (A check for you that your directory exists according to Matlab:)
    if ~exist(dataDir,'dir')
        error(['The directory (folder).' dataDir ' does not exist'])
    end

ncVars = {}; 
includeVars = {'VVA1064_Er','VVA915_Er','LatticeHold'};
excludeVars = {'IterationCount','IterationNum','ImageTime','LogTime'};

Data2020_12_17 = RunDataLibrary('Data from all the runs');
% allData = allData.autoConstruct(...
%     infoTable,dataDir,ncVars,includeVars,excludeVars);
Data2020_12_17 = Data2020_12_17.autoConstruct(...
    infoTable,dataDir,ncVars,includeVars,excludeVars);

save('allData_2020.12.17.mat','Data2020_12_17');
winopen(output_dir);

cd(current_dir);