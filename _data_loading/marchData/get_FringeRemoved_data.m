data_directory = "G:\My Drive\_WeldLab\Code\Analysis\quasicrystal_transport\_data_loading";
cd(data_directory);

numCols = 9; % To load the table as all strings, you must specify the number of columns.
infoTable = readtable('AutoConstrTable_FringeRemoved_TimeVary.csv','Format',repmat('%s',[1,numCols]),'TextType','char','Delimiter',',');

dataDir = 'W:\StrontiumData';
    % (A check for you that your directory exists according to Matlab:)
    if ~exist(dataDir,'dir')
        error(['The directory (folder).' dataDir ' does not exist'])
    end

ncVars = {'KDCal915','ImagingPowerVVA'}; 
includeVars = {'VVA1064_Er','VVA915_Er','LatticeHold'};
excludeVars = {'IterationCount','IterationNum'};

frData = RunDataLibrary('Data from all the runs');
frData = frData.autoConstruct(...
    infoTable,dataDir,ncVars,includeVars,excludeVars);

save('frData','frData')