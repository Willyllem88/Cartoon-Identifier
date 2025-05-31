% build_patches.m
% Script to crop positive (SpongeBob) and negative patches
% from a groundTruth object saved in 'spongebob_occurances.mat'

%% --- User parameters ---
windowSize     = [128 128];   % [height width] of patches
positiveFolder = 'positives';  % output folder for positive patches
negativeFolder = 'negatives';  % output folder for negative patches
numNeg         = 104;         % number of negative patches to generate
maxOverlap     = 0.05;         % max allowed IoU with any SpongeBob bbox

%% --- Load pre-saved groundTruth object ---
% The MAT-file must contain a variable (e.g. 'gTruth') of type groundTruth
data = load('spongebob_occurances.mat');
% Attempt to find the groundTruth variable:
gtFields = fieldnames(data);
gTruthVar = '';
for k = 1:numel(gtFields)
    if isa(data.(gtFields{k}), 'groundTruth')
        gTruthVar = gtFields{k};
        break;
    end
end
assert(~isempty(gTruthVar), ...
    'spongebob_occurances.mat must contain a groundTruth object.');
gTruth = data.(gTruthVar);

%% --- Convert groundTruth to trainingData table ---
trainingData = objectDetectorTrainingData(gTruth);

% Identify which columns correspond to filenames and bboxes
vars = trainingData.Properties.VariableNames;
bboxesCol = '';
fnameCol  = '';
for iVar = 1:numel(vars)
    colData = trainingData.(vars{iVar});
    % bbox column: cell array of N×4 numeric arrays
    if iscell(colData) && all(cellfun(@(c) isnumeric(c) && size(c,2)==4, colData))
        bboxesCol = vars{iVar};
    end
    % filename column: cell array of strings or char vectors
    if (iscellstr(colData) || isstring(colData)) && isempty(fnameCol)
        fnameCol = vars{iVar};
    end
end
assert(~isempty(bboxesCol), 'No bounding‐box column found in trainingData.');
assert(~isempty(fnameCol),  'No filename column found in trainingData.');

defFiles  = trainingData.(fnameCol);   % N×1 cell array of image paths
defBBoxes = trainingData.(bboxesCol);  % N×1 cell array of M×4 bboxes

%% --- Create output directories ---
if ~exist(positiveFolder, 'dir')
    mkdir(positiveFolder);
end
if ~exist(negativeFolder, 'dir')
    mkdir(negativeFolder);
end

%% --- Generate Positive Patches ---
posCount = 0;
for i = 1:numel(defFiles)
    I = imread(defFiles{i});
    boxes = defBBoxes{i};  % M×4 array of [x y w h] for this image
    for j = 1:size(boxes, 1)
        patch = imcrop(I, boxes(j, :));
        patch = imresize(patch, windowSize);
        posCount = posCount + 1;
        imwrite(patch, fullfile(positiveFolder, sprintf('pos_%05d.jpg', posCount)));
    end
end
fprintf('Saved %d positive patches to "%s".\n', posCount, positiveFolder);

%% --- Generate Negative Patches ---
negCount = 0;
rng(0);
numImages = numel(defFiles);

while negCount < numNeg
    % Pick a random image index
    idx = randi(numImages);
    I   = imread(defFiles{idx});
    hI  = size(I, 1);
    wI  = size(I, 2);
    % Random top-left corner for a window of size windowSize
    y = randi(hI - windowSize(1));
    x = randi(wI - windowSize(2));
    rect = [x, y, windowSize];  % [x y width height]
    % Check overlap with any SpongeBob boxes in this image
    boxes = defBBoxes{idx};
    if isempty(boxes)
        accept = true;
    else
        overlaps = bboxOverlapRatio(rect, boxes);
        accept = all(overlaps <= maxOverlap);
    end
    if accept
        patch = imcrop(I, rect);
        negCount = negCount + 1;
        imwrite(patch, fullfile(negativeFolder, sprintf('neg_%05d.jpg', negCount)));
    end
end
fprintf('Saved %d negative patches to "%s".\n', negCount, negativeFolder);

% End of script
