function state = preprocess_state(game_state)
    
    cp = game_state.current_player;
    op = 3 - cp;

    % Card Location Matrix: encodes where every card in the deck is located.
    card_locations = zeros(40, 4, 'single');
    if ~isempty(game_state.players(cp).hand)
        card_locations(game_state.players(cp).hand.CardID, 1) = 1; % Agent's Hand
    end
    if ~isempty(game_state.field_cards)
        card_locations(game_state.field_cards.CardID, 2) = 1; % Cards on Table
    end
    if ~isempty(game_state.players(cp).captured)
        card_locations(game_state.players(cp).captured.CardID, 3) = 1; % Agent's Captured Pile
    end
    if ~isempty(game_state.players(op).captured)
        card_locations(game_state.players(op).captured.CardID, 4) = 1; % Opponent's Captured Pile
    end
    
    base_state_vector = card_locations(:);

    % Historical and Game-Level Features

    out_of_play = zeros(40, 1, 'single');
    if ~isempty(game_state.players(cp).captured)
        out_of_play(game_state.players(cp).captured.CardID) = 1;
    end
    if ~isempty(game_state.players(op).captured)
        out_of_play(game_state.players(op).captured.CardID) = 1;
    end

    % Counts of cards and scopas for both players
    agent_card_count = single(height(game_state.players(cp).captured));
    opponent_card_count = single(height(game_state.players(op).captured));
    agent_scopa_count = single(game_state.players(cp).scopas);
    opponent_scopa_count = single(game_state.players(op).scopas);
    
    % Normalize counts
    game_features = [
        agent_card_count / 40; 
        opponent_card_count / 40; 
        agent_scopa_count / 5; 
        opponent_scopa_count / 5
    ];

    % Capture Potential Matrix 
    capture_feature_matrix = zeros(40, 3, 'single');
    player_hand = game_state.players(cp).hand;
    field_cards = game_state.field_cards;

    if ~isempty(player_hand) && ~isempty(field_cards)
        for i = 1:height(player_hand)
            played_card_value = player_hand.Value(i);
            
            capture_groups = find_all_captures(played_card_value, field_cards.Value);
            
            if ~isempty(capture_groups)
                for j = 1:length(capture_groups)
                    group_indices = capture_groups{j};
                    captured_card_ids = field_cards.CardID(group_indices);
                    
                   
                    capture_feature_matrix(captured_card_ids, i) = 1;
                end
            end
        end
    end
    capture_feature_vector = capture_feature_matrix(:);

    % Final State Vector
    state = [base_state_vector; out_of_play; game_features; capture_feature_vector];
    
end