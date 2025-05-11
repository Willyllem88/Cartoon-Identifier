% clasifier.m
clear; clc; close all;

traindir = './TRAIN';
testdir = './TEST';
traindirs = dir(traindir);
testdirs = dir(testdir);


%% TRAIN table creation
rows = struct('meanS', {}, 'sdS', {}, 'meanV', {}, 'sdV', {}, 'histogram', {}, 'edgeDensity', {}, 'Label', {});
for i = 1:length(traindirs)
    name = traindirs(i).name;

    if startsWith(name, '.'); continue; end

    files = dir(fullfile(traindir, name, '*.jpg'));
    for j = 1:length(files)
        imgPath = fullfile(files(j).folder, files(j).name);

        I = imread(imgPath);

        row = extreureCaracteristiques(I);
        row.Label = string(name);

        rows(end+1) = row;
    end
end
T = struct2table(rows);

%% TEST table creation
rows = struct('meanS', {}, 'sdS', {}, 'meanV', {}, 'sdV', {}, 'histogram', {}, 'edgeDensity', {}, 'Label', {});
for i = 1:length(testdirs)
    name = testdirs(i).name;

    if startsWith(name, '.'); continue; end

    files = dir(fullfile(testdir, name, '*.jpg'));
    for j = 1:length(files)
        imgPath = fullfile(files(j).folder, files(j).name);

        I = imread(imgPath);

        row = extreureCaracteristiques(I);
        row.Label = string(name);

        rows(end+1) = row;
    end
end
Ttest = struct2table(rows);

