function isThereCharacter = SpongeBodetection_SPONGEBOB(imageFile, sampleRate,threshold,doResize)
%SPONGEBODETECTION_SPONGEBOB  Slide a window over an input image and detect SpongeBob.
%
%   isThereCharacter = SpongeBodetection_SPONGEBOB(imageFile, sampleRate)
%   loads a trained model ('trainedModel_FineTree.mat'), then slides a 128×128
%   window (stride 16) over the image.  Rather than examining every window,
%   it only processes each window with probability sampleRate (0 < sampleRate ≤ 1).
%   For each sampled window, it extracts features, calls the classifier, and
%   counts positive detections.  Returns 1 if at least one positive patch was found,
%   otherwise 0.
%
%   INPUTS:
%     imageFile  - full path to the test image.
%     sampleRate - fraction of windows to actually evaluate (e.g., 0.2 for 20%).
%                  If omitted, defaults to 1 (i.e., examine every window).
%
%   EXAMPLE:
%     isChar = SpongeBodetection_SPONGEBOB('test.jpg', 0.5);  % 50% of windows

%NOTA: per fer que vagi mes rapid. fer resize, tot mateixa mida

    if nargin < 2
        sampleRate = 1;  % examine all windows by default
    end
    assert(sampleRate > 0 && sampleRate <= 1, 'sampleRate must be in (0,1].');

    %% --- 1. Load the trained model ---
    data = load('trainedModel_FineTree.mat');
    if ~isfield(data, 'trainedModel')
        error('The model file must contain a variable named ''trainedModel''.');
    end
    modelStruct = data.trainedModel;
    predictFcn   = modelStruct.predictFcn;
    varNames     = modelStruct.RequiredVariables;  % cell array of column names
    posClass     = "true";  % assume positive label is "true"

    %% --- 2. Parameters (must match training) ---
    windowSize = [128 128];   % [height, width]
    binCount   = 32;          % number of bins for HSV histograms
    step       = 16;          % sliding window stride

    %% --- 3. Read image and get dimensions ---
    I = imread(imageFile);
    [hI, wI, ~] = size(I);

    %% --- 4. Sliding window with sampling ---
    count = 0;
    for y = 1:step:(hI - windowSize(1))
        for x = 1:step:(wI - windowSize(2))
            if rand() > sampleRate
                continue;  % skip this window
            end

            rect  = [x, y, windowSize(2), windowSize(1)];
            patch = imcrop(I, rect);

            % 4.1 Extract features for this patch
            featVec = extractFeatures_SPONGEBOB(patch, binCount, windowSize);

            % 4.2 Build a one-row table with required column names
            T = array2table(featVec, 'VariableNames', varNames);

            % 4.3 Predict label and score
            [label, score] = predictFcn(T);
            posScore = score(2);

            % 4.4 If predicted label is positive, increment count
            if string(label) == posClass
                count = count + 1;
            end
            if count > 0 && count > threshold
                fprintf('SpongeBob found!  Count: >%d (sampleRate = %.2f)\n', count, sampleRate);
                isThereCharacter = 1;
                return
            end
        end
    end

    %% --- 5. Return result and print count ---
    if count > 0 && count > threshold
        fprintf('SpongeBob found!  Count: %d (sampleRate = %.2f)\n', count, sampleRate);
        isThereCharacter = 1;
    else
        fprintf('SpongeBob found not!  Count: %d (sampleRate = %.2f)\n', count, sampleRate);
        isThereCharacter = 0;
    end
end
