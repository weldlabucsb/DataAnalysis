function aliasCell = varAlias(vars)
% VARALIAS takes in a list of cicero variable names as a cell array of
% strings, and outputs a list of corresponding names which look a bit
% nicer when placed in plot titles, legends, etc. Update here as you find
% more that you want to swap out.

    arguments
        vars cell
    end
    
    aliasCell = vars;
    
    for k = 1:length(vars)
        if vars{k} == "VVA915_Er"
            aliasCell{k} = '915';
        end
        
        if vars{k} == "VVA1064_Er"
            aliasCell{k} = '1064';
        end
        
        if vars{k} == "PiezoModFreq"
           aliasCell{k} = 'PiezoFreq';
        end
        
    end
    
end