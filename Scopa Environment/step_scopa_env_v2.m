function [next_game_state, reward, done] = step_scopa_env_v2(game_state, action, was_capture_possible)
    % This function executes a single step (playing one card) in the Scopa environment,
    % calculates the appropriate reward, and determines if the game has ended.

    % --- 1. Initialization ---
    reward = 0;
    done = false;
    cp = game_state.current_player;
    op = 3 - cp; % Opponent
    next_game_state = game_state;

    % --- 2. Apply Action and Update State ---
    played_card = action.played_card;
    next_game_state.players(cp).hand(action.hand_card_idx, :) = []; 
    
    if strcmp(action.type, 'capture')
        % --- Logic for a Capture Action ---
        captured_cards = action.captured_cards;
        all_captured = [captured_cards; played_card];
        reward = reward + 2.0; 
        
        % Increased reward multipliers to emphasize better captures
        reward = reward + (height(captured_cards) * 0.50);
        reward = reward + (sum(strcmp(all_captured.Suit, 'Denari')) * 0.60);
        
        is_primiera_card = all_captured.Rank == 7 | all_captured.Rank == 6;
        reward = reward + (sum(is_primiera_card) * 0.3);
        is_settebello = (all_captured.Rank == 7) & strcmp(all_captured.Suit, 'Denari');
        if any(is_settebello); reward = reward + 3.0; end

        next_game_state.players(cp).captured = [next_game_state.players(cp).captured; all_captured];
        next_game_state.field_cards(action.capture_indices, :) = [];
        next_game_state.last_capture_player = cp;

        if isempty(next_game_state.field_cards)
            reward = reward + 5.0; % Scopa bonus
            next_game_state.players(cp).scopas = next_game_state.players(cp).scopas + 1;
        end
    else % Action type is 'trail'
        % --- Logic for a Trail Action ---
        if was_capture_possible
            reward = reward - 5.0; % Penalty for ignoring a capture
        else
            is_valuable = (played_card.Rank == 7) || strcmp(played_card.Suit, 'Denari');
            if is_valuable; reward = reward - 1.5; else; reward = reward - 0.2; end
        end
        next_game_state.field_cards = [next_game_state.field_cards; played_card];
    end

    % --- 3. Check for End of Round or End of Game ---
    if isempty(next_game_state.players(1).hand) && isempty(next_game_state.players(2).hand)
        if isempty(next_game_state.deck)
            % --- End of Game Logic ---
            done = true; % The entire game is over

            % Assign any remaining cards on the table to the last player who made a capture.
            if next_game_state.last_capture_player > 0
                next_game_state.players(next_game_state.last_capture_player).captured = [
                    next_game_state.players(next_game_state.last_capture_player).captured;
                    next_game_state.field_cards];
                next_game_state.field_cards = table();
            end

            % Calculate final scores and assign a large terminal reward for winning.
            scores = calculate_hand_scores(next_game_state.players);
            if scores(cp) > scores(op)
                reward = reward + 20.0; % Win bonus
            elseif scores(op) > scores(cp)
                reward = reward - 20.0; % Loss penalty
            end
        else
            % --- End of Round Logic ---
            % Hands are empty, but the deck is not. The game continues.
            % The training loop will handle the re-dealing of cards.
            done = false;
        end
    end

    % --- 4. Switch Player for the Next Turn ---
    next_game_state.current_player = op;
end