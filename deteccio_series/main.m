function main()
    load('trainedModel.mat', 'trainedModel');

    [file, path] = uigetfile({'*.jpg'}, 'Selecciona un archivo');
    if isequal(file, 0)
        disp('No se seleccionó ningún archivo.');
        return;
    end
    filePath = fullfile(path, file);

    I = imread(filePath);
    car = extreureCaracteristiques(I);
    Tnew = struct2table(car);

    [yfit, scores] = trainedModel.predictFcn(Tnew);
    disp(['Predicción: ', char(yfit)]);
    disp('Probabilidades:');
    disp(scores);
end

