function hand_scores = calculate_hand_scores(players)
    p1_score = 0; p2_score = 0;
    p1_captured = players(1).captured; p2_captured = players(2).captured;

    if height(p1_captured) > height(p2_captured); p1_score = p1_score + 1;
    elseif height(p2_captured) > height(p1_captured); p2_score = p2_score + 1; end

    if sum(strcmp(p1_captured.Suit, 'Denari')) > sum(strcmp(p2_captured.Suit, 'Denari')); p1_score = p1_score + 1;
    elseif sum(strcmp(p2_captured.Suit, 'Denari')) > sum(strcmp(p1_captured.Suit, 'Denari')); p2_score = p2_score + 1; end

    if any(p1_captured.Rank == 7 & strcmp(p1_captured.Suit, 'Denari')); p1_score = p1_score + 1;
    elseif any(p2_captured.Rank == 7 & strcmp(p2_captured.Suit, 'Denari')); p2_score = p2_score + 1; end

    p1_primiera = get_primiera_score(p1_captured);
    p2_primiera = get_primiera_score(p2_captured);
    if p1_primiera > p2_primiera; p1_score = p1_score + 1;
    elseif p2_primiera > p1_primiera; p2_score = p2_score + 1; end

    p1_score = p1_score + players(1).scopas;
    p2_score = p2_score + players(2).scopas;

    hand_scores = [p1_score, p2_score];
end