function [qNetwork, optimizerState, loss] = update_network(qNetwork, targetNetwork, optimizerState, batch, gamma, learningRate, iteration)
    
    % Re-format the batch data
    states = dlarray(cat(2, batch.state), 'CB');
    actions = [batch.action]';
    rewards = [batch.reward]';
    nextStates = dlarray(cat(2, batch.next_state), 'CB');
    dones = [batch.done]';
    
    % Double DQN Target Calculation
    qNext_online = predict(qNetwork, nextStates);
    [~, best_actions_idx] = max(extractdata(qNext_online), [], 1);
    qNext_target = predict(targetNetwork, nextStates);
    batch_size = length(best_actions_idx);
    linear_indices = sub2ind(size(qNext_target), best_actions_idx, 1:batch_size);
    maxNextQ = extractdata(qNext_target(linear_indices));
    qTargets = dlarray(rewards + gamma * maxNextQ' .* ~dones, 'CB');
    
    % Compute gradients using Huber Loss
    [gradients, loss] = dlfeval(@modelGradients_Huber, qNetwork, states, actions, qTargets);

    % Gradient Clipping
    gradThreshold = 1.0; 
    gradients = dlupdate(@(g) thresholdL2Norm(g, gradThreshold), gradients);

    % Update network
    [qNetwork.Learnables, optimizerState.averageGrad, optimizerState.averageSqGrad] = adamupdate(...
        qNetwork.Learnables, gradients, optimizerState.averageGrad, optimizerState.averageSqGrad, iteration, learningRate);
end

% Gradient function for Huber Loss
function [gradients, loss] = modelGradients_Huber(net, states, actions, targets)
    qPred = predict(net, states);
    
    batchSize = size(qPred, 2);
    actionIndices = sub2ind(size(qPred), actions', 1:batchSize);
    selectedQ = qPred(actionIndices);
    
    targets = reshape(targets, size(selectedQ));
    
    % Huber Loss logic
    delta = 1.0;
    err = selectedQ - targets;
    quadratic = min(abs(err), delta);
    linear = abs(err) - quadratic;
    loss = mean(0.5 * quadratic.^2 + delta * linear);
    
    gradients = dlgradient(loss, net.Learnables);
end

function g = thresholdL2Norm(g, threshold)
    normG = sqrt(sum(g.^2, 'all'));
    if normG > threshold
        g = g * (threshold / normG);
    end
end