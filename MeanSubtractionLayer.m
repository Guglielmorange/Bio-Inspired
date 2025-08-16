
classdef MeanSubtractionLayer < nnet.layer.Layer
    properties
        NumActions
    end
    methods
        function layer = MeanSubtractionLayer(name, numActions)
            layer.Name = name;
            layer.NumActions = numActions;
        end
        function Z = predict(layer, X)
            % Implements Z = X - mean(X)
            meanAdvantage = mean(X, 1);
            Z = X - meanAdvantage;
        end
    end
end