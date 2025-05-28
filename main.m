[file, path] = uigetfile({'*.jpg'}, 'Selecciona un archivo');
if isequal(file, 0)
    disp('No se seleccionó ningún archivo.');
    return;
end
I = imread(fullfile(path, file));

% Extraer características y convertir a tabla
feat = extreureCaracteristiques(I);
row = struct();
row.meanS = feat.meanS;
row.sdS = feat.sdS;
row.meanV = feat.meanV;
row.sdV = feat.sdV;
for k = 1:numel(feat.histogram)
    row.(sprintf('hist%d', k)) = feat.histogram(k);
end
row.edgeDensity = feat.edgeDensity;
row.Label = ""; % Dummy label
Tnew = struct2table(row);

% Predicción con salida extendida
[label, scores, cost] = predict(mdl, Tnew);

disp(['Predicción: ', char(label)]);
disp(['Coste: ', num2str(cost)]);
disp('Puntuaciones:');
disp(scores);

% Calcular distancia al vecino más cercano (outlier detection)
xq = Tnew{1, mdl.PredictorNames};          % Vector fila
Xtrain = table2array(mdl.X);               % Convertir tabla a matriz numérica

dists = vecnorm(Xtrain - xq, 2, 2);       % Distancias euclídeas
[minDist, idx] = min(dists);

disp(['Distancia al vecino más cercano: ', num2str(minDist)]);
disp(['Clase del vecino más cercano: ', char(mdl.Y(idx))]);
