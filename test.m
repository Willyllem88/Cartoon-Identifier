load('trainedModel.mat', 'trainedModel');

traindir = './TEST';
dirs = dir(traindir);

disp('Variables requeridas por el modelo:');
disp(trainedModel.RequiredVariables);

hits = 0;
fails = 0;

for i = 1:length(dirs)
    name = dirs(i).name;

    if startsWith(name, '.'); continue; end

    files = dir(fullfile(traindir, name, '*.jpg'));
    for j = 1:length(files)
        imgPath = fullfile(files(j).folder, files(j).name);

        I = imread(imgPath);

        car = extreureCaracteristiques(I);
        Tnew = struct2table(car);

        [yfit, scores] = trainedModel.predictFcn(Tnew);

        if string(yfit) == string(name)
            hits = hits + 1;
        else
            fails = fails + 1;
        end
    end
end

disp('Resultados de la clasificación:');
disp(['Aciertos: ', num2str(hits)]);
disp(['Fallos: ', num2str(fails)]);
disp(['Precisión: ', num2str(hits / (hits + fails) * 100), '%']);
