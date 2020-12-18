function [density, varied_var_values, ywidths]  = avgRepeats(RunDatas, varied_variable_name)
% AVG_REPEATS averages the repeats over the provided RunDatas.Atomdata
% Provide the varied_variable_name as a string corresponding to a variable
% in RunDatas.Atomdata.vars.(varied_variable_name).

    density_raw = [];
    ywidths_raw = [];
    varied_var_raw = [];
    
    if class(RunDatas) == "cell"
        ads = [];
        for ii = 1:length(RunDatas)
            ads = [ads; RunDatas{ii}.Atomdata];
        end
    else
        ads = RunDatas.Atomdata;
    end
    
    if isa(ads(1).vars.(varied_variable_name),'datetime')
        varied_var_raw = datetime.empty;
    end
    
    for ii=1:length(ads)
        varied_var_raw(ii) = ads(ii).vars.(varied_variable_name);
        ywidths_raw(ii) = ads(ii).cloudSD_y;
        xwidths_raw(ii) = ads(ii).cloudSD_x;
        density_raw(ii,:) = ads(ii).summedODy;
    end
    
    [varied_var_raw, inds] = sort(varied_var_raw);
    ywidths_raw = ywidths_raw(inds);
    xwidths_raw = xwidths_raw(inds);
    density_raw = density_raw(inds,:);
    
    [varied_var_values,~,idx] = unique(varied_var_raw);
    N = length(varied_var_values);
    
    ywidths = accumarray(idx, ywidths_raw, [], @mean);
    xwidths = accumarray(idx, xwidths_raw, [], @mean);

    density = [];
    
    % Averages profiles with same holdtime together, returns averaged
    % density
    for ii = 1:N
        this_varvar = varied_var_values(ii);
        thisprofile = density_raw(varied_var_raw == this_varvar,:); 
        % grabs only the row(s) of profile_A with holdtimeA == thishold
        thisprofile = mean(thisprofile,1); 
        density = [density; thisprofile]; 
        % vertical appends thisprofile to profile_A_avg
    end
end