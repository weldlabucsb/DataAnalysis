function RunDatas = cellWrap(RunDatas)
% CELLWRAP puts a lone RunData object in a cell if it is alone, returning
% {RunDatas}. Otherwise, does nothing.
%
% This silly function exists because all most of my functions work on a
% cell array of RunDatas.

    class_flag = rdclass(RunDatas);
    if ~class_flag
        RunDatas = {RunDatas};
    end
    
end