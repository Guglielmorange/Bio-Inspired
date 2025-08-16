function total_primiera = get_primiera_score(captured_cards)
    suits = {'Coppe', 'Denari', 'Bastoni', 'Spade'};
    total_primiera = 0;
    for s_idx = 1:length(suits)
        suit_cards = captured_cards(strcmp(captured_cards.Suit, suits{s_idx}), :);
        if isempty(suit_cards)
            total_primiera = 0;
            return;
        end
        total_primiera = total_primiera + max(suit_cards.PrimieraValue);
    end
end