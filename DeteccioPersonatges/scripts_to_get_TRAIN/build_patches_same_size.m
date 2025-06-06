% build_patches_same_size.m
% Script que ha generat les imatges de TRAIN:
%
% ·S'accedeix a spongebob_occurances.mat (fet gracies a
% imageLabeler de matlab) que conte les imatges donades de la serie
% spongebob pero amb les ocurrencies del spongebob labeled (i tambe mes 
% que hem afegit nosaltres: aixo es mes explicat a 
% ../spongebob_dataset/extended_spongebob_dataset)
%
% ·A partir de spongebob_occurances.mat, es generen patches de mida 128x128
% de les imatges. es generen 5000 patches QUE FORMEN PART del spongebob, i
% 5000 patches que NO FORMEN PART de spongebob.
%
% ·Les imatges generades amb aixo son les del TRAIN

%% parametres
windowSize     = [128 128]; % [height width] del patch
positiveFolder = 'positives'; % output folder per patches positius
negativeFolder = 'negatives'; % output folder per patches negatius
numPos         = 5000; % numero patches positius ha generar
numNeg         = 5000; % numero patches negatius ha generar
maxOverlap     = 0.05; % overlap entre patches diferents maxim

%% carraguem ocurrencies
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

%% conversions
trainingData = objectDetectorTrainingData(gTruth);

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
assert(~isempty(bboxesCol), 'No bounding‐box column found in trainingData.');
assert(~isempty(fnameCol),  'No filename column found in trainingData.');

defFiles  = trainingData.(fnameCol);
defBBoxes = trainingData.(bboxesCol);

%% creem els directoris positives i negatives
if ~exist(positiveFolder, 'dir')
    mkdir(positiveFolder);
end
if ~exist(negativeFolder, 'dir')
    mkdir(negativeFolder);
end

%% generem patches positius

candidates = struct('imgIdx', {}, 'rect', {});

winH = windowSize(1);
winW = windowSize(2);

for imgIdx = 1:numel(defFiles)
    boxes = defBBoxes{imgIdx};
    for b = 1:size(boxes,1)
        bbox = boxes(b,:);
        bx = bbox(1); by = bbox(2);
        bw = bbox(3); bh = bbox(4);
        if bw >= winW && bh >= winH
            x_start = bx;
            x_end   = bx + bw - winW;
            y_start = by;
            y_end   = by + bh - winH;
            c = struct('imgIdx', [], 'rect', []);
            for yy = y_start : y_end
                for xx = x_start : x_end
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

rng(0);
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

posCount = 0;
for k = 1:numel(selected)
    cand = candidates(selected(k));
    I = imread(defFiles{cand.imgIdx});
    patch = imcrop(I, cand.rect);
    posCount = posCount + 1;
    imwrite(patch, fullfile(positiveFolder, sprintf('pos_%05d.jpg', posCount)));
end
fprintf('Saved %d positive patches to "%s".\n', posCount, positiveFolder);

%% generem patches negatius
negCount = 0;
rng(0);
numImages = numel(defFiles);

while negCount < numNeg
    imgIdx = randi(numImages);
    I      = imread(defFiles{imgIdx});
    hI     = size(I,1);
    wI     = size(I,2);

    y = randi(hI - winH + 1);
    x = randi(wI - winW + 1);
    rect = [x, y, winW, winH];

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