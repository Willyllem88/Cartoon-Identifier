function main()
    clear; clc; close all;
    load("seriesClassification.mat", "seriesClassificationModel")

    opcio = menuOpcions();

    switch opcio
        case 1
            predirImatgeIndividual(seriesClassificationModel);
        case 2
            predirImatgesTest(seriesClassificationModel);
        case 3
            predirImatgesDirectori(seriesClassificationModel);
        case 4
            predirEstadistiquesDirectori(seriesClassificationModel);
        otherwise
            disp('Opció no vàlida.');
    end
end

function opcio = menuOpcions()
    disp('Selecciona una opció:');
    disp('1. Classificar una imatge individual');
    disp('2. Classificar totes les imatges de test');
    disp('3. Classificar totes les imatges d''un directori');
    disp('4. Estadístiques de classificació d''un directori');
    opcio = input('Opció: ');
end

function predirImatgeIndividual(model)
    [file, path] = uigetfile({'*.jpg'}, 'Selecciona un archivo');
    if isequal(file, 0)
        disp('No se seleccionó ningún archivo.');
        return;
    end
    filePath = fullfile(path, file);

    I = imread(filePath);
    car = extreureCaracteristiques(I);
    Tnew = struct2table(car);

    [yfit, ~] = model.predictFcn(Tnew);

    disp(['S''ha predit que la imatge pertany: ', char(yfit)])

    % Pintar la imagen con una captio con el resultado de la prediccion
    figure;
    imshow(I);
    title(['Predicción: ', char(yfit)]);
end

function predirImatgesTest(model)
    disp('Executant el model amb totes les imatges de test... (pot trigar una estona)')
    traindir = './TEST';
    dirs = dir(traindir);
    
    hits = 0; fails = 0;
    
    for i = 1:length(dirs)
        name = dirs(i).name;
    
        if startsWith(name, '.'); continue; end
    
        files = dir(fullfile(traindir, name, '*.jpg'));
        for j = 1:length(files)
            imgPath = fullfile(files(j).folder, files(j).name);
    
            I = imread(imgPath);
    
            car = extreureCaracteristiques(I);
            Tnew = struct2table(car);
    
            [yfit, ~] = model.predictFcn(Tnew);
    
            if string(yfit) == string(name)
                hits = hits + 1;
            else
                fails = fails + 1;
            end
        end
    end
    
    disp('Resultats de la classificació:');
    disp(['Encerts: ', num2str(hits)]);
    disp(['Fallades: ', num2str(fails)]);
    disp(['Precisió: ', num2str(hits / (hits + fails) * 100), '%']);
end

function predirImatgesDirectori(model)
    disp('Selecciona un directori amb imatges per classificar, s''executaran aquelles imatges amb extensió *.jpg, *.jpeg i *.png.');
    dirPath = uigetdir(".", "Selecciona un directori d'imatges");

    if dirPath == 0
        disp('No s''ha seleccionat cap directori.');
        return;
    end

    % Agafar tots els fitxers jpg, jpeg i png
    exts = {'*.jpg', '*.jpeg', '*.png'};
    files = [];
    for k = 1:length(exts)
        files = [files; dir(fullfile(dirPath, exts{k}))];
    end

    if isempty(files)
        disp('No s''han trobat imatges en aquest directori.');
        return;
    end

    for i = 1:length(files)
        imgPath = fullfile(files(i).folder, files(i).name);
        I = imread(imgPath);

        car = extreureCaracteristiques(I);
        Tnew = struct2table(car);

        [yfit, ~] = model.predictFcn(Tnew);

        figure;
        imshow(I);
        title(['Predicció: ', char(yfit)]);

        % Esperar a que tanqui la finestra abans de continuar
        waitfor(gcf);
    end
end

function predirEstadistiquesDirectori(model)
    disp('Selecciona un directori amb imatges per classificar.');
    dirPath = uigetdir(".", "Selecciona un directori d'imatges");

    if dirPath == 0
        disp('No s''ha seleccionat cap directori.');
        return;
    end

    exts = {'*.jpg', '*.jpeg', '*.png'};
    files = [];
    for k = 1:length(exts)
        files = [files; dir(fullfile(dirPath, exts{k}))];
    end

    if isempty(files)
        disp('No s''han trobat imatges en aquest directori.');
        return;
    end

    % Inicialitzar comptadors per cada classe
    classes = ["barrufets","bob-esponja","gat-i-gos","gumball","hora-de-aventuras","oliver-y-benji","padre-de-familia","pokemon","southpark","tom-y-jerry"];
    counts = zeros(size(classes));

    for i = 1:length(files)
        imgPath = fullfile(files(i).folder, files(i).name);
        I = imread(imgPath);

        car = extreureCaracteristiques(I);
        Tnew = struct2table(car);

        [yfit, ~] = model.predictFcn(Tnew);

        idx = find(classes == string(yfit));
        if ~isempty(idx)
            counts(idx) = counts(idx) + 1;
        else
            disp(['Classe desconeguda: ', char(yfit)]);
        end
    end

    % Mostrar estadístiques
    disp('Estadístiques de classificació:');
    for i = 1:length(classes)
        disp([char(classes(i)), ': ', num2str(counts(i))]);
    end
end
