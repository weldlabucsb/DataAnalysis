function run_labeled_title = runDateList(RunDatas)
% RUNSLABELEDTITLE outputs a title of the format specified

if class(RunDatas) == "cell"
    dates = string( cellfun(@(x) strcat( num2str(x.Month), ".", num2str(x.Day) ), RunDatas, 'UniformOutput', 0) );
    runNumbers = string( cellfun(@(x) x.RunNumber, RunDatas, 'UniformOutput', 0) );
elseif class(RunDatas) == "RunData"
    dates = strcat( num2str(RunDatas.Month), ".", num2str(RunDatas.Day));
    runNumbers = string( RunDatas.RunNumber );
end

[theUniqueDates, dateIdx] = unique(dates);
N = length(theUniqueDates);

for ii = 1:N
    if ii ~= N
        thisDateIdx = dateIdx(ii):( dateIdx(ii + 1) );
    else
        thisDateIdx = dateIdx(ii):length(dates);
    end
    thisDateRunNums = runNumbers(thisDateIdx);
    
    dateNumTitle(ii) = strcat( theUniqueDates(ii), " - ", strjoin(thisDateRunNums) );
end

if length(runNumbers) == 1
    pluraltag = " ";
else
    pluraltag = "s ";
end

run_labeled_title = strcat("Run", pluraltag, strjoin(dateNumTitle,", "));

end