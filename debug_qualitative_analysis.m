function debug_qualitative_analysis(agent_file_path)
    % --- Qualitative Analysis Script ---
    fprintf('--- Starting Qualitative Analysis ---\n');

    if nargin < 1
        agent_file_path = fullfile('Results', 'scopa_agent_final_p2_stable.mat');
    end
    
    try
        fprintf('Loading agent from: %s\n', agent_file_path);
        load(agent_file_path, 'qNetwork');
    catch
        error('Failed to load agent file. Make sure "%s" exists.', agent_file_path);
    end

    gameState = reset_scopa_env();
    done = false;
    
    fprintf('\n--- Starting New Game Analysis ---\n');
    while ~done
        if isempty(gameState.players(1).hand) && isempty(gameState.players(2).hand)
            if isempty(gameState.deck); done = true; continue;
            else; [gameState.players, ~, gameState.deck] = deal_cards(gameState.players, gameState.deck, false); end
        end

        cp = gameState.current_player;

        if ~isempty(gameState.players(cp).hand)
            valid_actions = get_valid_actions(gameState);
            if isempty(valid_actions); done = true; continue; end
            
            was_capture_possible = false;
            for k = 1:length(valid_actions); if strcmp(valid_actions{k}.type, 'capture'); was_capture_possible = true; break; end; end

            if cp == 1 % Agent's Turn
                fprintf('\n------------------- AGENT''S TURN -------------------\n');
                fprintf('Table Cards: %s\n', format_cards(gameState.field_cards));
                fprintf('Agent''s Hand: %s\n', format_cards(gameState.players(1).hand));
                fprintf('-----------------------------------------------------\n');
                
                currentState = preprocess_state(gameState);
                all_q_values = predict(qNetwork, dlarray(currentState, 'CB'));
                qValues_data = extractdata(all_q_values);
                
                fprintf('Agent''s Assessed Q-Values for Valid Actions:\n');
                valid_q_values = -inf(1, length(valid_actions), 'single');
                for i = 1:length(valid_actions)
                   action = valid_actions{i};
                   card_id = action.played_card.CardID;
                   valid_q_values(i) = qValues_data(card_id);
                   action_description = sprintf('Play %s', format_cards(action.played_card));
                   if strcmp(action.type, 'capture'); action_description = [action_description, sprintf(' to capture %s', format_cards(action.captured_cards))]; end
                   fprintf('  - Action: %-50s | Q-Value: %8.4f\n', action_description, valid_q_values(i));
                end
                
                [~, chosen_action_idx] = max(valid_q_values);
                chosen_action = valid_actions{chosen_action_idx};
                
                fprintf('-----------------------------------------------------\n');
                fprintf('BEST ACTION CHOSEN (Highest Q-Value):\n');
                best_action_desc = sprintf('Play %s', format_cards(chosen_action.played_card));
                if strcmp(chosen_action.type, 'capture'); best_action_desc = [best_action_desc, sprintf(' to capture %s', format_cards(chosen_action.captured_cards))]; end
                fprintf('>> %s\n', best_action_desc);
                fprintf('-----------------------------------------------------\n');
                input('Press Enter to execute agent''s turn...');
            else % Opponent's Turn
                fprintf('\n--- Opponent''s Turn ---\n');
                chosen_action_idx = randi(length(valid_actions));
                chosen_action = valid_actions{chosen_action_idx};
                fprintf('Opponent played: %s.\n', format_cards(chosen_action.played_card));
            end
            
            [gameState, ~, done] = step_scopa_env(gameState, chosen_action, was_capture_possible);
        else
            gameState.current_player = 3 - cp;
        end
    end
    fprintf('\n--- GAME OVER ---\n');
end

function str = format_cards(card_table)
    if isempty(card_table); str = '[None]'; return; end
    cards = cell(height(card_table), 1);
    for i = 1:height(card_table); cards{i} = sprintf('%d of %s', card_table.Rank(i), card_table.Suit{i}); end
    str = strjoin(cards, ', ');
end