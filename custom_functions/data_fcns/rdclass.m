function trueIfCell = rdclass(RunData)
% Returns true if input is a cell of RunDatas, false if the input is a
% RunData.

if class(RunData) == "cell"
    if class(RunData{1}) == "RunData"
        trueIfCell = 1;
    else
        fuck_you();
    end
elseif class(RunData) == "RunData"
    trueIfCell = 0;
else
    
    return;
end

    function fuck_you()
        disp('What the hell is this shit, it is not a RunData or a cell of RunDatas.');
    end

end