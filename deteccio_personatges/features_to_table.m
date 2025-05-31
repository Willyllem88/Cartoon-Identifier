% Script per passar features a taula
% Aixo cal ja que el classification learner vol una taula

% Load your extracted data
load('spongebob_features.mat','features','labels');

% Build variable names
varNames = [ ...
    {'meanS','sdS','meanV','sdV'}, ...          % 4 color‐moments
    arrayfun(@(i) sprintf('hueBin%02d',i), 1:16, 'uni',false), ...  % 16 histogram bins
    {'edgeDensity'} ];                          % 1 edge density

% Create the table
T = array2table(features, 'VariableNames', varNames);
T.IsSpongeBob = categorical(labels);  % add the response variable

% Inspect
head(T);
