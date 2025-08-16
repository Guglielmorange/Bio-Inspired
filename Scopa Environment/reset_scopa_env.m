% === FULL GAME VERSION ===
function game_state = reset_scopa_env()
    % Create and shuffle deck
    deck = create_deck();
    
    % Create an empty table with the same structure as the deck
    deck_template = deck(1,:);
    deck_template(1,:) = []; % Empty the template, keeping the column headers
    
    deck = deck(randperm(height(deck)), :);

    % Initialize players
    for i = 1:2
        players(i).hand = table();
        players(i).captured = deck_template; % Use the structured empty table
        players(i).scopas = 0;
    end

    % Deal initial hands and field cards
    [players, field_cards, deck] = deal_cards(players, deck, true);

    % Build initial game_state for a full game
    game_state.players = players;
    game_state.field_cards = field_cards;
    game_state.deck = deck; % The rest of the deck is now part of the state
    game_state.current_player = randi(2);
    game_state.last_capture_player = 0;
    game_state.done = false;
    game_state.reward = 0;
end


% % === SINGLE-HAND VERSION [FIXED for empty captures] ===
% function game_state = reset_scopa_env()
%     % Create and shuffle deck
%     deck = create_deck();
% 
%     % --- FIX: Create an empty table with the same structure as the deck ---
%     % This prevents errors when a player captures zero cards.
%     deck_template = deck(1,:);
%     deck_template(1,:) = []; % Empty the template, keeping the column headers
% 
%     deck = deck(randperm(height(deck)), :);
% 
%     % Initialize players
%     for i = 1:2
%         players(i).hand = table();
%         players(i).captured = deck_template; % Use the structured empty table
%         players(i).scopas = 0;
%     end
% 
%     % Deal a single hand (3 cards each, 4 to field)
%     [players, field_cards, ~] = deal_cards(players, deck, true);
% 
%     % Build initial game_state for a single hand
%     game_state.players = players;
%     game_state.field_cards = field_cards;
%     game_state.deck = table(); % Deck is empty for single-hand games
%     game_state.current_player = randi(2);
%     game_state.last_capture_player = 0;
%     game_state.done = false;
%     game_state.reward = 0;
% end