% test_folder_spongebob.m
% Script que demana a l'usuari una carpeta d'entrada, amb subfolders 
% "positives" i "negatives" (amb imatges on apareix o no el spongebob
%  respectivament), i itera sobre totes les imatges, aplica la prediccio.
%  per cada foto es guarda si es correcte, o fals positiu o fals negatiu, i
%  finalment s'ensenya a la terminal la matriu de confussio.

%% demanar a l'usuari la carpeta
parentFolder = uigetdir(pwd, 'Select the folder containing "positives" and "negatives"');
if isequal(parentFolder, 0)
    disp('No folder selected');
    return;
end

threshold = 2;
sampleRate = 0.15;
fprintf('Sample rate used to select windows (percentage of 128x128 windows tested): %d\n', sampleRate)
fprintf('Minimum number of windows with spongebob occurance to tell if spongebob is: %d\n', threshold)

%% definim positives i negatives subfolders
posFolder = fullfile(parentFolder, 'positives');
negFolder = fullfile(parentFolder, 'negatives');

if ~isfolder(posFolder) || ~isfolder(negFolder)
    error('Selected folder must contain subfolders named "positives" and "negatives".');
end

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

%% inicialitzar contadors
TP = 0;  % true positives
FN = 0;  % false negatives
FP = 0;  % false positives
TN = 0;  % true negatives

%% processar imatges positives
fprintf('=== Starting test of positives folder ===\n')
for i = 1:numPos
    imageFile = fullfile(posFolder, posFiles(i).name);
    try
        result = detection_spongebob(imageFile,sampleRate,threshold);  % should return 0 or 1
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

%% processar imatges negatives
fprintf('=== Starting test of negatives folder ===\n')
for i = 1:numNeg
    imageFile = fullfile(negFolder, negFiles(i).name);
    try
        result = detection_spongebob(imageFile,sampleRate,threshold);
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

%% calcular accuracy
totalImages = TP + TN + FP + FN;
accuracy = (TP + TN) / totalImages * 100;

%% mostrar resultats (accuracy i confusion matrix)
fprintf('\nEvaluation Results:\n');
fprintf('  True Positives  (TP): %d\n', TP);
fprintf('  False Negatives (FN): %d\n', FN);
fprintf('  False Positives (FP): %d\n', FP);
fprintf('  True Negatives  (TN): %d\n', TN);
fprintf('  Total images       : %d\n', totalImages);
fprintf('  Accuracy           : %.2f%%\n', accuracy);

confMat = [TP, FN;
           FP, TN];
disp('Confusion Matrix (rows=actual [Positive; Negative], columns=predicted [Positive, Negative]):');
disp(array2table(confMat, ...
    'VariableNames', {'Pred_Pos', 'Pred_Neg'}, ...
    'RowNames',      {'Actual_Pos', 'Actual_Neg'}));
