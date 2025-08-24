function [players, field, deck] = deal_cards(players, deck, is_initial_deal)
    if is_initial_deal
        % Initial deal at the very start of a new game
        players(1).hand = deck(1:3, :); deck(1:3, :) = [];
        players(2).hand = deck(1:3, :); deck(1:3, :) = [];
        field = deck(1:4, :); deck(1:4, :) = [];
    else
        field = table(); 
        
        % Deal new hands to players if there are enough cards in the deck
        if height(deck) >= 6
            players(1).hand = deck(1:3, :); deck(1:3, :) = [];
            players(2).hand = deck(1:3, :); deck(1:3, :) = [];
        end
    end
end