function test_winrate(agentFile, opponentFile)
    % Agent Win Rate Evaluation Script

    numGames = 100;
    winningScore = 11;
    
    if nargin < 1
        agentFile = fullfile('Results', 'scopa_agent_final.mat');
    end
    if nargin < 2
        opponentFile = 'random'; % Default to a random opponent, you can also pick a previous version of the agent
    end

    % Trained Agent
    fprintf('Loading agent from %s...\n', agentFile);
    try
        agentData = load(agentFile, 'qNetwork');
        qNetwork = agentData.qNetwork;
    catch
        error('Failed to load agent file: %s', agentFile);
    end
    
    % Opponent
    isOpponentRandom = false;
    if strcmpi(opponentFile, 'random')
        isOpponentRandom = true;
        fprintf('Opponent is a random player.\n');
    else
        fprintf('Loading opponent from %s...\n', opponentFile);
        try
            opponentData = load(opponentFile, 'qNetwork');
            opponentNetwork = opponentData.qNetwork;
        catch
            error('Failed to load opponent file: %s', opponentFile);
        end
    end
    
    agentGamesWon = 0;
    opponentGamesWon = 0;
    
    fprintf('--- Playing %d Games to %d ---\n', numGames, winningScore);
    
    h = waitbar(0, sprintf('Playing Game 1 of %d...', numGames));

    for gameNum = 1:numGames
        waitbar(gameNum / numGames, h, sprintf('Playing Game %d of %d...', gameNum, numGames));
        
        agentTotalScore = 0;
        opponentTotalScore = 0;
        
        while agentTotalScore < winningScore && opponentTotalScore < winningScore
            gameState = reset_scopa_env();
            done = false;
            
            while ~done
                if isempty(gameState.players(1).hand) && isempty(gameState.players(2).hand)
                    if isempty(gameState.deck)
                        done = true;
                        continue;
                    else
                        [gameState.players, ~, gameState.deck] = deal_cards(gameState.players, gameState.deck, false);
                    end
                end

                cp = gameState.current_player;

                if ~isempty(gameState.players(cp).hand)
                    valid_actions = get_valid_actions(gameState);
                    if isempty(valid_actions); done = true; continue; end
                    
                    was_capture_possible = false;
                    for k = 1:length(valid_actions); if strcmp(valid_actions{k}.type, 'capture'); was_capture_possible = true; break; end; end

                    if cp == 1 
                        currentState = preprocess_state(gameState);
                        all_q_values = predict(qNetwork, dlarray(currentState, 'CB'));
                        qValues_data = extractdata(all_q_values);
                        
                        valid_q_values = -inf(1, length(valid_actions), 'single');
                        for i = 1:length(valid_actions)
                           card_id = valid_actions{i}.played_card.CardID;
                           valid_q_values(i) = qValues_data(card_id);
                        end
                        [~, chosen_action_idx] = max(valid_q_values);
                        chosen_action = valid_actions{chosen_action_idx};
                    
                    else 
                        if isOpponentRandom
                            chosen_action_idx = randi(length(valid_actions));
                            chosen_action = valid_actions{chosen_action_idx};
                        else
                            currentState = preprocess_state(gameState);
                            all_q_values = predict(opponentNetwork, dlarray(currentState, 'CB'));
                            qValues_data = extractdata(all_q_values);
                            
                            valid_q_values = -inf(1, length(valid_actions), 'single');
                            for i = 1:length(valid_actions)
                               card_id = valid_actions{i}.played_card.CardID;
                               valid_q_values(i) = qValues_data(card_id);
                            end
                            [~, chosen_action_idx] = max(valid_q_values);
                            chosen_action = valid_actions{chosen_action_idx};
                        end
                    end
                    
                    [gameState, ~, done] = step_scopa_env(gameState, chosen_action, was_capture_possible);
                else
                    gameState.current_player = 3 - cp;
                end
            end
            
            round_scores = calculate_hand_scores(gameState.players);
            agentTotalScore = agentTotalScore + round_scores(1);
            opponentTotalScore = opponentTotalScore + round_scores(2);
        end
        
        if agentTotalScore > opponentTotalScore
            agentGamesWon = agentGamesWon + 1;
        else
            opponentGamesWon = opponentGamesWon + 1;
        end
    end
    
    close(h);

    winRate = (agentGamesWon / numGames) * 100;
    
    fprintf('\n--- Evaluation Complete ---\n');
    fprintf('Total Games Played: %d\n', numGames);
    fprintf('Agent Wins: %d\n', agentGamesWon);
    fprintf('Opponent Wins: %d\n', opponentGamesWon);
    fprintf('---------------------------\n');
    fprintf('Agent Win Rate: %.2f%%\n', winRate);
    fprintf('---------------------------\n');
end