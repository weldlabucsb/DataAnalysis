function [fitresult, gof] = gauss_fit_2(x, y, options)
%CREATEFIT(X,Y)
%  Create a fit.
%
%  Data for 'untitled fit 1' fit:
%      X Input : x
%      Y Output: y
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.

%  Auto-generated by MATLAB on 13-Jun-2020 20:12:11
    arguments
        x double
        y double
    end
    arguments
        options.PlotFit logical = 0
        options.LineWidth double = 1
        options.Color (1,3) double = [0 0 1]
    end

    plotFit = options.PlotFit;

    %% Fit: 'untitled fit 1'.
    [xData, yData] = prepareCurveData( x, y );
    
    ampGuess = max(y);
    offsetGuess = min(y);
    [sigmaGuess, centerGuess] = frac_width(x,y,0.5);

    % Set up fittype and options.
    ft = fittype( 'a1 * exp( - (x - b1)^2/(2*sigma1^2) ) + c1', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
    opts.Display = 'Off';
    opts.Lower = [0 -Inf -Inf -Inf];
    opts.StartPoint = [ampGuess centerGuess offsetGuess sigmaGuess];
    opts.Upper = [10000 250 Inf Inf];

    % Fit model to data.
    [fitresult, gof] = fit( xData, yData, ft, opts );

    % Plot fit with data.
    if plotFit
        hold on
        yy = fitresult(x);
        plot( x, yy , '-.','Color',options.Color,'LineWidth', options.LineWidth);
        hold off
    end

end


