function [varied_var, heldvars_each, heldvars_all, legendvars_each, legendvars_all] = unpackRunVars(RunVars)
% UNPACKRUNVARS takes in the RunVars struct output by selectRuns, and
% returns the list of variables you'll need to specify the
% varied_variable_name, legendvars, and heldvars for your plots.
%
% Sets legendvars_each = varied_var, legendvars_all = heldvars_each.

varied_var = RunVars.varied_var;
heldvars_each = RunVars.heldvars_each;
heldvars_all = RunVars.heldvars_all;

% For individual plots of many traces within a single run, I typically want
% to label legend with the varied variable value for each trace.
%
% Example: in stackedExpansionPlot of a time series with fixed 1064 & 915,
% I want the legend labeled with the varying variable (LatticeHold) value
% on each trace.
legendvars_each = varied_var;

% For plots which contain traces derived from all the runs, label legend
% with the variables held constant in each run.
% 
% Example: For plotting the widths of a set of time series runs for
% different 1064 or 915, I want each trace labeled by the 1064 and 915
% values of each run.
legendvars_all = heldvars_each;

end