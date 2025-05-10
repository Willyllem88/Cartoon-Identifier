% clasifier.m
clear; clc; close all;

traindir = './TRAIN';
dirs = dir(traindir);

% struct array vacío
rows = struct('meanS', {}, 'sdS', {}, 'Hist', {}, 'Label', {});

for i = 1:length(dirs)
    name = dirs(i).name;

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
disp(T(1:5,:))


%% función local al final del script
function row = extreureCaracteristiques(I)
    IMAGE_SIZE = 128;

    I = imresize(I, [IMAGE_SIZE, IMAGE_SIZE]);
    Ihsv = rgb2hsv(I);

    meanS = mean(Ihsv(:,:,2), 'all');
    stdS = std(Ihsv(:,:,2), 0, 'all');

    hist = getHistogram(I);
    row = struct(...
      'meanS', meanS, ...
      'sdS', stdS, ...
      'Hist', hist ...
    );
end

%% función para obtener el histograma de la imagen
function hist = getHistogram(I)
    % Convertir la imagen a double y normalizar, eliminando así la iluminación
    % pasamos de RGB a rgb
    I = im2double(I);
    S = sum(I,3);
    S(S == 0) = 1;

    % Normalizar los canales r y g, ya que el canal B se puede deducir
    % a partir de los otros dos: b = 1 - r - g
    rgb(:,:,1) = I(:,:,1)./S;
    rgb(:,:,2) = I(:,:,2)./S;

    N = 32;
    edges = linspace(0, 1, N+1);
    
    hR = histcounts(rgb(:,:,1), edges);
    hG = histcounts(rgb(:,:,2), edges);

    hist = [hR hG];
end