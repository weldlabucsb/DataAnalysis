function saveFigure(figure_handle, filename, varargin)
% SAVE_FIGURE saves the figure specified by figure_handle to the location
% specified by filename. If a third argument is provided, it is treated as
% the directory to which the figure should be saved.

if ~isfolder( varargin{1} )
    disp(strcat(...
        "Output folder at ",varargin{1}, " does not exist. Creating directory."));
    mkdir(varargin{1});
end

% shove things into cells if they aren't already to make the loop work.
if class(filename) ~= "cell"
    filename = {filename};
end
if class(figure_handle) ~= "cell"
    figure_handle = {figure_handle};
end

N_figures = length(filename);
% loop over the figures and save them all
for j = 1:N_figures
    
    disp(strcat("Saving ", num2str(j), "/", num2str(N_figures) ," figures."));
    
    % if output folder is specified, change filename to include it
    if ~isempty(varargin)
        filename{j} = fullfile( varargin{1}, filename{j} );
    end
    
    saveas( figure_handle{j}, filename{j} );
end

end