% features_to_table.m
% Script auxiliar que converteix una matriu (de features del TRAIN), a una
% tala (de manera que li podem passar al classification learner)

load('spongebob_features.mat', 'features', 'labels');
[~, featDim] = size(features);
varNames = arrayfun(@(i) sprintf('feat%03d', i), 1:featDim, 'UniformOutput', false);
T = array2table(features, 'VariableNames', varNames);
T.IsSpongeBob = categorical(labels);