%% función local al final del script
function row = extreureCaracteristiques(I)
    IMAGE_SIZE = 128;

    I = imresize(I, [IMAGE_SIZE, IMAGE_SIZE]);
    Ihsv = rgb2hsv(I);

    meanS = mean(Ihsv(:,:,2), 'all');
    stdS = std(Ihsv(:,:,2), 0, 'all');
    hist = getHistogram(I);
    edgeDensity = getEdgeDensity(I);

    row = struct(...
      'meanS', meanS, ...
      'sdS', stdS, ...
      'histogram', hist, ...
      'edgeDensity', edgeDensity ...
    );
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

    N = 32;
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