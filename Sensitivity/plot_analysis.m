function plot_analysis(file_paths, legend_labels, analysis_title)
    % A flexible script to plot and compare the results of multiple training runs.
    
    if nargin < 3
        analysis_title = 'Agent Performance Analysis';
    end
    if nargin < 2
        error('Please provide legend labels for the plots.');
    end
    if nargin < 1
        error('Please provide a cell array of file paths to load.');
    end

    fprintf('Generating analysis plot: %s\n', analysis_title);

    smoothingWindow = 100;
    
    figure('Name', analysis_title, 'NumberTitle', 'off');
    hold on;

    colors = lines(length(file_paths)); % Get a set of distinct colors

    for i = 1:length(file_paths)
        filePath = file_paths{i};
        try
            data = load(filePath, 'episodeRewards');
        catch e
            warning('Could not load file: %s. Skipping. Error: %s', filePath, e.message);
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