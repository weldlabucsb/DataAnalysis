%% Initialize data:

data_directory = "G:\My Drive\_WeldLab\Code\Analysis\quasicrystal_transport\_data_loading";
cd(data_directory);

fringe_removal = 1;

high_imaging_power_data = 0;
toshi_runs_85 = 1;
fix_ramp_85 = 0;
toshi_runs_10 = 0;
test = 0;

%%

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

clear('Data');

if high_imaging_power_data
    Data = RunDataLibrary('Only runs with high imaging power');
    Data = Data.libraryConstruct(DATA, { 'ImagingPowerVVA', '780' } );
    latticeDepthRanges = {'0.01to0.05','0.06to0.15','0.4to1'};
end

if toshi_runs_85
    condition = {'RunID','03_19','RunNumber',{'12','13','14','16','17','18','19','20','21'}};

    Data = RunDataLibrary('The runs from Toshi slide');
    Data = Data.libraryConstruct(...
        DATA,condition);
    latticeDepthRanges = {'0.04to0.06','0.07to0.3','0.5to2'};
end

if toshi_runs_10
    condition = {'RunID','03_18','RunNumber',{'20','21','22'}};
    
    Data = RunDataLibrary('The runs from Toshi slide');
    Data = Data.libraryConstruct(...
        DATA,condition);
    latticeDepthRanges = {'0.01to0.05','0.06to0.15','0.4to1'};
end

if fix_ramp_85
    condition = {'RunID','03_19','RunNumber',{'22','23','24'}};

    Data = RunDataLibrary('The runs from Toshi slide');
    Data = Data.libraryConstruct(...
        DATA,condition);
    latticeDepthRanges = {'0.05to0.06'};
end

%% Plot Options

close_figs_after_keypress = 0; % must click in to command window for keypress to register

fig_folder = 'G:\My Drive\_WeldLab\Code\Analysis\quasicrystal_transport\new_figs\new';
% fig_folder = 'G:\My Drive\_WeldLab\Code\Analysis\quasicrystal_transport\new_figs\toshi_replot\';
% fig_folder = 'G:\My Drive\_WeldLab\Code\Analysis\quasicrystal_transport\new_figs\high_intensity_plots';

fontsize = 30; % Legends for expansion plots are by default at fontsize/2
titleFontSize = 24;
dotSize = 8; % marker sizes
markerXSizeMultiplier = 2.5; % makes red fit-exclusion X's bigger
pixel_to_um_convert = 2; % 2 um per pixel

save_figures = 1;

smooth_data = 1;
smooth_window_width = 3;

switch_to_transverse_X = 0; % switches to plotting transverse sum X (from Y)

density_expansion_fig = 1;
offset_expansion_fig = 0;
zoom_expansion = 0;

if offset_expansion_fig
    zoom_expansion = 0;
end

kurtosis_fig = 0; % broken

atom_number_fig = 0;

oort_gif = 0; % only works if save_figures == 1
zoom_oort = 1;
smooth_window_width_gif = 5;
gif_frame_time = 0.4; % seconds
oort_timestamp_font_multiplier = 0.75;

frac_width_log_fig = 1;
plot_frac_fit = 1;
addFitExponentsToLegends_loglogPlot = 1;
markPointsNotUsedInFit_loglogPlot = 1;

int_sigmas_plot = 0;

frac_width_T_plot = 0;
invert_T_plot = 0; % makes vs. 1/T
addFitExponentsToLegends_Tplot = 1;
markPointsNotUsedInFit_Tplot = 1; % BROKEN for inverted plots, auto-disabled if invert = 1

frac_width_SqrtT_plot = 0;
invert_SqrtT_plot = 0; % makes vs. 1/sqrt(T)
addFitExponentsToLegends_SqrtTplot = 1;
markPointsNotUsedInFit_SqrtTplot = 1; % BROKEN for inverted plots, auto-disabled if invert = 1

zoom_inverse_plots = 1;

central_density_fig = 0;
inv_central_density_fig = 0;

center_location_fig = 0;
use_width_center = 1;
use_max_center = 0;

SD_width_fig = 0;
addFitExponentsToLegends_SDplot = 1;
markPointsNotUsedInFit_SDplot = 0; % BROKEN, keep = 0

%% Check stuff, fix stuff

if switch_to_transverse_X % plots summedODx
    addFitExponentsToLegends_loglogPlot = 0;
    addFitExponentsToLegends_Tplot = 0;
    addFitExponentsToLegends_SqrtTplot = 0;
end

if fig_folder(end) ~= '\' % fig_folder has to end with file delimiter
    fig_folder = [fig_folder, '\'];
end


%% Initialize cells

% I don't think I actually need these if I am not preallocating them at the
% correct size, but for superstitious purposes I am leaving them here.

lattice915 = cell(1);
maxval = cell(1);
centerPositions = cell(1);
Widths = cell(1);
subtractedWidths = cell(1);
fracWidths = cell(1);
thisCenterPositionsWidthCenter = cell(1);
width_exponents = cell(1);
SD_exponents = cell(1);
runNumber = cell(1);
pointsNotUsedInFit = cell(1);

%% Options for Averaging, Width Plotting

% how many pixels on either side of maximum we want to average over in
% order to obtain maximum value
radius = 3; 

widthFraction = 0.15; % where to define our width
endIndicesExcluded = 0; % number of end entries to ignore for exponential fit
startIndicesExcluded = 0; % exclude starting indices

% I think this should be off if using italian fit
fit_type = "Italian";
% fit_type = "Power";

subtractInitialWidthBeforeFitting = 0;
% 
% if fit_type == "Italian"
%     subtractInitialWidthBeforeFitting = 0;
% else
%% Average Same Lattice Depths
    
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
        if switch_to_transverse_X
            density_raw(ii,:) = ads(ii).summedODx;
        else
            density_raw(ii,:) = ads(ii).summedODy;
        end
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
    
    thisDate = strcat(...
        num2str(setsWithThisLatticeDepth{1}.Year),"-", ...
        num2str(setsWithThisLatticeDepth{1}.Month),"-", ...
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
    
    TitleRunSpecific{dataSet} =  strcat(thisDate,", Avg of Runs ",...
        runNumber{dataSet},fr_tag, ...
        ", 1064 Depth - ", num2str(this1064), " Er, ", ...
        " 915 Depth - ", num2str(this915), " Er");
    
    %% Evolution Figure
    
    if smooth_data
        for ii = 1:N
            density(ii,:) = movmean(density(ii,:),smooth_window_width);
        end
    end
    
    if density_expansion_fig
    
        offset = zeros(N,1);
        labels = strings(N,1);
        plotMe = [];

        figure(9*dataSet);

        for ii = 1:N
            if offset_expansion_fig
              offset(ii+1) = offset(ii) + max( density(ii,:) ) - min( density(ii,:) ) - 200;
            end
            
            plotMe(ii,:) = density(ii,:) + offset(ii);
        end

        clf;
        hold on
        for ii = 1:N
            x = 1:length(plotMe(ii,:));
            h = plot( pixel_to_um_convert * x, plotMe(ii,:) );
            h.LineWidth = 2;
            labels(ii) = convertCharsToStrings(num2str(holdtimes(ii)));
        end
        
%         plot(zeros( length(plotMe(1,:)),1 ),'Color','k','LineWidth',2);

        if  zoom_expansion
            ylim([-75 200]);
        else
            limShift = 150;
            ylim([min(min(plotMe)) - limShift,max(max(plotMe)) + limShift])
        end
            
        lgd = legend( labels , 'FontSize', fontsize/2, 'interpreter','latex');
        title(lgd,"Hold Time (ms)",'FontSize',fontsize/2);

        Title1 = "Transverse Sum of Optical Depth vs Lattice Hold Time";  
        title({Title1,TitleRunSpecific{dataSet}},'FontSize',titleFontSize,'interpreter','latex');
        ylabel('Density (a.u.)','FontSize',fontsize,'interpreter','latex');
        xlabel('Position ($\mu$m)','FontSize',fontsize,'interpreter','latex');

        save_figure(fig_folder,Title1,TitleRunSpecific{dataSet},save_figures);

        hold off
    
    end
    
    %% Setup Central Density Figure
    
    thisRunMaxSet = [];
    thisCenterPositions = [];
    
    for ii = 1:N
        [peakVal, peakIndex] = max(density(ii,:));
        window = [(peakIndex - radius):(peakIndex + radius)];
        thisCenterPositions(ii) = peakIndex;
        thisRunMaxSet(ii) = mean(density(ii, window),2);
    end
  
    centerPositions{dataSet} = thisCenterPositions;
    maxval{dataSet} = thisRunMaxSet;
    
    %% Setup Fractional Width Figure
    
    theseFracWidths = zeros(1,N);
    
    for ii = 1:N
        
        y = density(ii,:);
        x = pixel_to_um_convert * (1:length(y));
        
        [theseFracWidths(ii), theseCenters(ii)] = ...
            frac_width( x, y, widthFraction, 'CustomMax', thisRunMaxSet(ii));
    end
    
    centerPositionsWidthCenter{dataSet} = theseCenters;
    fracWidths{dataSet} = theseFracWidths / 2;
    
    %% Finding Widths From Density Distribution (rather than from atomdata)
    
    for p = 1:N
        [params, ~] = gauss_fit(X,density(p,:));
        ywidth_new(p) = params.c1;
        ycenter_new(p) = params.b1;
    end
    
    for p = 1:N
       moment_width(p) = sqrt( abs(trapz( X, X.^2 .* density(p,:) )) );
    end
    
    moment_widths{dataSet} = moment_width;
    ywidths_new{dataSet} = ywidth_new;
    ycenters_new{dataSet} = ycenter_new;
    
    %% Setup Kurtosis Fig
    
    sigma = zeros(1,N);
    thisKurt = [];
        
    for ii = 1:N

        x = X;
        y = density(ii,:);
        y = y / trapz( x, y );

%       b = trapz(x, x .* y);
        b = theseCenters(ii);

        sigma(ii) = trapz(x , ( (x - b).^2) .* y ) ^ 0.5;

        thisKurt(ii) = round( ...
            trapz( x, ((x - b) .^ 4) .* y ) / sigma(ii)^4 - 3, 5 );
            
    end
        
        kurtoses{dataSet} = thisKurt;
        int_sigmas{dataSet} = sigma;
    
    %% Atom Number Figure
    
    if atom_number_fig
        atomNum = zeros(N,1);

        for ii = 1:N
            atomNum(ii) = trapz(X, density(ii,:) );
        end

        h0 = plot(holdtimes/1000,atomNum,'o-','Color','k','MarkerSize',dotSize);
        h0.LineWidth = 2;

        Title1 = "Atom Number vs Lattice Hold Time";  
        title({Title1,TitleRunSpecific{dataSet}},'FontSize',titleFontSize,'interpreter','latex');
        ylabel('Atom Number (a.u.)','FontSize',fontsize,'interpreter','latex');
        xlabel('Hold Time (s)','FontSize',fontsize,'interpreter','latex');

        save_figure(fig_folder,Title1,TitleRunSpecific{dataSet},save_figures);
    end
    
    %% Oort Gif
    
    if oort_gif & save_figures
        
        figure(111);
    
        for kk = 1:length(holdtimes)
          smoothedprofile = movmean(density(kk,:),smooth_window_width_gif);
          
          h=plot(pixel_to_um_convert*X,smoothedprofile);
          h.LineWidth=2;
          
          set(gcf,'Position',[6 151 1365 1199]);

          set(gca,'FontSize',fontsize/2);
          xlabel('Position ($\mu \mathrm{m}$)','interpreter','latex','FontSize',fontsize);
          ylabel('Density (a.u.)','interpreter','latex','FontSize',fontsize);
          
          axis tight;
          
          legend(strcat(...
              "Hold Time: ", ...
              num2str(holdtimes(kk)/1000, '%.2f'),...
              " (s)"),'location','northwest',...
              'FontSize',fontsize*oort_timestamp_font_multiplier,...
              'interpreter','latex');
          
          set(gcf,'color','w');

            if zoom_oort
                ylim([-75 200]);
            else
                ylim([-75 max(max(density))])
            end
%           xlim([1 length(smoothedprofile)]);
          
          Title1 = "Oort Cloud GIF";  
          TitleTotal = {Title1,TitleRunSpecific{dataSet}};
          
          title(TitleTotal,'interpreter','latex','FontSize',titleFontSize);
          
          filename = strcat(fig_folder, Title1,", ", TitleRunSpecific{dataSet},".gif");
          
          frame = getframe(gcf);
          im = frame2im(frame);
          [A,map] = rgb2ind(im,256);   

             if kk == 1
              imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime',gif_frame_time);
            else
              imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',gif_frame_time);
             end

        end
        
    end
    
end

%% Generate General Titles

    for jj = 1:length(runNumber)
        if jj == 1
            allRunNumbers = strcat("(",runNumber{1},")");
        else
            allRunNumbers = strcat(allRunNumbers,", (",runNumber{jj},")");
        end
    end

    GeneralTitle =  strcat(thisDate,", Runs ", allRunNumbers,fr_tag,",", ...
        " 1064 Depth - ", num2str(this1064), " Er");

%% Compute Width Exponents

if ~switch_to_transverse_X

    for dataSet = sets

            thisWidth = fracWidths{dataSet};
            thisX = holdtimes/1000;

            if subtractInitialWidthBeforeFitting
                thisWidth = thisWidth - thisWidth(1);
            end
            
            [thisFit, ~, pointsNotUsedInFit{dataSet}] = ... 
                expfit(thisX, thisWidth, endIndicesExcluded, startIndicesExcluded,...
                "FitType",fit_type);
            fracFit{dataSet} = thisFit;
            width_exponents{dataSet} = round(thisFit.b,2);
            
            thisItalianWidth = int_sigmas{dataSet};
            
            [thisItalianFit,~,~] = ...
                expfit(thisX, thisItalianWidth, endIndicesExcluded, startIndicesExcluded,...
                "FitType",fit_type);
            int_width_exponents{dataSet} = round(thisFit.b,2);

    end

end
    
%% plotting the figures which depend on all runs

%% log ( SD - initialSD )

if SD_width_fig

    labels = [];

%     H2 = figure(2);

    SD_exponents = [];

    for dataSet = sets 
        
        thisX = holdtimes/1000;
        thisWidth = ywidths_new{dataSet};
        if subtractInitialWidthBeforeFitting
            thisWidth = thisWidth - thisWidth(1);
        end

        h2 = loglog(thisX, thisWidth ,'o-');
        h2.LineWidth=2;
        h2.MarkerSize = dotSize;
        
        [thisFit, thisGOF] = expfit(thisX', thisWidth, endIndicesExcluded, startIndicesExcluded);
        SD_exponents{dataSet} = round(thisFit.b,3);
        
        hold on
        
        if addFitExponentsToLegends_SDplot 
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$, ","exp = ",...
                num2str(SD_exponents{dataSet}) )];
            if markPointsNotUsedInFit_SDplot 
                excludedY = thisWidth(pointsNotUsedInFit{dataSet});
                excludedX = thisX(pointsNotUsedInFit{dataSet});
                plot(excludedX,excludedY,'rX','HandleVisibility','off','MarkerSize',round(dotSize*markerXSizeMultiplier),'LineWidth',2);
            end
        else
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$")];
        end

        ylabel('$\log(\mathrm{CloudSD} - \mathrm{InitialSD})$','FontSize',fontsize,'interpreter','latex');
        xlabel('$\log(\mathrm{Hold \ Time})$ (s)','FontSize',fontsize,'interpreter','latex');

    end

    hold on

    plot(thisX, 3*(thisX).^0.5,'--','Color','k');
    labels = [labels, "Slope = 0.5"];

    plot(thisX, 24*(thisX).^1,'--','Color','b');
    labels = [labels, "Slope = 1"];

    legend(labels,'FontSize',fontsize,'Location','northwest','interpreter','latex')

    hold off

    if subtractInitialWidthBeforeFitting
        Title1 = "Log(CloudSD - InitialSD) vs Log(Hold Time)";
    else
        Title1 = "Log(CloudSD) vs Log(Hold Time)";
    end
    
    title({Title1,GeneralTitle},'FontSize',titleFontSize,'interpreter','latex');

    save_figure(fig_folder,Title1,GeneralTitle,save_figures);
    
end

%% Fractional Widths LogLog Plot

if frac_width_log_fig

    labels = [];

    hold off

    H5 = figure(5);
    
    colors = colormap(lines( length(sets) ));

    for dataSet = sets

        thisWidth = fracWidths{dataSet};
        thisX = holdtimes/1000;
        if subtractInitialWidthBeforeFitting
            thisWidth = thisWidth - thisWidth(1);
        end

        h1 = loglog(thisX, thisWidth ,'o-','Color',colors(dataSet,:));
        h1.LineWidth=2;
        h1.MarkerSize = dotSize;
        
        hold on
        
        if addFitExponentsToLegends_loglogPlot
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$, ","$\alpha$ = ",...
                num2str(width_exponents{dataSet},'%.2f') )];
            if markPointsNotUsedInFit_loglogPlot 
                excludedY = thisWidth(pointsNotUsedInFit{dataSet});
                excludedX = thisX(pointsNotUsedInFit{dataSet});
                plot(excludedX,excludedY,'rX','HandleVisibility','off','MarkerSize',round(dotSize*markerXSizeMultiplier),'LineWidth',2);
            end
        else
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$")];
        end
        
        if plot_frac_fit
            smooth_x = thisX(1):0.001:thisX(end);
            thisFit = fracFit{dataSet}
            plot(smooth_x,thisFit(smooth_x),'HandleVisibility','off','Color',colors(dataSet,:),...
                'LineWidth',1.5)
        end

        if subtractInitialWidthBeforeFitting
            ylabel(strcat("$\log(",num2str(widthFraction),"*\mathrm{Max \ Fractional \ Width} - \mathrm{Initial \ Width})$"),'FontSize',fontsize,'interpreter','latex');
        else
            ylabel(strcat("$\log(",num2str(widthFraction),"*\mathrm{Max \ Fractional \ Width \ }) \ (\mu \mathrm{m})$"),'FontSize',fontsize,'interpreter','latex');
        end
        
        xlabel('$\log(\mathrm{Hold \ Time})$ (s)','FontSize',fontsize,'interpreter','latex');

    end
    
    leg = legend(labels);

    hold on

    if fit_type ~= "Italian"
        if ~subtractInitialWidthBeforeFitting
            logOffset1 = 45;
            logOffset2 = 100;
        else
            logOffset1 = 3;
            logOffset2 = 24;
        end

        plot(thisX, logOffset1*(thisX).^0.5,'--','Color','k');
        labels = [labels, "Slope = 0.5"];
        
        legtitle = get(leg,'Title');
        set(legtitle,'String',"Fit: $\sigma(t) propto t^\alpha$");

    %     plot(thisX, logOffset2*(thisX).^1,'--','Color','b');
    %     labels = [labels, "Slope = 1"];
    else
        
        legtitle = get(leg,'Title');
        set(legtitle,'String',"Fit: $\sigma_0(1 + t/t_0)^\alpha$");
    
    end

    legend(labels,'FontSize',fontsize,'Location','northwest','interpreter','latex')
    
    hold off

    if subtractInitialWidthBeforeFitting
        Title1 = strcat("Log(FW at ",num2str(widthFraction),"Max - Initial Width) vs Log(Hold Time)");
    else
        Title1 = strcat("Log(FW at ",num2str(widthFraction),"Max) vs Log(Hold Time)");
    end
    
    title({Title1,GeneralTitle},'FontSize',titleFontSize,'interpreter','latex');

    save_figure(fig_folder,Title1,GeneralTitle,save_figures);
    
end

%% sigma from integral plot

if int_sigmas_plot

    labels = [];

    hold off

    H5 = figure(891);

    for dataSet = sets

        thisWidth = int_sigmas{dataSet};
        thisX = holdtimes/1000;
        if subtractInitialWidthBeforeFitting
            thisWidth = thisWidth - thisWidth(1);
        end

        h1 = loglog(thisX, thisWidth ,'o-');
        h1.LineWidth=2;
        h1.MarkerSize = dotSize;
        
        hold on
        
        if addFitExponentsToLegends_loglogPlot
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$, ","exp = ",...
                num2str(int_width_exponents{dataSet},'%.2f') )];
            if markPointsNotUsedInFit_loglogPlot 
                excludedY = thisWidth(pointsNotUsedInFit{dataSet});
                excludedX = thisX(pointsNotUsedInFit{dataSet});
                plot(excludedX,excludedY,'rX','HandleVisibility','off','MarkerSize',round(dotSize*markerXSizeMultiplier),'LineWidth',2);
            end
        else
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$")];
        end
        
        if subtractInitialWidthBeforeFitting
            ylabel(strcat("$\log( \sigma - \sigma_0 )$"),'FontSize',fontsize,'interpreter','latex');
        else
            ylabel(strcat("$\log( \sigma )$"),'FontSize',fontsize,'interpreter','latex');
        end
        
        xlabel('$\log(\mathrm{Hold \ Time})$ (s)','FontSize',fontsize,'interpreter','latex');

    end

    hold on

    plot(thisX, 3*(thisX).^0.5,'--','Color','k');
    labels = [labels, "Slope = 0.5"];

    plot(thisX, 24*(thisX).^1,'--','Color','b');
    labels = [labels, "Slope = 1"];

    legend(labels,'FontSize',fontsize,'Location','northwest','interpreter','latex')

    hold off

    if subtractInitialWidthBeforeFitting
        Title1 = strcat("Log(2nd Moment Width - Initial Width) vs Log(Hold Time)");
    else
        Title1 = strcat("Log(2nd Moment Width) vs Log(Hold Time)");
    end
        
    title({Title1,GeneralTitle},'FontSize',titleFontSize,'interpreter','latex');

    save_figure(fig_folder,Title1,GeneralTitle,save_figures);
    
end

%% fractional widths vs t (or 1/t)

if frac_width_T_plot

    labels = [];

    hold off
    
    figure(66)

    for dataSet = sets
        
        
        thisWidth = fracWidths{dataSet};
        thisX = holdtimes/1000;

        if invert_T_plot
            remove = excludedata(thisX,thisWidth,'domain',[-Inf,0]);
            if subtractInitialWidthBeforeFitting
                thisWidthFiltered = thisWidth - thisWidth(1);
            end
            thisWidthFiltered = thisWidth(remove);
            thisXfiltered = thisX(remove);
            thisXfiltered = 1./thisXfiltered;
        else
            thisXfiltered = thisX;
            if subtractInitialWidthBeforeFitting
                thisWidthFiltered = thisWidth - thisWidth(1);
            else
                thisWidthFiltered = thisWidth;
            end
        end

        h1 = plot( thisXfiltered, thisWidthFiltered ,'o-');
        h1.LineWidth=2;
        h1.MarkerSize = dotSize;
        
        hold on
        
        if addFitExponentsToLegends_Tplot 
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$, ","exp = ",...
                num2str(width_exponents{dataSet},'%.2f') )];
            if markPointsNotUsedInFit_Tplot & ~invert_T_plot
                excludedY = thisWidthFiltered(pointsNotUsedInFit{dataSet});
                excludedX = thisX(pointsNotUsedInFit{dataSet});
                plot(excludedX,excludedY,'rX','HandleVisibility','off','MarkerSize',round(dotSize*markerXSizeMultiplier),'LineWidth',2);
            end
%               BROKEN, not worth fixing rn. Excluded X and Excluded Y have
%               to be recomputed with possible square roots inversions
        else
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$")];
        end
        
        if subtractInitialWidthBeforeFitting
            ylabel(strcat( num2str(widthFraction),"$*\mathrm{Max \ Fractional \ Width} - \mathrm{Initial \ Width}$" ),'FontSize',fontsize,'interpreter','latex');
        else
            ylabel(strcat( num2str(widthFraction),"$*\mathrm{Max \ Fractional \ Width}$" ),'FontSize',fontsize,'interpreter','latex');
        end
        
        if invert_T_plot
            xlabel('Inverse Hold Time (1/s)','FontSize',fontsize,'interpreter','latex');
        else
            xlabel('Hold Time (s)','FontSize',fontsize,'interpreter','latex');
        end
        
    end

    hold on

    leg1 = legend(labels,'FontSize',fontsize,'Location','northwest','interpreter','latex');

    hold off

    if invert_T_plot
        modifier = " Inverse";
        leg1.Location = 'northeast';
        if zoom_inverse_plots
            xlim([0,3.5])
        end
    else
        modifier = "";
    end
    
    if subtractInitialWidthBeforeFitting
        Title1 = strcat("(FW ",num2str(widthFraction),"Max - Initial Width) vs",modifier," Hold Time");
    else
        Title1 = strcat("(FW ",num2str(widthFraction),"Max) vs",modifier," Hold Time");
    end
    
    title({Title1,GeneralTitle},'FontSize',titleFontSize,'interpreter','latex');

    save_figure(fig_folder,Title1,GeneralTitle,save_figures);
    
end

%% fractional widths vs sqrt(t) (or 1/sqrt(t))

if frac_width_SqrtT_plot

    labels = [];

    hold off
    
    figure(65)

    for dataSet = sets

        thisWidth = fracWidths{dataSet};
        thisX = holdtimes/1000;

        if invert_T_plot
            remove = excludedata(thisX,thisWidth,'domain',[-Inf,0]);
            if subtractInitialWidthBeforeFitting
                thisWidthFiltered = thisWidth - thisWidth(1);
            end
            thisWidthFiltered = thisWidth(remove);
            thisXfiltered = thisX(remove);
            thisXfiltered = 1./sqrt(thisXfiltered);
        else
            thisXfiltered = sqrt(thisX);
            if subtractInitialWidthBeforeFitting
                thisWidthFiltered = thisWidth - thisWidth(1);
            end
        end

        h1 = plot( thisXfiltered, thisWidthFiltered ,'o-');
        h1.LineWidth=2;
        h1.MarkerSize = dotSize;
        
        hold on
        
        if addFitExponentsToLegends_SqrtTplot
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$, ","exp = ",...
                num2str(width_exponents{dataSet},'%.2f') )];
            if markPointsNotUsedInFit_SqrtTplot & ~invert_SqrtT_plot
                excludedY = thisWidthFiltered(pointsNotUsedInFit{dataSet});
                excludedX = thisXfiltered(pointsNotUsedInFit{dataSet});
                plot(excludedX,excludedY,'rX','HandleVisibility','off','MarkerSize',round(dotSize*markerXSizeMultiplier),'LineWidth',2);
            end
%               BROKEN, not worth fixing rn. Excluded X and Excluded Y have
%               to be recomputed with possible square roots inversions
        else
            labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$")];
        end
        
        if subtractInitialWidthBeforeFitting
            ylabel(strcat( num2str(widthFraction),"$*\mathrm{Max \ Fractional \ Width} - \mathrm{Initial \ Width}$" ),'FontSize',fontsize,'interpreter','latex');
        else
            ylabel(strcat( num2str(widthFraction),"$*\mathrm{Max \ Fractional \ Width}$" ),'FontSize',fontsize,'interpreter','latex');
        end
        
        if invert_SqrtT_plot
            xlabel('Inverse Root Hold Time (1/$\sqrt{s}$)','FontSize',fontsize,'interpreter','latex');
        else
            xlabel('Root Hold Time ($\sqrt{s}$)','FontSize',fontsize,'interpreter','latex');
        end
        
    end

    hold on

    leg2 = legend(labels,'FontSize',fontsize,'Location','northwest','interpreter','latex');

    hold off
    
    if invert_SqrtT_plot
        modifier = " Inverse";
        leg2.Location = 'northeast';
        if zoom_inverse_plots
            xlim([0,3.5])
        end
    else
        modifier = "";
    end
    
    if subtractInitialWidthBeforeFitting
        Title1 = strcat("(FW ",num2str(widthFraction),"Max - Initial Width) vs",modifier," Root Hold Time");
    else
        Title1 = strcat("(FW ",num2str(widthFraction),"Max) vs",modifier," Root Hold Time");
    end
    
    title({Title1,GeneralTitle},'FontSize',titleFontSize,'interpreter','latex');

    save_figure(fig_folder,Title1,GeneralTitle,save_figures);
    
end

%% Kurtosis Plot

if kurtosis_fig
   
    labels = [];

    hold off

    H5 = figure(5);

    for dataSet = sets

        thisKurt = kurtoses{dataSet};
        thisX = holdtimes/1000;
        
        h3 = semilogx(thisX, thisKurt ,'o-');
        h3.LineWidth = 2;
        h3.MarkerSize = dotSize;

        hold on

        labels = [labels, strcat("915: ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$")];

    end

    ylabel('Kurtosis','FontSize',fontsize,'interpreter','latex');
    xlabel('$\log(\mathrm{Hold \ Time})$ (s)','FontSize',fontsize,'interpreter','latex');

    hold on

    plot(thisX, 0 ,'--','Color','k');
    labels = [labels, "Gaussian"];

    legend(labels,'FontSize',fontsize,'Location','northwest','interpreter','latex')

    hold off

    Title1 = strcat("Kurtosis vs log(Hold Time)");
    title({Title1,GeneralTitle},'FontSize',titleFontSize,'interpreter','latex');

    save_figure(fig_folder,Title1,GeneralTitle,save_figures);
    
end

%% Central Density Figure

if central_density_fig

    labels = [];
    figure(4);

    hold off

    for dataSet = sets

        h = plot(holdtimes/1000, maxval{dataSet} ,'o-','MarkerSize',dotSize);
        h.LineWidth=2;

        labels = [labels, strcat("915 ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$")]; 

        hold on

    end

    ylabel('Central Density (a.u.)','FontSize',fontsize,'interpreter','latex');
    xlabel('Hold Time (s)','FontSize',fontsize,'interpreter','latex');

    legend(labels,'FontSize',fontsize,'interpreter','latex')

    Title1 = "Central Density vs Lattice Hold Time";
    title({Title1,GeneralTitle},'FontSize',titleFontSize,'interpreter','latex');

    save_figure(fig_folder,Title1,GeneralTitle,save_figures);
    
end

%% Inverse Central Density Figure

if inv_central_density_fig

    labels = [];
    figure(6);

    hold off

    for dataSet = sets

        h = plot(sqrt(holdtimes/1000), 1./maxval{dataSet} ,'o-','MarkerSize',dotSize);
        h.LineWidth=2;

        labels = [labels, strcat("915 ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$")]; 

        hold on

    end

    ylabel('Inverse Central Density (a.u.)','FontSize',fontsize,'interpreter','latex');
    xlabel('Root Time (s)','FontSize',fontsize,'interpreter','latex');

    legend(labels,'FontSize',fontsize,'Location','northwest','interpreter','latex');

    Title1 = "Inverse Central Density vs Sqrt(Hold Time)";
    title({Title1,GeneralTitle},'FontSize',titleFontSize,'interpreter','latex');

    save_figure(fig_folder,Title1,GeneralTitle,save_figures);
    
end

%% center position figure

if center_location_fig
   
    labels = [];
    
    figure(100);
    
    for dataSet = sets

        if (~use_width_center & ~use_max_center) | (use_width_center & use_max_center)
            thisYY = centerPositionsWidthCenter{dataSet} + 3*dataSet;
            modifier2 = " (Extracted from Fractional Edges)";
            if dataSet == 1
                disp("Both options unselected or both options selected -- make up your mind. Plotting for center extracted from the widths.");
            end
        elseif use_width_center
            thisYY = centerPositionsWidthCenter{dataSet} + 3*dataSet;
            modifier2 = " (Extracted from Fractional Edges)";
        elseif use_max_center
            thisYY = centerPositions{dataSet} + 3*dataSet;
            modifier2 = " (Location of Maximum)";
        end
        
        h11 = plot( holdtimes/1000, thisYY,'o-','MarkerSize',round(dotSize/2));
        h11.LineWidth=2;
        xlim([-1,21])

        labels = [labels, strcat("915 ", num2str(lattice915{dataSet}), " $\mathrm{E}_\mathrm{r}$")];
        
        hold on
    end
    
    ylabel('Center Position (pixels, arb. origin)','FontSize',fontsize);
    xlabel('Hold Time (s)','FontSize',fontsize);
%     set(gca,'ytick',[])

    leg = legend(labels,'FontSize',fontsize,'Location','northwest','interpreter','latex');
%     dataSet(leg,'Location',[0.6825    0.6150    0.1890    0.1293]);

    Title1 = strcat("Peak Position",modifier2," vs. Hold Time");
    title({Title1,GeneralTitle},'FontSize',titleFontSize,'interpreter','latex');

    save_figure(fig_folder,Title1,GeneralTitle,save_figures);
    
end

%% Closing Figures

if close_figs_after_keypress
    pause;
    close all
end
    
%% functions

function save_figure(fig_folder,Title1,Title2,save_figures)
    set(gcf,'Position',[6         151        1365        1199]);
    filename = strcat(fig_folder, Title1,", ", Title2,".png");
    if save_figures
        saveas(gcf,filename);
    end
end

function [fitresult, gof, excludedPoints] = expfit(x, y, endIndicesExcluded, startIndicesExcluded, options)
% EXPFIT fits data to a*x^b + c.

arguments
    x
    y
    endIndicesExcluded
    startIndicesExcluded
end
arguments
    options.FitType string = "Power"
end

fit_type = options.FitType;

% Fit: 'untitled fit 1'.
[xData, yData] = prepareCurveData( x, y );

% Set up fittype and options.
lastIndex = length(yData);

if fit_type == "Italian"
    ft = fittype( 'sigma0 * (1 + x/t0)^b' , 'independent', 'x', 'dependent', 'y' );
    disp("Using Italian Fit")
else
    ft = fittype( 'a*x^b + c', 'independent', 'x', 'dependent', 'y' );  
    disp("Using Power Law Fit")
end

excludedPoints = excludedata( xData, yData, 'range', [0,Inf]);

if startIndicesExcluded == 0
    exclStartIndices = [];
else
    exclStartIndices = 1:(startIndicesExcluded);
end

excludedPoints = excludedPoints | excludedata( xData, yData, 'indices', exclStartIndices);

exclEndInidices = (lastIndex - endIndicesExcluded + 1):lastIndex;
excludedPoints = excludedPoints | excludedata( xData, yData, 'indices', exclEndInidices);

opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.Robust = 'BiSquare';
opts.Lower = [0 0 0];
opts.Upper = [Inf Inf Inf];
opts.StartPoint = [0.5 10 1];
opts.Exclude = excludedPoints;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );
end