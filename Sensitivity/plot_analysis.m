function plot_analysis(file_names, legend_labels, analysis_title)
    % A flexible script to plot and compare the results of multiple training runs.
    
    if nargin < 3; analysis_title = 'Agent Performance Analysis'; end
    if nargin < 2; error('Please provide legend labels for the plots.'); end
    if nargin < 1; error('Please provide a cell array of file names to load.'); end

    fprintf('Generating analysis plot: %s\n', analysis_title);
    
    % --- CHANGE: Increased smoothing window for a clearer trend line ---
    smoothingWindow = 1000;
    
    resultsFolder = fullfile('Sensitivity', 'Sensitivity Results');
    
    figure('Name', analysis_title, 'NumberTitle', 'off');
    hold on;
    colors = lines(length(file_names));

    for i = 1:length(file_names)
        fullFilePath = fullfile(resultsFolder, file_names{i});
        try
            data = load(fullFilePath, 'episodeRewards');
        catch e
            warning('Could not load file: %s. Skipping. Error: %s', fullFilePath, e.message);
            continue;
        end
        
        plot(movmean(data.episodeRewards, smoothingWindow), ...
             'LineWidth', 2, ...
             'DisplayName', legend_labels{i}, ...
             'Color', colors(i,:));
    end
    
    hold off;
    title(analysis_title);
    xlabel('Episode');
    ylabel(sprintf('Total Reward (%d-Episode Moving Average)', smoothingWindow));
    legend('Location', 'southeast');
    grid on;
    set(gca, 'FontSize', 12);
    fprintf('Plot generated successfully.\n');
end