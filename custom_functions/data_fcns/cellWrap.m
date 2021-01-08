function RunDatas = cellWrap(RunDatas)
% CELLWRAP puts a lone RunData object in a cell if it is alone, returning
% {RunDatas}. Otherwise, does nothing.
%
% This silly function exists because all most of my functions work on a
% cell array of RunDatas.

    if ~rdclass(RunDatas)
        RunDatas = {RunDatas};
    end
    
end