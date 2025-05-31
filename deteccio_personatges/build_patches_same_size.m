% build_patches_same_size.m
% Script to crop a fixed number of positive (SpongeBob) and negative patches
% (all of identical size) from a groundTruth object saved in 'spongebob_occurances.mat'.
% Positive patches: window‐size subwindows fully contained within annotated bboxes.
% Negative patches: random windows of the same size with IoU ≤ maxOverlap to any bbox.

%% --- User parameters ---
windowSize     = [128 128];   % [height width] of desired patches
positiveFolder = 'positives';  % output folder for positive patches
negativeFolder = 'negatives';  % output folder for negative patches
numPos         = 5000;         % number of positive patches to generate
numNeg         = 5000;         % number of negative patches to generate
maxOverlap     = 0.05;        % max allowed IoU with any SpongeBob bbox for negatives

%% --- Load pre-saved groundTruth object ---
data = load('spongebob_occurances.mat');
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

%% --- Generate Candidate Positive Windows ---
% For each annotated bbox (of SpongeBob), generate all possible window‐sized
% subwindows that fit entirely inside. Collect them across all images.

candidates = struct('imgIdx', {}, 'rect', {});  % list of structs with fields imgIdx & rect

winH = windowSize(1);
winW = windowSize(2);

for imgIdx = 1:numel(defFiles)
    boxes = defBBoxes{imgIdx};  % M×4 array: [bx by bw bh] for that image
    for b = 1:size(boxes,1)
        bbox = boxes(b,:);      % [bx by bw bh]
        bx = bbox(1); by = bbox(2);
        bw = bbox(3); bh = bbox(4);
        % Only proceed if bbox is at least as large as windowSize
        if bw >= winW && bh >= winH
            % Range of top-left x positions inside bbox
            x_start = bx;
            x_end   = bx + bw - winW;
            y_start = by;
            y_end   = by + bh - winH;
            c = struct('imgIdx', [], 'rect', []);
            for yy = y_start : y_end
                for xx = x_start : x_end
                    % Each subwindow is [xx, yy, winW, winH]
                    c.imgIdx = imgIdx;
                    c.rect   = [xx, yy, winW, winH];
                    candidates(end+1) = c;  %#ok<SAGROW>
                end
            end
        end
    end
end

totalCandidates = numel(candidates);
if totalCandidates == 0
    error('No valid window‐sized subwindows found inside annotated bboxes.');
end

% Sample up to numPos from these candidates
rng(0);  % for reproducibility
if numPos >= totalCandidates
    selected = 1:totalCandidates;
    if numPos > totalCandidates
        warning('Requested %d positives but only %d candidates available. Using all.', ...
            numPos, totalCandidates);
    end
else
    perm = randperm(totalCandidates, numPos);
    selected = perm;
end

%% --- Generate and Save Positive Patches ---
posCount = 0;
for k = 1:numel(selected)
    cand = candidates(selected(k));
    I = imread(defFiles{cand.imgIdx});
    patch = imcrop(I, cand.rect);
    posCount = posCount + 1;
    imwrite(patch, fullfile(positiveFolder, sprintf('pos_%05d.jpg', posCount)));
end
fprintf('Saved %d positive patches to "%s".\n', posCount, positiveFolder);

%% --- Generate Negative Patches ---
negCount = 0;
rng(0);  % reproducible negatives
numImages = numel(defFiles);

while negCount < numNeg
    % Pick a random image
    imgIdx = randi(numImages);
    I      = imread(defFiles{imgIdx});
    hI     = size(I,1);
    wI     = size(I,2);

    % Random top-left corner for windowSize
    y = randi(hI - winH + 1);
    x = randi(wI - winW + 1);
    rect = [x, y, winW, winH];

    % Check overlap with all annotated bboxes in this image
    boxes = defBBoxes{imgIdx};  % M×4
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
