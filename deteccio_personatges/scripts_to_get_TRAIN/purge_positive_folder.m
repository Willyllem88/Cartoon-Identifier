% delete_non_yellow_images_with_ratio.m
% This script iterates over all images in a specified folder. For each image,
% it computes the approximate “amount” of yellow, white, and blue pixels.
% If (white + blue) pixels exceed a fraction of yellow pixels (controlled by
% ratioThreshold), the script deletes that image. Lowering ratioThreshold
% makes the deletion criterion easier to meet, so more images get deleted.

%% --- User Parameters ---
imageFolder     = 'positives';  % <-- Change this to your folder path
fileExtension   = '*.jpg';                % e.g. '*.jpg', '*.png', etc.

% Ratio threshold: delete if (white + blue) > ratioThreshold * (yellow)
% Default = 1.0 replicates the original “(white+blue) > yellow” rule.
% Lower values (e.g. 0.8, 0.5) will delete more images.
ratioThreshold = 0.5;

%% --- Color Thresholds (in HSV) ---
% These thresholds are approximate and may need tweaking for your data.

% Yellow thresholds:
hYellowMin = 0.10;   % hue lower bound (≈36°)
hYellowMax = 0.17;   % hue upper bound (≈61°)
sYellowMin = 0.40;   % saturation lower bound
vYellowMin = 0.50;   % value (brightness) lower bound

% White thresholds:
sWhiteMax = 0.20;    % saturation upper bound (low saturation → white/grey)
vWhiteMin = 0.80;    % value (high brightness → white)

% Blue thresholds:
hBlueMin = 0.50;     % hue lower bound (≈180°)
hBlueMax = 0.70;     % hue upper bound (≈252°)
sBlueMin = 0.40;     % saturation lower bound
vBlueMin = 0.20;     % value (brightness) lower bound

%% --- Fetch Image List ---
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

    % Read image
    I = imread(fullpath);
    if size(I,3) ~= 3
        fprintf('Skipping "%s" (not a 3‐channel RGB image).\n', filename);
        continue;
    end

    % Convert to HSV
    hsv = rgb2hsv(I);
    H = hsv(:,:,1);
    S = hsv(:,:,2);
    V = hsv(:,:,3);

    % Compute masks for each color category
    yellowMask = (H >= hYellowMin) & (H <= hYellowMax) & ...
                 (S >= sYellowMin) & (V >= vYellowMin);

    whiteMask = (S <= sWhiteMax) & (V >= vWhiteMin);

    blueMask = (H >= hBlueMin) & (H <= hBlueMax) & ...
               (S >= sBlueMin) & (V >= vBlueMin);

    % Count pixels in each category
    numYellow = nnz(yellowMask);
    numWhite  = nnz(whiteMask);
    numBlue   = nnz(blueMask);

    % Deletion condition with ratioThreshold
    if (numWhite + numBlue) > (ratioThreshold * numYellow)
        % Delete the file
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
