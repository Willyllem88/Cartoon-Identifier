% extract_all_features.m
% Master script to extract the enhanced feature vectors from positive and negative patches
% using the external extractFeatures_SPONGEBOB.m function.

%% --- User parameters ---
windowSize = [128 128];      % ensure all patches are same size
posFolder  = 'positives';
negFolder  = 'negatives';
binCount   = 32;             % number of bins for each HSV histogram

%% --- Gather image file lists ---
posFiles = dir(fullfile(posFolder, '*.jpg'));
negFiles = dir(fullfile(negFolder, '*.jpg'));
numPos   = numel(posFiles);
numNeg   = numel(negFiles);
total    = numPos + numNeg;

if total == 0
    error('No images found in "positives/" or "negatives/" folders.');
end

%% --- Determine feature vector length dynamically by sampling one image ---
% Read one positive patch (or negative if no positives)
if numPos > 0
    sampleImg = imread(fullfile(posFolder, posFiles(1).name));
else
    sampleImg = imread(fullfile(negFolder, negFiles(1).name));
end
sampleVec = extractFeatures_SPONGEBOB(sampleImg, binCount, windowSize);
featLen   = length(sampleVec);

%% --- Preallocate feature matrix and labels ---
features = zeros(total, featLen);
labels   = false(total, 1);   % true = SpongeBob, false = background

%% --- Process positives ---
for i = 1:numPos
    I = imread(fullfile(posFolder, posFiles(i).name));
    vec = extractFeatures_SPONGEBOB(I, binCount, windowSize);
    features(i, :) = vec;
    labels(i) = true;
end

%% --- Process negatives ---
for i = 1:numNeg
    I   = imread(fullfile(negFolder, negFiles(i).name));
    vec = extractFeatures_SPONGEBOB(I, binCount, windowSize);
    features(numPos + i, :) = vec;
    labels(numPos + i) = false;
end

%% --- Save features and labels ---
outputFile = fullfile('.', 'spongebob_features.mat');
save(outputFile, 'features', 'labels');
fprintf('Extracted %d feature vectors (%d pos, %d neg) and saved to %s.\n', ...
        total, numPos, numNeg, outputFile);
