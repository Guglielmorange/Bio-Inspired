function run_sensitivity_analysis()
    % This master script automates the process of running a multi-variable
    % sensitivity analysis for the Scopa RL agent.

    % Add the Scopa Environment folder to MATLAB's path
    
    fprintf('--- Starting Multi-Variable Sensitivity Analysis ---\n');

    % --- Baseline Hyperparameters ---
    % All experiments will start with these settings, and we will vary
    % one parameter at a time.
    base_params.numEpisodes = 15000; % Shorter runs are fine for analysis
    base_params.initialLearningRate = 0.00025;
    base_params.gamma = 0.95;
    base_params.batchSize = 512;
    base_params.tau = 1e-3;
    base_params.epsilonDecay = 0.9999;
    
    % --- 1. Learning Rate Analysis ---
    fprintf('\n--- Testing Sensitivity to Learning Rate --- \n');
    params_lr_high = base_params;
    params_lr_high.initialLearningRate = 0.0005;
    
    params_lr_low = base_params;
    params_lr_low.initialLearningRate = 0.0001;
    
    run_and_save(base_params, 'scopa_agent_LR_BASELINE.mat');
    run_and_save(params_lr_high, 'scopa_agent_LR_HIGH.mat');
    run_and_save(params_lr_low, 'scopa_agent_LR_LOW.mat');

    % --- 2. Discount Factor (Gamma) Analysis ---
    fprintf('\n--- Testing Sensitivity to Discount Factor (Gamma) --- \n');
    params_gamma_high = base_params;
    params_gamma_high.gamma = 0.99;

    params_gamma_low = base_params;
    params_gamma_low.gamma = 0.85;
    
    run_and_save(params_gamma_high, 'scopa_agent_GAMMA_HIGH.mat');
    run_and_save(params_gamma_low, 'scopa_agent_GAMMA_LOW.mat');

    % --- 3. Batch Size Analysis ---
    fprintf('\n--- Testing Sensitivity to Batch Size --- \n');
    params_bs_high = base_params;
    params_bs_high.batchSize = 1024;
    
    params_bs_low = base_params;
    params_bs_low.batchSize = 128;

    run_and_save(params_bs_high, 'scopa_agent_BS_HIGH.mat');
    run_and_save(params_bs_low, 'scopa_agent_BS_LOW.mat');
    
    fprintf('\n--- Sensitivity Analysis Complete --- \n');
    fprintf('All result files have been saved to the "Results" folder.\n');
    fprintf('You can now use the plot_analysis.m script to generate your graphs.\n');
end

% --- Helper function to run training and save results ---
function run_and_save(params, filename)
    fprintf('Running training for: %s\n', filename);
    
    % Call the modified training function with the specified parameters
    [~, episodeRewards] = train_scopa_agent(params);
    
    % Save the results to the specified file
    resultsFolder = 'Results';
    if ~exist(resultsFolder, 'dir'); mkdir(resultsFolder); end
    save(fullfile(resultsFolder, filename), 'episodeRewards', 'params');
    
    fprintf('Finished and saved results for: %s\n', filename);
end