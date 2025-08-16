function deck = create_deck()
    % Creates a standard 40-card Scopa deck as a table.
    suits = {'Coppe'; 'Denari'; 'Bastoni'; 'Spade'};
    ranks = (1:10)';
    
    % --- CHANGE: The value of a card for summing is its rank ---
    % An 8 is worth 8, a 9 is worth 9, and a 10 is worth 10 for captures.
    values = (1:10)'; 

    primiera_values = [16, 12, 13, 14, 15, 18, 21, 10, 10, 10]';
    card_ids = (1:40)';
    
    deck = table();
    card_idx = 1;
    for s = 1:length(suits)
        temp_table = table(ranks, repmat(suits(s), 10, 1), values, primiera_values, ...
            card_ids(card_idx:card_idx+9), 'VariableNames', ...
            {'Rank', 'Suit', 'Value', 'PrimieraValue', 'CardID'});
        deck = [deck; temp_table];
        card_idx = card_idx + 10;
    end
end