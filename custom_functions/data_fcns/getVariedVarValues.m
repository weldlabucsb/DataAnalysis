function varied_var_values = getVariedVarValues(RunDatas,varied_var_name)
% GETHELDVARVALUES takes in a SINGLE RunData (or just one RunData)
% and returns a vector of the varied variable values for that run. Obtained
% by repeat-averaging, so that they appear in the same order as returned by
% avgRepeats(RunData,...).

    RunDatas = cellWrap(RunDatas);
    
    run_date_list = runDateList(RunDatas); % in case needed for error message

    whereThisVarLives = findVarField(RunDatas, varied_var_name);
    
    if whereThisVarLives == "runDataVars" || whereThisVarLives == "atomdataVars"
        
        avg_ad = avgRepeats(RunDatas,varied_var_name,varied_var_name);
        varied_var_values = [avg_ad.(varied_var_name)];
        
    elseif whereThisVarLives == "ncVars"
        
        for ii = 1:numel(RunDatas)
            varied_var_values{ii} = RunDatas{ii}.ncVars.(varied_var_name);
            if ii > 1
                cond = ~all( varied_var_values{ii-1} == varied_var_values{ii} );
                assert(cond,strcat("The repeat-avg'd ",run_date_list," don't have the same set of varied_var_values."));
            end
        end
        varied_var_values = varied_var_values{1};
    end
    
end