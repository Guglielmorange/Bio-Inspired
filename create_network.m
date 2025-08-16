% create_network.m (Updated for Dueling Architecture)

function qNetwork = create_network()
    newStateSize = 324; % From your preprocess_state.m

    % Create the layer graph
    lgraph = layerGraph();

    % --- Shared Feature Learning Base ---
    sharedLayers = [
        featureInputLayer(newStateSize, 'Name', 'state')
        fullyConnectedLayer(256, 'Name', 'fc1', 'WeightsInitializer', 'he')
        leakyReluLayer(0.01, 'Name', 'leaky1')
    ];
    lgraph = addLayers(lgraph, sharedLayers);

    % --- Value Stream (outputs a single scalar V(s)) ---
    valueStream = [
        fullyConnectedLayer(128, 'Name', 'fc_value_1')
        leakyReluLayer(0.01, 'Name', 'leaky_value')
        fullyConnectedLayer(1, 'Name', 'value') % Outputs a single value
    ];
    lgraph = addLayers(lgraph, valueStream);
    lgraph = connectLayers(lgraph, 'leaky1', 'fc_value_1');

    % --- Advantage Stream (outputs a value for each action A(s,a)) ---
    advantageStream = [
        fullyConnectedLayer(128, 'Name', 'fc_advantage_1')
        leakyReluLayer(0.01, 'Name', 'leaky_advantage')
        fullyConnectedLayer(40, 'Name', 'advantage') % 40 actions
    ];
    lgraph = addLayers(lgraph, advantageStream);
    lgraph = connectLayers(lgraph, 'leaky1', 'fc_advantage_1');
    
    % --- Aggregation Layer to combine V(s) and A(s,a) ---
    lgraph = addLayers(lgraph, additionLayer(2, 'Name', 'add'));
    lgraph = addLayers(lgraph, MeanSubtractionLayer('mean_sub_layer', 40)); % Custom Layer
    
    lgraph = connectLayers(lgraph, 'value', 'add/in1');
    lgraph = connectLayers(lgraph, 'advantage', 'mean_sub_layer/in');
    lgraph = connectLayers(lgraph, 'mean_sub_layer/out', 'add/in2');
    
    qNetwork = dlnetwork(lgraph);
end
