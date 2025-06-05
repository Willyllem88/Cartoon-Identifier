% purge_positive_folder.m
% Itera per totes les imatges d'una carpeta especificada. Per a cada imatge,
% calcula aproximadament la quantitat de pixels grocs, blancs i blaus.
% Si els píxels (blancs + blaus) superen una fraccio dels grocs (donada per
% ratioThreshold), l'script elimina aquesta imatge.

%% Parametres de l'usuari
imageFolder     = 'positives'; %cal canviar la ruta
fileExtension   = '*.jpg';

% Llindar de ratio: s'elimina si (blancs + blaus) > ratioThreshold * (grocs)
ratioThreshold = 0.5;

%% Llindars de color en HSV

%llindars groc
hYellowMin = 0.10; %36 graus
hYellowMax = 0.17; %61 graus
sYellowMin = 0.40;
vYellowMin = 0.50;

%llindars blanc
sWhiteMax = 0.20;
vWhiteMin = 0.80;

%llindars blau
hBlueMin = 0.50; %180 graus
hBlueMax = 0.70; %252 graus
sBlueMin = 0.40;     % límit inferior de saturació
vBlueMin = 0.20;     % límit inferior de valor (brillantor)

%% Obtenir llista d’imatges
imageFiles = dir(fullfile(imageFolder, fileExtension));
numFiles = numel(imageFiles);
if numFiles == 0
    warning('No images with extension %s found in folder "%s".', fileExtension, imageFolder);
    return;
end

deletedCount = 0;
fprintf('Processing %d images in "%s"...\n', numFiles, imageFolder);

for k = 1:numFiles
    filename = imageFiles(k).name;
    fullpath = fullfile(imageFolder, filename);

    %llegeix la imatge
    I = imread(fullpath);
    if size(I,3) ~= 3
        fprintf('Skipping "%s" (not a 3‐channel RGB image).\n', filename);
        continue;
    end

    %converteix a HSV
    hsv = rgb2hsv(I);
    H = hsv(:,:,1);
    S = hsv(:,:,2);
    V = hsv(:,:,3);

    yellowMask = (H >= hYellowMin) & (H <= hYellowMax) & ...
                 (S >= sYellowMin) & (V >= vYellowMin);

    whiteMask = (S <= sWhiteMax) & (V >= vWhiteMin);

    blueMask = (H >= hBlueMin) & (H <= hBlueMax) & ...
               (S >= sBlueMin) & (V >= vBlueMin);

    %compta pixels
    numYellow = nnz(yellowMask);
    numWhite  = nnz(whiteMask);
    numBlue   = nnz(blueMask);

    %conidicio per eliminar o no
    if (numWhite + numBlue) > (ratioThreshold * numYellow)
        % Elimina el fitxer
        delete(fullpath);
        deletedCount = deletedCount + 1;
        fprintf('Deleted "%s": (yellow=%d, white=%d, blue=%d)\n', ...
                filename, numYellow, numWhite, numBlue);
    else
        fprintf('Kept    "%s": (yellow=%d, white=%d, blue=%d)\n', ...
                filename, numYellow, numWhite, numBlue);
    end
end

fprintf('\nFinished. Deleted %d out of %d images (ratioThreshold=%.2f).\n', ...
        deletedCount, numFiles, ratioThreshold);
