% features_to_table.m
% Convert the extracted feature matrix into a table for Classification Learner.
% This version assigns generic column names ("feat001", "feat002", …) so it
% works regardless of the feature dimension.

%% --- Load feature data ---
% Ensure you have run extract_all_features.m so that 'spongebob_features.mat'
% exists and contains variables 'features' (N×D) and 'labels' (N×1 logical).
load('spongebob_features.mat', 'features', 'labels');

%% --- Determine feature dimension and build generic variable names ---
[~, featDim] = size(features);
varNames = arrayfun(@(i) sprintf('feat%03d', i), 1:featDim, ...
                    'UniformOutput', false);

%% --- Create the table with generic feature columns ---
T = array2table(features, 'VariableNames', varNames);

%% --- Add the response variable (categorical) ---
T.IsSpongeBob = categorical(labels);

%% --- Inspect the first few rows ---
disp('First few rows of the feature table:');
head(T);
