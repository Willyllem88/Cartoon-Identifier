% clasifier.m
clear; clc; close all;

traindir = './TRAIN';
testdir = './TEST';
traindirs = dir(traindir);
testdirs = dir(testdir);


%% TRAIN table creation
rows = []; % array de structs planos

for i = 1:length(traindirs)
    name = traindirs(i).name;

    if startsWith(name, '.'); continue; end

    files = dir(fullfile(traindir, name, '*.jpg'));
    for j = 1:length(files)
        imgPath = fullfile(files(j).folder, files(j).name);
        I = imread(imgPath);

        row = extreureCaracteristiques(I); % extracción ya plana
        row.Label = string(name); % añadimos etiqueta

        rows = [rows; row];
    end
end

T = struct2table(rows); % tabla lista para entrenar

%% TEST table creation
rows_test = [];

for i = 1:length(testdirs)
    name = testdirs(i).name;
    if startsWith(name, '.'); continue; end
    files = dir(fullfile(testdir, name, '*.jpg'));
    for j = 1:length(files)
        imgPath = fullfile(files(j).folder, files(j).name);
        I = imread(imgPath);
        row = extreureCaracteristiques(I);
        row.Label = string(name);
        rows_test = [rows_test; row];
    end
end

Ttest = struct2table(rows_test);

%% Obtain model
% Train a classifier using KNN with just 1 N
mdl = fitcknn(T, 'Label', 'NumNeighbors', 1);

% Predict labels for the entire test set
predictedLabels = predict(mdl, Ttest);
% Calculate accuracy
accuracy = sum(predictedLabels == Ttest.Label) / height(Ttest);
fprintf('Accuracy: %.2f%%\n', accuracy * 100);
