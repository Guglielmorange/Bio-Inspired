function [qNetwork, episodeRewards] = train_scopa_agent(params)
    % --- Hyperparameters (loaded from the input struct) ---
    numEpisodes = params.numEpisodes;
    initialLearningRate = params.initialLearningRate;
    gamma = params.gamma;
    batchSize = params.batchSize;
    tau = params.tau;
    epsilonDecay = params.epsilonDecay;
    
    % --- Other fixed parameters ---
    minLearningRate = 0.00001;
    lrDecayRate = 0.99985;
    learningRate = initialLearningRate;
    epsilon = 1.0;
    minEpsilon = 0.1;
    bufferCapacity = 100000;
    opponentUpdateFrequency = 2500;
    opponentPoolSize = 30;
    
    % --- Initialization ---
    qNetwork = create_network();
    targetNetwork = create_network();
    targetNetwork.Learnables = qNetwork.Learnables;
    
    opponentPool = cell(opponentPoolSize, 1);
    for i = 1:opponentPoolSize
        pool_net = create_network();
        pool_net.Learnables = qNetwork.Learnables;
        opponentPool{i} = pool_net;
    end
    poolPointer = 1;
    
    optimizerState.averageGrad = [];
    optimizerState.averageSqGrad = [];
    iteration = 0;
    
    replayBuffer = struct('state', cell(bufferCapacity,1), 'action', [], 'reward', [], 'next_state', [], 'done', []);
    bufferPointer = 1;
    bufferSize = 0;
    episodeRewards = zeros(numEpisodes, 1);
    
    fprintf('--- Training with LR=%.5f, Gamma=%.2f, BS=%d ---\n', initialLearningRate, gamma, batchSize);
    
    for episode = 1:numEpisodes
        gameState = reset_scopa_env();
        opponentNetwork = opponentPool{randi(opponentPoolSize)};
        done = false;
        totalReward = 0;
        
        while ~done
            if isempty(gameState.players(1).hand) && isempty(gameState.players(2).hand)
                if isempty(gameState.deck); done = true; continue;
                else; [gameState.players, ~, gameState.deck] = deal_cards(gameState.players, gameState.deck, false); end
            end
            cp = gameState.current_player;
            is_agent_turn = (cp == 1);
            if is_agent_turn; active_network = qNetwork; explore = true;
            else; active_network = opponentNetwork; explore = false; end

            if ~isempty(gameState.players(cp).hand)
                valid_actions = get_valid_actions(gameState);
                if isempty(valid_actions); done = true; continue; end
                
                was_capture_possible = false;
                for k = 1:length(valid_actions)
                    if strcmp(valid_actions{k}.type, 'capture'); was_capture_possible = true; break; end
                end
                if explore && rand < epsilon
                    chosen_action_idx = randi(length(valid_actions));
                else
                    currentState = preprocess_state(gameState);
                    qValues = predict(active_network, dlarray(currentState, 'CB'));
                    qValues_data = extractdata(qValues);
                    valid_q_values = -inf(1, length(valid_actions), 'single');
                    for i = 1:length(valid_actions)
                       card_id = valid_actions{i}.played_card.CardID;
                       valid_q_values(i) = qValues_data(card_id);
                    end
                    [~, chosen_action_idx] = max(valid_q_values);
                end
                
                chosen_action = valid_actions{chosen_action_idx};
                [next_game_state, reward, done] = step_scopa_env(gameState, chosen_action, was_capture_possible);
                
                if is_agent_turn
                    totalReward = totalReward + reward;
                    replayBuffer(bufferPointer) = struct('state', preprocess_state(gameState), 'action', chosen_action.played_card.CardID, 'reward', reward, 'next_state', preprocess_state(next_game_state), 'done', done);
                    bufferPointer = mod(bufferPointer, bufferCapacity) + 1;
                    bufferSize = min(bufferSize + 1, bufferCapacity);
                end
                gameState = next_game_state;
            else
                gameState.current_player = 3 - cp;
            end
        end
        
        episodeRewards(episode) = totalReward;
        epsilon = max(minEpsilon, epsilon * epsilonDecay);
        learningRate = max(minLearningRate, learningRate * lrDecayRate);
        
        if bufferSize >= batchSize
            batchIndices = randperm(bufferSize, batchSize);
            batch = replayBuffer(batchIndices);
            iteration = iteration + 1; 
            
            [qNetwork, optimizerState, ~] = update_network(qNetwork, targetNetwork, optimizerState, batch, gamma, learningRate, iteration);
            
            t_params = targetNetwork.Learnables;
            q_params = qNetwork.Learnables;
            for i = 1:height(t_params)
                t_params.Value{i} = tau * q_params.Value{i} + (1-tau) * t_params.Value{i};
            end
            targetNetwork.Learnables = t_params;
        end
        
        % --- CHANGE: Add intermediate progress notification ---
        if mod(episode, 5000) == 0 && episode > 0
            fprintf('... Progress: Episode %d / %d ...\n', episode, numEpisodes);
        end
    end
end