% extract_all_features.m
% Master script to extract features from positive and negative patches
% using external extractFeatures.m function

%% --- User parameters ---
windowSize = [128 128];  % ensure all patches are same size
posFolder  = 'positives';
negFolder  = 'negatives';
binCount   = 16;        % number of bins for hue histogram

%% --- Gather image file lists ---
posFiles = dir(fullfile(posFolder, '*.jpg'));
negFiles = dir(fullfile(negFolder, '*.jpg'));
numPos   = numel(posFiles);
numNeg   = numel(negFiles);
total    = numPos + numNeg;

%% --- Preallocate feature matrix and labels ---
% Features: [meanS, sdS, meanV, sdV, hist(1:binCount), edgeDensity]
featLen = 4 + binCount + 1;  % 4 color moments + histogram + edge density
features = zeros(total, featLen);
labels   = false(total, 1);   % true = SpongeBob, false = background

%% --- Process positives ---
for i = 1:numPos
    I = imread(fullfile(posFolder, posFiles(i).name));
    % Call external feature extraction function
    vec = extractFeatures_SPONGEBOB(I, binCount, windowSize);
    features(i, :) = vec;
    labels(i) = true;
end

%% --- Process negatives ---
for i = 1:numNeg
    I = imread(fullfile(negFolder, negFiles(i).name));
    % Call external feature extraction function
    vec = extractFeatures_SPONGEBOB(I, binCount, windowSize);
    features(numPos + i, :) = vec;
    labels(numPos + i) = false;
end

%% --- Save features and labels ---
outputFile = fullfile('./', 'spongebob_features.mat');
save(outputFile, 'features', 'labels');
fprintf('Extracted %d feature vectors (%d pos, %d neg) and saved to %s.\n', total, numPos, numNeg, outputFile);
