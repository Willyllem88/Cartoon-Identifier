% extract_features_of_train_spongebob.m
% Script que extreu totes les caracteristiques de la carpeta TRAIN, i
% es guarda les features.
% Comentari: s'han de posar els paths positives and negatives del TRAIN
% respectivament a les variables posFolder i negFolder perque funcioni

%% parametres
windowSize = [128 128];
posFolder  = '...';
negFolder  = '...';
binCount   = 32;

%% obtenim llista de les imatges
posFiles = dir(fullfile(posFolder, '*.jpg'));
negFiles = dir(fullfile(negFolder, '*.jpg'));
numPos   = numel(posFiles);
numNeg   = numel(negFiles);
total    = numPos + numNeg;

if total == 0
    error('No images found in "positives/" or "negatives/" folders.');
end

%% obetnir mida del vector de features
if numPos > 0
    sampleImg = imread(fullfile(posFolder, posFiles(1).name));
else
    sampleImg = imread(fullfile(negFolder, negFiles(1).name));
end
sampleVec = extractFeatures_SPONGEBOB(sampleImg, binCount, windowSize);
featLen   = length(sampleVec);

%% definim features i labels
features = zeros(total, featLen);
labels   = false(total, 1);   % true = SpongeBob, false = background

%% processem positives
for i = 1:numPos
    I = imread(fullfile(posFolder, posFiles(i).name));
    vec = extractFeatures_SPONGEBOB(I, binCount, windowSize);
    features(i, :) = vec;
    labels(i) = true;
end

%% procesem negatives
for i = 1:numNeg
    I   = imread(fullfile(negFolder, negFiles(i).name));
    vec = extractFeatures_SPONGEBOB(I, binCount, windowSize);
    features(numPos + i, :) = vec;
    labels(numPos + i) = false;
end

%% ens guardem les features i labels
outputFile = fullfile('.', 'spongebob_features1.mat');
save(outputFile, 'features', 'labels');
fprintf('Extracted %d feature vectors (%d pos, %d neg) and saved to %s.\n', ...
        total, numPos, numNeg, outputFile);
