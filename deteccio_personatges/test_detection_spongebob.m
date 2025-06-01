% evaluate_detection.m
% Script to evaluate SpongeBob detection on "positives" and "negatives" folders.
%
% The user selects a parent directory that contains two subfolders:
%   • "positives" – images where SpongeBob appears
%   • "negatives" – images where SpongeBob does not appear
%
% For each image, the script calls
%   result = detection_SPONGEBOB_withCount(imageFile);
% which should return 1 (true) if SpongeBob is detected, or 0 (false) otherwise.
%
% The script then computes overall accuracy and displays a confusion matrix.

%NOTA: per fer que vagi mes rapid. fer resize, tot mateixa mida

%% --- Prompt user for parent folder ---
parentFolder = uigetdir(pwd, 'Select the folder containing "positives" and "negatives"');
if isequal(parentFolder, 0)
    disp('No folder selected. Exiting.');
    return;
end

threshold = 2;
sampleRate = 0.15;
doResize = 0;

%% --- Define positive and negative subfolders ---
posFolder = fullfile(parentFolder, 'positives');
negFolder = fullfile(parentFolder, 'negatives');

if ~isfolder(posFolder) || ~isfolder(negFolder)
    error('Selected folder must contain subfolders named "positives" and "negatives".');
end

%% --- Gather positive and negative image file lists ---
% Accept common image extensions
posJPG = dir(fullfile(posFolder, '*.jpg'));
posPNG = dir(fullfile(posFolder, '*.png'));
posFiles = [posJPG; posPNG];

negJPG = dir(fullfile(negFolder, '*.jpg'));
negPNG = dir(fullfile(negFolder, '*.png'));
negFiles = [negJPG; negPNG];

numPos = numel(posFiles);
numNeg = numel(negFiles);
if numPos == 0 && numNeg == 0
    error('No .jpg or .png files found in either "positives" or "negatives" folders.');
end

%% --- Initialize confusion counts ---
TP = 0;  % True Positives   (positive image, detected = 1)
FN = 0;  % False Negatives  (positive image, detected = 0)
FP = 0;  % False Positives  (negative image, detected = 1)
TN = 0;  % True Negatives   (negative image, detected = 0)

%% --- Process positive images ---
for i = 1:numPos
    imageFile = fullfile(posFolder, posFiles(i).name);
    try
        result = detection_SPONGEBOB_withCount(imageFile,sampleRate,threshold,doResize);  % should return 0 or 1
    catch ME
        warning('Error running detection on "%s": %s', posFiles(i).name, ME.message);
        continue;
    end
    if result == 1
        TP = TP + 1;
    else
        FN = FN + 1;
    end
end

%% --- Process negative images ---
for i = 1:numNeg
    imageFile = fullfile(negFolder, negFiles(i).name);
    try
        result = detection_SPONGEBOB_withCount(imageFile,sampleRate,threshold,doResize);
    catch ME
        warning('Error running detection on "%s": %s', negFiles(i).name, ME.message);
        continue;
    end
    if result == 1
        FP = FP + 1;
    else
        TN = TN + 1;
    end
end

%% --- Compute accuracy ---
totalImages = TP + TN + FP + FN;
accuracy = (TP + TN) / totalImages * 100;

%% --- Display results ---
fprintf('\nEvaluation Results:\n');
fprintf('  True Positives  (TP): %d\n', TP);
fprintf('  False Negatives (FN): %d\n', FN);
fprintf('  False Positives (FP): %d\n', FP);
fprintf('  True Negatives  (TN): %d\n', TN);
fprintf('  Total images       : %d\n', totalImages);
fprintf('  Accuracy           : %.2f%%\n', accuracy);

% Construct and display confusion matrix
confMat = [TP, FN;  % actual positive:   [predicted positive, predicted negative]
           FP, TN]; % actual negative:   [predicted positive, predicted negative]
disp('Confusion Matrix (rows=actual [Positive; Negative], columns=predicted [Positive, Negative]):');
disp(array2table(confMat, ...
    'VariableNames', {'Pred_Pos', 'Pred_Neg'}, ...
    'RowNames',      {'Actual_Pos', 'Actual_Neg'}));
