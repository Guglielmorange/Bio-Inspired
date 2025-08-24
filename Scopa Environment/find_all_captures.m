function capture_groups = find_all_captures(played_card_value, field_card_values)
    % Finds all possible combinations of field cards that can be captured by the played card.
    % Output: A cell array where each cell contains the indices of the cards on the field that form a valid capture group.

    capture_groups = {};
    num_field_cards = length(field_card_values);

    % Check for a direct rank match
    match_indices = find(field_card_values == played_card_value);
    if ~isempty(match_indices)
        capture_groups{end+1} = match_indices;
        return;
    end

    % Check for sum combinations
    for i = 1:2^num_field_cards - 1
        subset_indices = find(dec2bin(i, num_field_cards) == '1');
        
        if sum(field_card_values(subset_indices)) == played_card_value
            capture_groups{end+1} = subset_indices;
        end
    end
end
