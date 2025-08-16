% preprocess_state.m (Updated with Historical Features)

function state = preprocess_state(game_state)
    % Converts the game state into a rich feature vector including historical info.
    cp = game_state.current_player;
    op = 3 - cp;

    % --- Part 1: Card Location Matrix (as before) ---
    card_locations = zeros(40, 4, 'single');
    if ~isempty(game_state.players(cp).hand)
        card_locations(game_state.players(cp).hand.CardID, 1) = 1; % Agent's Hand
    end
    if ~isempty(game_state.field_cards)
        card_locations(game_state.field_cards.CardID, 2) = 1; % Cards on Table
    end
    if ~isempty(game_state.players(cp).captured)
        card_locations(game_state.players(cp).captured.CardID, 3) = 1; % Agent's Captured
    end
    % NEW: Add opponent's captured cards as a feature
    if ~isempty(game_state.players(op).captured)
        card_locations(game_state.players(op).captured.CardID, 4) = 1; % Opponent's Captured
    end
    
    base_state_vector = card_locations(:); % 160x1 vector

    % --- Part 2: Historical and Game-Level Features ---
    % NEW: Create explicit features for game progress.
    
    % Vector indicating all cards out of play 
    out_of_play = zeros(40, 1, 'single');
    if ~isempty(game_state.players(cp).captured)
        out_of_play(game_state.players(cp).captured.CardID) = 1;
    end
    if ~isempty(game_state.players(op).captured)
        out_of_play(game_state.players(op).captured.CardID) = 1;
    end

    % Counts of cards and scopas for both players [cite: 210, 211]
    agent_card_count = single(height(game_state.players(cp).captured));
    opponent_card_count = single(height(game_state.players(op).captured));
    agent_scopa_count = single(game_state.players(cp).scopas);
    opponent_scopa_count = single(game_state.players(op).scopas);
    
    % Normalize counts to prevent large values from dominating network inputs
    % (e.g., divide by 40 for cards, maybe 4-5 for scopas)
    game_features = [
        agent_card_count / 40; 
        opponent_card_count / 40; 
        agent_scopa_count / 5; 
        opponent_scopa_count / 5
    ]; % 4x1 vector

    % --- Part 3: Combine all features ---
    % Note: The 'capture_potential' feature is very advanced and specific.
    % For a standard rich state, historical info is more common. You can choose
    % to keep it or replace it with this more standard historical vector.
    % Let's combine them for maximum information.
    
    % (Your original capture potential code can remain here)
    capture_feature_matrix = zeros(40, 3, 'single');
    player_hand = game_state.players(cp).hand;
    field_cards = game_state.field_cards;
    if ~isempty(player_hand) && ~isempty(field_cards)
        % ... (rest of your capture feature logic) ...
    end
    capture_feature_vector = capture_feature_matrix(:); % 120x1 vector

    % Final state vector
    state = [base_state_vector; out_of_play; game_features; capture_feature_vector];
    
    % IMPORTANT: You must update 'newStateSize' in create_network.m to match
    % the new length of this state vector (160 + 40 + 4 + 120 = 324).
end