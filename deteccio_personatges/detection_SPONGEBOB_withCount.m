function detection_SPONGEBOB()
%DETECTION_SPONGEBOB  Slide a window over an input image and count SpongeBob patches.
%
%   This function:
%     1) Prompts the user to select an image file (.jpg or .png).
%     2) Loads a trained model (exported from Classification Learner) 
%        stored in 'untitled.mat' (must contain a variable 'trainedModel').
%     3) Slides a 128×128 window (stride 16) over the image.
%     4) For each window, extracts the enhanced feature vector via 
%        extractFeatures_SPONGEBOB(patch, binCount, windowSize).
%     5) Converts that feature vector to a table row with column names taken
%        from modelStruct.RequiredVariables.
%     6) Calls predictFcn(T) to obtain [label, score].
%     7) If label=='true' and score(2) ≥ 1, increments a counter and displays
%        the patch (with its score) in a figure.
%     8) At the end, prints the total number of SpongeBob patches found.

    %% --- 1. Load image via uigetfile ---
    [file, path] = uigetfile({'*.jpg;*.png','Images (*.jpg,*.png)'}, 'Selecciona una imagen');
    if isequal(file,0)
        disp('No se seleccionó ningún archivo.');
        return;
    end
    imageFile = fullfile(path, file);

    %% --- 2. Load the trained model ---
    data = load('trainedModel_FineTree.mat');
    if ~isfield(data, 'trainedModel')
        error('The model file "untitled.mat" must contain a variable named ''trainedModel''.');
    end
    modelStruct = data.trainedModel;
    predictFcn   = modelStruct.predictFcn;
    varNames     = modelStruct.RequiredVariables;  % cell array of column names
    % We assume the positive class label was "true" during training.
    posClass     = "true";

    %% --- 3. Parameters (must match training) ---
    windowSize = [128 128];   % [height, width]
    binCount   = 32;          % number of bins for H, S, and V histograms in extractFeatures_SPONGEBOB
    step       = 16;          % sliding window stride

    %% --- 4. Read image and get dimensions ---
    I = imread(imageFile);
    [hI, wI, ~] = size(I);

    %% --- 5. Sliding window detection ---
    count = 0;
    for y = 1:step:(hI - windowSize(1))
        for x = 1:step:(wI - windowSize(2))
            rect  = [x, y, windowSize(2), windowSize(1)];
            patch = imcrop(I, rect);

            % 5.1 Extract features for this patch
            featVec = extractFeatures_SPONGEBOB(patch, binCount, windowSize);

            % 5.2 Build a one-row table with the required column names
            T = array2table(featVec, 'VariableNames', varNames);

            % 5.3 Predict label and score
            [label, score] = predictFcn(T);
            posScore = score(2);  % positive-class score

            % 5.4 If predicted label is 'true' and score ≥ 1, count & display
            if string(label) == posClass
                count = count + 1;
                figure;
                imshow(patch);
                title(sprintf('Patch with SpongeBob (score = %.3f)', posScore));
            end
        end
    end

    %% --- 6. Print total count ---
    fprintf('Number of SpongeBob patches found: %d\n', count);
end
