function output = cellmean(cellIn)
% CELLMEAN averages the vectors contained in the input cell. If their size
% does not match, returns an error.

    cellD = numel( size(cellIn) );

    dataAsNumericArray = cat(cellD + 1, cellIn{:});
    output = mean( dataAsNumericArray, cellD+1 );

end