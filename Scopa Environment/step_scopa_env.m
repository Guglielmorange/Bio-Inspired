function [next_game_state, reward, done] = step_scopa_env(game_state, action, was_capture_possible)

    % Initialization
    reward = 0;
    done = false;
    cp = game_state.current_player;
    op = 3 - cp; 
    next_game_state = game_state;

    % Apply Action and Update State
    played_card = action.played_card;
    next_game_state.players(cp).hand(action.hand_card_idx, :) = []; 
    
    if strcmp(action.type, 'capture')
        % Logic for a Capture Action 
        captured_cards = action.captured_cards;
        all_captured = [captured_cards; played_card];
        reward = reward + 2.0; 
        
        % Reward multipliers
        reward = reward + (height(captured_cards) * 0.85);
        reward = reward + (sum(strcmp(all_captured.Suit, 'Denari')) * 0.70);
        
        is_primiera_card = all_captured.Rank == 7 | all_captured.Rank == 6;
        reward = reward + (sum(is_primiera_card) * 0.4);
        is_settebello = (all_captured.Rank == 7) & strcmp(all_captured.Suit, 'Denari');
        if any(is_settebello); reward = reward + 5.0; end

        next_game_state.players(cp).captured = [next_game_state.players(cp).captured; all_captured];
        next_game_state.field_cards(action.capture_indices, :) = [];
        next_game_state.last_capture_player = cp;

        if isempty(next_game_state.field_cards)
            reward = reward + 5.0;
            next_game_state.players(cp).scopas = next_game_state.players(cp).scopas + 1;
        end
    else 
        if was_capture_possible
            reward = reward - 3.0; 
        else
            is_valuable = (played_card.Rank == 7) || strcmp(played_card.Suit, 'Denari');
            if is_valuable; reward = reward - 1.5; else; reward = reward - 0.2; end
        end
        next_game_state.field_cards = [next_game_state.field_cards; played_card];
    end

    if isempty(next_game_state.players(1).hand) && isempty(next_game_state.players(2).hand)
        if isempty(next_game_state.deck)
            % End of Game Logic
            done = true; 

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
                reward = reward + 20.0; 
            elseif scores(op) > scores(cp)
                reward = reward - 20.0; 
            end
        else
            done = false;
        end
    end

    %  Switch Player for the Next Turn
    next_game_state.current_player = op;
end