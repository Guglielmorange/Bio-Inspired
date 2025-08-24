function qNetwork = create_network()
    newStateSize = 324; 

    % Create the layer graph
    lgraph = layerGraph();

    % Shared Feature Learning Base
    sharedLayers = [
        featureInputLayer(newStateSize, 'Name', 'state')
        fullyConnectedLayer(256, 'Name', 'fc1', 'WeightsInitializer', 'he')
        leakyReluLayer(0.01, 'Name', 'leaky1')
    ];
    lgraph = addLayers(lgraph, sharedLayers);

    % Value Stream 
    valueStream = [
        fullyConnectedLayer(128, 'Name', 'fc_value_1')
        leakyReluLayer(0.01, 'Name', 'leaky_value')
        fullyConnectedLayer(1, 'Name', 'value') 
    ];
    lgraph = addLayers(lgraph, valueStream);
    lgraph = connectLayers(lgraph, 'leaky1', 'fc_value_1');

    % Advantage Stream 
    advantageStream = [
        fullyConnectedLayer(128, 'Name', 'fc_advantage_1')
        leakyReluLayer(0.01, 'Name', 'leaky_advantage')
        fullyConnectedLayer(40, 'Name', 'advantage') 
    ];
    lgraph = addLayers(lgraph, advantageStream);
    lgraph = connectLayers(lgraph, 'leaky1', 'fc_advantage_1');
    
    % Aggregation Layer to combine outputs
    lgraph = addLayers(lgraph, additionLayer(2, 'Name', 'add'));
    lgraph = addLayers(lgraph, MeanSubtractionLayer('mean_sub_layer', 40));
    
    lgraph = connectLayers(lgraph, 'value', 'add/in1');
    lgraph = connectLayers(lgraph, 'advantage', 'mean_sub_layer/in');
    lgraph = connectLayers(lgraph, 'mean_sub_layer/out', 'add/in2');
    
    qNetwork = dlnetwork(lgraph);
end
