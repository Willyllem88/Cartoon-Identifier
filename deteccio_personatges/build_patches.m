% build_patches.m
% Script to crop positive (SpongeBob) and negative patches
% from a groundTruth object exported by Image Labeler

%% --- User parameters ---
windowSize     = [128 128];   % [height width] of patches
positiveFolder = 'positives';  % output folder for positive patches
negativeFolder = 'negatives';  % output folder for negative patches
numNeg         = 2000;         % number of negative patches to generate
maxOverlap     = 0.1;         % max allowed IoU with any SpongeBob bbox

%% --- Load ground truth ---
gTruth = LabelingSpongebob;
trainingData = objectDetectorTrainingData(gTruth);

% Identify bounding box and filename columns
vars = trainingData.Properties.VariableNames;
bboxesCol = '';
fnameCol  = '';
for iVar = 1:numel(vars)
    colData = trainingData.(vars{iVar});
    if iscell(colData) && all(cellfun(@(c) isnumeric(c) && size(c,2)==4, colData))
        bboxesCol = vars{iVar};
    end
    if (iscellstr(colData) || isstring(colData)) && isempty(fnameCol)
        fnameCol = vars{iVar};
    end
end
assert(~isempty(bboxesCol),'No bbox column found');
assert(~isempty(fnameCol),'No filename column found');

defFiles = trainingData.(fnameCol);
defBBoxes = trainingData.(bboxesCol);

%% --- Create output directories ---
if ~exist(positiveFolder,'dir'), mkdir(positiveFolder); end
if ~exist(negativeFolder,'dir'), mkdir(negativeFolder); end

%% --- Generate Positive Patches ---
posCount = 0;
for i = 1:numel(defFiles)
    I     = imread(defFiles{i});
    boxes = defBBoxes{i};  % N x 4 matrix
    for j = 1:size(boxes,1)
        patch = imcrop(I, boxes(j,:));
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
    % Random image
    idx = randi(numImages);
    I   = imread(defFiles{idx});
    hI = size(I,1); wI = size(I,2);
    % Random location
    y = randi(hI-windowSize(1)); x = randi(wI-windowSize(2));
    rect = [x y windowSize];
    % Check overlap
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
