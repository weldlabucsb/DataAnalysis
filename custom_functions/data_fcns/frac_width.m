function [width, center, peakLeftEdge, peakRightEdge] = frac_width(x,y,widthFraction,options)

    arguments
        x 
        y 
        widthFraction (1,1) double
    end
    arguments
        options.CustomMax = max(y)
    end

    peakValue = options.CustomMax - min(y);

    thisFracWidthHeight = peakValue * widthFraction + min(y);

    [~,knownIndex] = max(y);

    aboveFracWidthHeight = y > thisFracWidthHeight;

    logic = logical(aboveFracWidthHeight);

    edges = diff(logic);
    leftedges = find(edges == 1) + 1;
    rightedges = find(edges == -1);

    edgevals = edges(edges ~= 0);

    if edgevals(1) == -1
        leftedges = [1; leftedges];
    end

    if edgevals(end) == 1
        rightedges = [rightedges; length(logic)];
    end

    for n = 1:length(leftedges)
        blockN = [leftedges(n):rightedges(n)];
        if sum( blockN == knownIndex ) == 1
            peakLeftEdge = x( blockN(1) );
            peakRightEdge = x( blockN(end));
        end
    end

    center = (peakLeftEdge + peakRightEdge)/2;
    width = peakRightEdge - peakLeftEdge;
    
    
end