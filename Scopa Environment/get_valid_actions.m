function valid_actions = get_valid_actions(game_state)
    % Generates a cell array of all valid actions for the current player.

    valid_actions = {};
    player_hand = game_state.players(game_state.current_player).hand;
    field_cards = game_state.field_cards;

    % Iterate through each card in the player's hand
    for i = 1:height(player_hand)
        played_card = player_hand(i, :);
        
        % Find all possible combinations for the current card
        capture_groups = find_all_captures(played_card.Value, field_cards.Value);

        if ~isempty(capture_groups)
            for j = 1:length(capture_groups)
                action.type = 'capture';
                action.hand_card_idx = i;
                action.played_card = played_card;
                action.capture_indices = capture_groups{j};
                action.captured_cards = field_cards(capture_groups{j}, :);
                valid_actions{end+1} = action;
            end
        else
            action.type = 'trail';
            action.hand_card_idx = i;
            action.played_card = played_card;
            action.capture_indices = [];
            action.captured_cards = [];
            valid_actions{end+1} = action;
        end
    end
end