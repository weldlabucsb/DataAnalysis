function [trueIfConstant, held_var_value] = determineIfHeldVarConstant(RunDatas,held_var_name)

    held_var_values = getHeldVarValues(RunDatas,held_var_name);
    held_var_values = unique(held_var_values);
    
    trueIfConstant = (length(held_var_values) == 1);
    
    if trueIfConstant
        held_var_value = held_var_values;
    else
        disp( strcat( held_var_name, " is not constant across the input RunDatas."));
        return;
    end
    
end