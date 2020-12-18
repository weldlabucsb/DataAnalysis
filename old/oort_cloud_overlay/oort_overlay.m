%% Initialize data:

%% Figure Options

save_figures = 1;
fig_folder = 'G:\My Drive\_WeldLab\Code\Analysis\quasicrystal_transport\new_figs\new\';

smooth_data = 1;
smooth_window_width = 7;

zoom_window = [-20 200];
plotEvery = 3;

plot_stuff = 1;

%% Figure Aesthetic Options

fontsize = 30; % Legends for expansion plots are by default at fontsize/2
titleFontSize = 24;
dotSize = 8; % marker sizes

%% Data Loading

group = 1;
groupSave = 1;

whichGroups = [1 2 3];
Ngroups = length(whichGroups);

for groupSelect = whichGroups

data_directory = "G:\My Drive\_WeldLab\Code\Analysis\quasicrystal_transport\_data_loading";
cd(data_directory);

fringe_removal = 1;

high_imaging_power_data = 0;
toshi_runs_85 = 0;
fix_ramp_85 = 0;
toshi_runs_10 = 0;

if ~exist('allData','var') && ~fringe_removal
    load('allData.mat')
end

if ~exist('frData','var') && fringe_removal
    load('frData.mat')
end

if fringe_removal
    DATA = frData;
elseif ~fringe_removal
    DATA = allData;
end

%% Select Data
% Note that latticeDepthRanges can't be specified exactly, due to some
% weird decimal problems with how the RunDatas store the lattice depth
% values. Just give it windows (non-overlapping) around the lattice values
% you know are in each run.

high_power = 0;

% groups of run IDs that are to be plotted together
if high_imaging_power_data || groupSelect == 1
    Data = RunDataLibrary('Only runs with high imaging power');
    Data = Data.libraryConstruct(DATA, { 'ImagingPowerVVA', '780' } );
    latticeDepthRanges = {'0.01to0.05','0.06to0.15','0.4to1'};
    high_power = 1;
end

if toshi_runs_85 || groupSelect == 3
    condition = {'RunID','03_19','RunNumber',{'12','13','14','16','17','18','19','20','21'}};

    Data = RunDataLibrary('The runs from Toshi slide');
    Data = Data.libraryConstruct(...
        DATA,condition);
    latticeDepthRanges = {'0.04to0.06','0.07to0.3','0.5to2'};
end

if toshi_runs_10 || groupSelect == 2
    condition = {'RunID','03_18','RunNumber',{'20','21','22'}};
    
    Data = RunDataLibrary('The runs from Toshi slide');
    Data = Data.libraryConstruct(...
        DATA,condition);
    latticeDepthRanges = {'0.01to0.05','0.06to0.15','0.4to1'};
end

if fix_ramp_85 || groupSelect == 4
    condition = {'RunID','03_19','RunNumber',{'22','23','24'}};

    Data = RunDataLibrary('The runs from Toshi slide');
    Data = Data.libraryConstruct(...
        DATA,condition);
    latticeDepthRanges = {'0.05to0.06'};
end

%% Averaging, Titles

for averaging = 1

clear('ShortTitleRunSpecific','TitleRunSpecific','sets','GeneralTitle','densities');
    
sets = 1:length(latticeDepthRanges); 

for dataSet = sets
    
    %% Setup and Averaging
    
    setsWithThisLatticeDepth = Data.whichRuns({ 'VVA915_Er', latticeDepthRanges{dataSet} });
    
    ads = [];
    for ii = 1:length(setsWithThisLatticeDepth)
        ads = [ads; setsWithThisLatticeDepth{ii}.Atomdata];
    end
    
    density_raw = [];
    holdtimes_raw = [];
    ywidths_raw = [];
    
    for ii=1:length(ads)
        holdtimes_raw(ii) = ads(ii).vars.LatticeHold;
        ywidths_raw(ii) = ads(ii).cloudSD_y;
        density_raw(ii,:) = ads(ii).summedODy;
    end
    
    [holdtimes_raw, inds] = sort(holdtimes_raw);
    ywidths_raw = ywidths_raw(inds);
    density_raw = density_raw(inds,:);

    [holdtimes,~,idx] = unique(holdtimes_raw);
    N = length(holdtimes);
    
    ywidths = accumarray(idx, ywidths_raw, [], @mean);

    density = [];

    % Averages profiles with same holdtime together, returns averaged
    % density
    for ii = 1:N
        thishold = holdtimes(ii);
        thisprofile = density_raw(holdtimes_raw == thishold,:); 
        % grabs only the row(s) of profile_A with holdtimeA == thishold
        thisprofile = mean(thisprofile,1); 
        density = [density; thisprofile]; 
        % vertical appends thisprofile to profile_A_avg
    end
    
    densities{dataSet} = density;
    
    X = 1:size(density,2);
    
    %% Construct Plot Titles
    
    this1064 = round(setsWithThisLatticeDepth{1}.vars.VVA1064_Er,2)  ;
    this915 = round(setsWithThisLatticeDepth{1}.vars.VVA915_Er,2);
    
    lattice915{dataSet} = this915;
    
    thedate{dataSet} = strcat(...
        num2str(setsWithThisLatticeDepth{1}.Year),"-", ...
        num2str(setsWithThisLatticeDepth{1}.Month),"-", ...
        num2str(setsWithThisLatticeDepth{1}.Day));
    
    theShortDate{dataSet} = strcat(...
        num2str(setsWithThisLatticeDepth{1}.Month),".", ...
        num2str(setsWithThisLatticeDepth{1}.Day));
        
    runNumbers = [];
    for ii = 1:length(setsWithThisLatticeDepth)
        runNumbers = [runNumbers, ...
            convertCharsToStrings(...
            num2str(setsWithThisLatticeDepth{ii}.RunNumber))];
    end
    
    runNumber{dataSet} = strings(1);
    for ii = 1:length(runNumbers)
        if ii == 1
            runNumber{dataSet} = runNumbers(1);
        else
            runNumber{dataSet} = strcat(runNumber{dataSet},", ",runNumbers(ii));
        end
    end
    
    pp = setsWithThisLatticeDepth{1};
    
    if contains(pp.FilePath,'(fr)')
        fr_tag = " (fr)";
    else
        fr_tag = "";
    end
    
    TitleRunSpecific{dataSet} =  strcat(thedate{dataSet},", Avg of Runs ",...
        runNumber{dataSet},fr_tag, ...
        ", 1064 Depth - ", num2str(this1064), " Er, ", ...
        " 915 Depth - ", num2str(this915), " Er");

%     TitleRunSpecific{dataSet} =  strcat(thedate{dataSet} ," Runs ", runNumber{dataSet},fr_tag, ...
%             " 915 Depth - ", num2str(this915), " Er");

    if high_power
        hp_tag = " (hp) ";
    else
        hp_tag = "";
    end

    ShortTitleRunSpecific{dataSet} = ...
        strcat(theShortDate{dataSet}," - ",num2str(runNumber{dataSet}),hp_tag,"; ",...
        num2str(this915),"+",num2str(this1064));
    
    %% Evolution Figure
    
    if smooth_data
        for ii = 1:N
            density(ii,:) = movmean(density(ii,:),smooth_window_width);
        end
    end
    
    densities{dataSet} = density;
    
end

for jj = 1:length(runNumber)
        if jj == 1
            allRunNumbers = strcat("(",runNumber{1},")");
        else
            allRunNumbers = strcat(allRunNumbers,", (",runNumber{jj},")");
        end
    end

GeneralTitle =  strcat(thedate{dataSet},", Runs ", allRunNumbers,fr_tag,",", ...
    " 1064 Depth - ", num2str(this1064), " Er");


if groupSave

    bigBoi{groupSelect} = struct(...
        "Density",densities,...
        "GeneralTitle",GeneralTitle,...
        "ShortRunTitle",ShortTitleRunSpecific,...
        "RunTitle",TitleRunSpecific,...
        "Sets",sets);

end

end

end

%% Plotting

if plot_stuff

figure(1)

counter = 1;

groups = whichGroups;

for g = groups
    
    thisBoi = bigBoi{g};
    sets = thisBoi(1).Sets;

    for dataSet = sets
        
        if length(sets) > 1
            theBoi = thisBoi(dataSet);
        else
            theBoi = thisBoi;
        end
        
        density = theBoi.Density;
        
        x = 1:size(density,2);
    
        N = size(density,1);
        whichPlots = [1 4 7 11 13];
        nPlots = length(whichPlots);

        thisPlot = whichPlots(dataSet);
        subplot(Ngroups,3,counter)

        cmap = flip(colormap(bone(nPlots+2)));

        for ii = 1:nPlots
            
            plotIndex = whichPlots(ii);

            hold on
            plot(x, density(plotIndex,:), 'LineWidth', 2, 'Color', cmap(ii+2,:))
            ylim(zoom_window)

        end

        counter = counter + 1;

        hold off

        Title1 = "Oorts Grid";  
        Title2 = theBoi.ShortRunTitle;
        title(Title2,'FontSize',titleFontSize/1.5,'interpreter','latex');
        % ylabel('Density (a.u.)','FontSize',fontsize,'interpreter','latex');
        % xlabel('Position (pixels)','FontSize',fontsize,'interpreter','latex');
    
    end

end

str = {"Subplot title format: [Date] - [Run Number(s)]; [Secondary Lattice Depth (Er)]+[Primary Lattice Depth (Er)]",...
    "Time evolution shown as color gradient: lighter = early times, darker = later times.",...
    "Multiple run numbers are averaged together. (hp) denotes high imaging power datasets "};
tbox = annotation('textbox',[0.23 0.03 0.6 0.05],'String',str,'FitBoxToText','off','FontSize',20);
tbox.Interpreter = 'latex';
tbox.LineStyle = 'none';
tbox.HorizontalAlignment = 'center';
tbox.VerticalAlignment = 'top';

figure(1);

sgtitle("Oort Cloud Overview",'FontSize',titleFontSize,'interpreter','latex');
save_figure(fig_folder,"Oort Overview","",save_figures,...
    'Position',[ 1          41        2560        1323 ],...
    'OneTitle',1);

end

%% Functions

function save_figure(fig_folder,Title1,Title2,save_figures,options)
    
    arguments
        fig_folder 
        Title1
        Title2
        save_figures logical
    end
    arguments
       options.Position (1,4) double =  [6         151        1365        1199];
       options.OneTitle logical = 0
    end

    set(gcf,'Position',options.Position);
    
    filename = strcat(fig_folder, Title1,", ", Title2,".png");
    
    if options.OneTitle
        filename = strcat(fig_folder, Title1, ".png");
    end
    
    if save_figures
        saveas(gcf,filename);
    end
end