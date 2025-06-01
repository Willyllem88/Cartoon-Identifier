% detection_spongebob.m
% Script que, donada una imatge de la serie spongebob, retorna si hi es o
% no el personatge del spongebob (retorna isThereCharacter).

% Algoritme: es basa en, iterar sobre un percentatge de totes les windows (o patches) 
% de 128x128 de l'imatge. per cada patch, apliquem un trainedModel que ens diu
% que el patch es del spongebob o no. Finalment, si a l'imatge trobem com a
% minim un cert nombre de spongebob patches. retornem que si que hi es, en
% cas contrari, diem que no.

% Parametres:
% 1) sampleRate: indica el percentatge de windows o patches de 128x128 que
% es tindran en compte (0 <= sampleRate <= 1)
% 2) threshold: indica quants patches han de ser del spongebob com a minim
% per tal que valorar que a la imatge SI hi ha un spongebob.

function isThereCharacter = detection_spongebob(imageFile, sampleRate,threshold)
    %% carraguem el trainedModel (que detecta si un patch de 128x128 es del spongebob)
    data = load('trainedModel_FineTree.mat');
    if ~isfield(data, 'trainedModel')
        error('The model file must contain a variable named ''trainedModel''.');
    end
    modelStruct = data.trainedModel;
    predictFcn   = modelStruct.predictFcn;
    varNames     = modelStruct.RequiredVariables;  % cell array of column names
    posClass     = "true";  % assume positive label is "true"

    %% parametres de les featuers (que son iguals que al training)
    windowSize = [128 128];   % [height, width]
    binCount   = 32;          % number of bins for HSV histograms
    step       = 16;          % sliding window stride

    %% read image
    I = imread(imageFile);
    [hI, wI, ~] = size(I);

    %% iterem sobre un percentatge de windows
    count = 0;
    for y = 1:step:(hI - windowSize(1))
        for x = 1:step:(wI - windowSize(2))
            if rand() > sampleRate
                continue;  % skip this window
            end

            rect  = [x, y, windowSize(2), windowSize(1)];
            patch = imcrop(I, rect);

            % obtenim featuers del patch actual
            featVec = extract_features_spongebob(patch, binCount, windowSize);

            % construim la taula
            T = array2table(featVec, 'VariableNames', varNames);

            % fem la prediccio amb el model
            [label, score] = predictFcn(T);
            posScore = score(2);

            % si el model prediu que es bob esponja, augmentem contador
            if string(label) == posClass
                count = count + 1;
            end
            if count > 0 && count > threshold
                fprintf('SpongeBob found!  Number of spongebob windows found: >%d\n', count);
                isThereCharacter = 1;
                return
            end
        end
    end

    %% imprimim els resultats
    if count > 0 && count > threshold
        fprintf('SpongeBob found!  Number of spongebob windows found: %d\n', count);
        isThereCharacter = 1;
    else
        fprintf('SpongeBob NOT found!  Number of spongebob windows found: %d\n', count);
        isThereCharacter = 0;
    end
end
