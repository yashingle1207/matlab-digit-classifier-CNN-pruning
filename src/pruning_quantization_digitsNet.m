% This script trains a digit classification CNN, prunes it iteratively using L1 norm,
% and performs post-training quantization. Visualizations and model statistics are also included.

scriptDir = fileparts(mfilename('fullpath'));
projectRoot = fileparts(scriptDir);
modelsDir = fullfile(projectRoot,'models');
resultsDir = fullfile(projectRoot,'results');
trainedNetPath = fullfile(modelsDir,'digitsNet.mat');
sparseNetPath = fullfile(modelsDir,'digitsNet_0.90_sparsity_params_6634.mat');

if ~isfolder(modelsDir)
    mkdir(modelsDir);
end

if ~isfolder(resultsDir)
    mkdir(resultsDir);
end

% -----------------------------
% Step 1: Load Dataset & Train
% -----------------------------
[imdsTrain, imdsValidation] = loadDigitDataset;
net = trainDigitDataNetwork(imdsTrain, imdsValidation);
save(trainedNetPath,'net');
trueLabels = imdsValidation.Labels;
classes = categories(trueLabels);

executionEnvironment = "auto";
miniBatchSize = 128;
imdsValidation.ReadSize = miniBatchSize;
mbqValidation = minibatchqueue(imdsValidation,1,...
    'MiniBatchSize',miniBatchSize,...
    'MiniBatchFormat','SSCB',...
    'MiniBatchFcn',@preprocessMiniBatch,...
    'OutputEnvironment',executionEnvironment);

lgraph = layerGraph(net.Layers);
lgraph = removeLayers(lgraph,["softmax","classoutput"]);
dlnetOriginal = dlnetwork(lgraph);
accuracyOriginalNet = evaluateAccuracy(dlnetOriginal,mbqValidation,classes,trueLabels);

% -----------------------------
% Step 2: Initialize Pruning
% -----------------------------
if isfile(trainedNetPath)
    load(trainedNetPath,'net');
end
convIndices = findConvLayers(net.Layers);
bnIndices = findBatchNormLayers(net.Layers);
fcIndex = findFCLayers(net.Layers);

prune_ratio = 0.1;
prune_iterations = int32(1/prune_ratio)-1;
prunedChannelsPerItr = zeros(length(convIndices), prune_iterations);
numOutChannelsPerLayer = zeros(length(convIndices),1);

for i=1:length(convIndices)
    layer = net.Layers(convIndices(i));
    if isa(layer, 'nnet.cnn.layer.Convolution2DLayer')
        numOutChannelsPerLayer(i) = layer.NumFilters;
    end
end

prunedAccuracies = zeros(prune_iterations, 1);
sparsityLevels = zeros(prune_iterations, 1);
options = trainingOptions('sgdm', ...
    'InitialLearnRate',0.01, 'MaxEpochs',10, ...
    'Shuffle','every-epoch', 'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, 'Verbose',false, ...
    'Plots','none',"ExecutionEnvironment","auto");

iter=1;
while true
    [convWeights, ~] = getConvWeights(net, convIndices);
    pruneFilters = computeL1Pruning(convWeights, prune_ratio);
    if iter-1 >= prune_iterations
        break;
    end
    [net,prunedChannelsPerItr(:,iter)]= pruneNetwork(net, convIndices, bnIndices, fcIndex, pruneFilters);
    lgraph_1 = layerGraph(net.Layers);
    prunedNet = trainNetwork(imdsTrain, lgraph_1, options);
    lgraph_2 = layerGraph(prunedNet.Layers);
    lgraph_2 = removeLayers(lgraph_2, ["softmax","classoutput"]);
    dlnet_2 = dlnetwork(lgraph_2);
    prunedAccuracies(iter) = evaluateAccuracy(dlnet_2,mbqValidation,classes,trueLabels);
    sparsityLevels(iter) = iter * prune_ratio * 100;
    net = prunedNet;
    iter=iter+1;
end

% -----------------------------
% Step 3: Plot Pruning Accuracy
% -----------------------------
figure
plot(sparsityLevels, prunedAccuracies*100, '-og','LineWidth',2,'MarkerSize',6);
xlabel('Sparsity (%)'); ylabel('Accuracy (%)');
title('Pruning Accuracy Trend'); grid on;
saveas(gcf,fullfile(resultsDir,'pruning_accuracy_trend.png'));

% -----------------------------
% Step 4: Plot Layer-wise Filters
% -----------------------------
prunedChannelsPerLayer = [sum(prunedChannelsPerItr, 2);0];
prunedConvChannels = prunedChannelsPerLayer(1:numel(convIndices));
remainingData = [numOutChannelsPerLayer-prunedConvChannels; size(net.Layers(fcIndex).Weights, 1)];
if remainingData(end) == 0; remainingData(end) = 1; end
layerNames = arrayfun(@(x) x.Name, net.Layers(convIndices), 'UniformOutput', false);
fcLayerName = net.Layers(fcIndex).Name;
selectedLayerNames = [layerNames; {fcLayerName}];
figure
bar([prunedChannelsPerLayer,remainingData],"stacked")
xlabel("Layer"); ylabel("Number of filters");
title("Number of Filters per Layer")
xticks(1:(numel(selectedLayerNames)))
xticklabels(selectedLayerNames)
xtickangle(45)
legend("Pruned","Remaining","Location","southoutside")
set(gca,'TickLabelInterpreter','none')
saveas(gcf,fullfile(resultsDir,'layer_filter_pruning.png'));

% -----------------------------
% Step 5: Quantization
% -----------------------------
calibrationDataStore = splitEachLabel(imdsTrain,0.1,'randomize');
validationDataStore = imdsValidation;
% Quantization expects a generated pruned .mat model to exist in the models folder.
assert(isfile(sparseNetPath), 'Expected pruned model file not found: %s', sparseNetPath);
load(sparseNetPath,'net');
quantObjPrunedNetwork = dlquantizer(net,'ExecutionEnvironment','auto');
quantOpts = dlquantizationOptions('Target','host');
calResults = calibrate(quantObjPrunedNetwork, calibrationDataStore);
valResults = validate(quantObjPrunedNetwork, validationDataStore, quantOpts);
valResults.MetricResults.Result
save(fullfile(modelsDir,'quantObjPrunedNetworkCalResults.mat'),'calResults');
save(fullfile(modelsDir,'quantObjPrunedNetwork.mat'),'quantObjPrunedNetwork');

% End of Script
