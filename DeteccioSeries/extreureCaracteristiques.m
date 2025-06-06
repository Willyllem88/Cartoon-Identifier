%% función local al final del script
function row = extreureCaracteristiques(I)
    IMAGE_SIZE = 128;

    I = imresize(I, [IMAGE_SIZE, IMAGE_SIZE]);
    Ihsv = rgb2hsv(I);

    meanS = mean(Ihsv(:,:,2), 'all');
    sdS = std(Ihsv(:,:,2), 0, 'all');
    meanV = mean(Ihsv(:,:,3), 'all');
    sdV = std(Ihsv(:,:,3), 0, 'all');
    hist = getHistogram(I);
    edgeDensity = getEdgeDensity(I);
    tex = getTextureFeatures(I);
    shp = getShapeFeatures(I);

    % Construir un struct plano con todos los campos, sin anidar histogram
    row = struct();
    row.meanS = meanS;
    row.sdS = sdS;
    row.meanV = meanV;
    row.sdV = sdV;
    for k = 1:numel(hist)
        row.(sprintf('hist%d', k)) = hist(k);
    end
    row.edgeDensity = edgeDensity;
    
    row.texContrast = tex.contrast;
    row.texCorrelation = tex.correlation;
    row.texEnergy = tex.energy;
    row.texHomogeneity = tex.homogeneity;
    row.shpArea = shp.area;
    row.shpEccentricity = shp.eccentricity;
    row.shpExtent = shp.extent;
    row.shpSolidity = shp.solidity;
end

%% función para obtener el histograma de la imagen
function hist = getHistogram(I)
    % Convertir la imagen a double y normalizar, eliminando así la iluminación
    % pasamos de RGB a rgb
    I = im2double(I);
    S = sum(I,3);
    S(S == 0) = 1;

    % Normalizar los canales r y g, ya que el canal B se puede deducir
    % a partir de los otros dos: b = 1 - r - g
    rgb(:,:,1) = I(:,:,1)./S;
    rgb(:,:,2) = I(:,:,2)./S;

    N = 48;
    edges = linspace(0, 1, N+1);
    
    hR = histcounts(rgb(:,:,1), edges);
    hG = histcounts(rgb(:,:,2), edges);

    hist = [hR hG];
end

%% función para calcular la desnidad de bordes
function edgeDensity = getEdgeDensity(I)
    edges = edge(rgb2gray(I),'Canny');
    edgeDensity = mean(edges,'all');
end

%% Características de textura: GLCM (contrast, correlation, energy, homogeneity)
function tex = getTextureFeatures(I)
    Igray = im2gray(I);
    % Generar matriz de co-ocurrencia de nivel de gris
    offsets = [0 1; -1 1; -1 0; -1 -1];
    glcm = graycomatrix(Igray, 'Offset', offsets, 'Symmetric', true);
    stats = graycoprops(glcm, {'Contrast','Correlation','Energy','Homogeneity'});
    % Promediar estadísticas de los diferentes offsets
    tex = struct(...
      'contrast', mean(stats.Contrast), ...
      'correlation', mean(stats.Correlation), ...
      'energy', mean(stats.Energy), ...
      'homogeneity', mean(stats.Homogeneity) ...
    );
end

%% Características de forma: segmentación y propiedades geométricas
function shp = getShapeFeatures(I)
    Igray = im2gray(I);
    % Segmentación por umbral de Otsu
    level = graythresh(Igray);
    BW = imbinarize(Igray, level);
    % Limpieza: rellenar agujeros y eliminar objetos pequeños
    BW = imfill(BW, 'holes');
    BW = bwareaopen(BW, 50);
    % Propiedades geométricas
    props = regionprops(BW, 'Area','Eccentricity','Extent','Solidity');
    if isempty(props)
        % Si no hay regiones, asignar ceros
        shp = struct('area',0,'eccentricity',0,'extent',0,'solidity',0);
    else
        % Calcular promedio de cada propiedad
        areas = [props.Area];
        eccs  = [props.Eccentricity];
        exts  = [props.Extent];
        sols  = [props.Solidity];
        shp = struct(...
          'area', mean(areas), ...
          'eccentricity', mean(eccs), ...
          'extent', mean(exts), ...
          'solidity', mean(sols) ...
        );
    end
end
