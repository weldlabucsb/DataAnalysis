function held_var_values = getHeldVarValues(RunDatas,held_var_name)
% GETHELDVARVALUES takes in a cell array of RunDatas (or just one RunData)
% and returns a vector of the held variable value for each RunData.
%
% Throws an error if the variable wasn't held constant within each run.

    RunDatas = cellWrap(RunDatas);

    whereThisVarLives = findVarField(RunDatas, held_var_name);
    
    if whereThisVarLives == "runDataVars"
        held_var_values = ...
            cellfun( @(rdcells) rdcells.vars.(held_var_name), RunDatas);
    elseif whereThisVarLives == "atomdataVars"
        held_var_values = ...
            cellfun( @(rdcells) ...
            unique( arrayfun( @(ad) ad.vars.(held_var_name), rdcells.Atomdata)),...
            RunDatas, 'UniformOutput', false);
        held_var_values = cell2mat(held_var_values);
        if numel( held_var_values ) ~= numel(RunDatas)
           error(strcat("Looks like ", held_var_name," was not constant within each Atomdata.")); 
        end
    elseif whereThisVarLives == "ncVars"
        held_var_values = ...
            cellfun( @(rdcells) rdcells.ncVars.(held_var_name), RunDatas);
    end
    
end