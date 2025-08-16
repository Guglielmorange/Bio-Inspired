function capture_groups = find_all_captures(played_card_value, field_card_values)
    % Finds all possible combinations of field cards that can be captured
    % by the played card.
    %
    % Output: A cell array where each cell contains the indices of the
    %         cards on the field that form a valid capture group.

    capture_groups = {};
    num_field_cards = length(field_card_values);

    % 1. Check for a direct rank match
    match_indices = find(field_card_values == played_card_value);
    if ~isempty(match_indices)
        % If there's a direct match, Scopa rules state you MUST take it.
        % We only return this capture option.
        capture_groups{end+1} = match_indices;
        return;
    end

    % 2. If no direct match, check for sum combinations
    % Iterate through all possible subsets of field cards
    for i = 1:2^num_field_cards - 1
        subset_indices = find(dec2bin(i, num_field_cards) == '1');
        
        % Check if the sum of values in the subset equals the played card's value
        if sum(field_card_values(subset_indices)) == played_card_value
            capture_groups{end+1} = subset_indices;
        end
    end
end
