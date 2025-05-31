function detection_SPONGEBOB()
%DETECTION_SPONGEBOB Detect SpongeBob using a fine KNN model without score output.

    % --- Load image ---
    [file, path] = uigetfile({'*.jpg;*.png'}, 'Selecciona una imagen');
    if isequal(file, 0)
        disp('No se seleccionó ningún archivo.');
        return;
    end
    imageFile = fullfile(path, file);

    % --- Load model ---
    m = load('untitled.mat');
    if isfield(m, 'trainedModel')
        modelStruct = m.trainedModel;
    else
        error('Model file must contain ''trainedModel'' struct.');
    end

    predictFcn = modelStruct.predictFcn;
    varNames   = modelStruct.RequiredVariables;
    posClass   = "true";  % positive class label

    % --- Parameters ---
    windowSize = [128 128];  % [height, width]
    binCount   = 16;
    step       = 16;

    % --- Read image ---
    I = imread(imageFile);
    [hI, wI, ~] = size(I);

    bboxes = [];
    scores = [];

    % --- Sliding window detection ---
    count = 0;
    for y = 1:step:(hI - windowSize(1))
        for x = 1:step:(wI - windowSize(2))
            rect = [x, y, windowSize(2), windowSize(1)];
            patch = imcrop(I, rect);
            %figure, imshow(patch), title("patch");

            featVec = extractFeatures_SPONGEBOB(patch, binCount, windowSize);
            T = array2table(featVec, 'VariableNames', varNames);

            [label,score]= predictFcn(T);
            posScore = score(2);
            if string(label) == "true"
                %figure, imshow(patch), title('patch where spongebob')
                %fprintf('is spongebob!\n');

                % Display the patch where SpongeBob was found:
                figure; imshow(patch);
                title(sprintf('Patch with SpongeBob (score = %.3f)', posScore));

                % Print to Command Window:
                %fprintf('SpongeBob found at window starting [x=%d, y=%d]\n', x, y);
                %fprintf('Positive‐class score = %.3f\n', posScore)
                %return
                count = count + 1;
            end
            %if string(label) == "true"
            %    bboxes(end+1, :) = rect;
            %    scores(end+1, 1) = 1;  % use constant score for binary classification
            %end
        end
    end
    fprintf('number of spongebobs found: %d\n', count);
    %fprintf('spongebob not found :(\n');
end
