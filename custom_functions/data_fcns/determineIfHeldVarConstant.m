function [trueIfConstant, held_var_value] = determineIfHeldVarConstant(RunDatas,held_var_name)

    class_flag = rdclass(RunDatas);
    if class_flag
        held_var_values = ...
            cellfun( @(rdcells) unique( arrayfun( @(ad) ad.vars.(held_var_name), rdcells.Atomdata)), RunDatas, 'UniformOutput', false);
        held_var_values = unique(cell2mat(held_var_values));
    else
        held_var_values = ...
            unique( arrayfun( @(ad) ad.vars.(held_var_name), RunDatas.Atomdata));
    end
    
    trueIfConstant = (length(held_var_values) == 1);
    
    if trueIfConstant
        held_var_value = held_var_values;
    else
        disp( strcat( held_var_name, " is not constant across the input RunDatas."));
        return;
    end
    
end