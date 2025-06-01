%extract_features_spongebob.m
% Treu les featuers d'un patch de spongbob (o sigui, no una imatge
% ajustada, bounding box, del spongebob, sino un patch o tros del
% spongebob, com la pell, o els ulls, etc).
% Els descriptors que s'utiltizen son:
% 1) mitjana i std de H,S,V respectivament 
% 2) histogrames normalitzats per cada canal H,S,v respectivament
% 3) densitat de edges (amb canny)
% 4) LBP (local binary pattern) per textures, es un histograma amb 59 bins

function vec = extract_features_spongebob(I, binCount, windowSize)
    % fem resize a 128x128 (no faria falta, els patches ja son de 128x128)
    I = imresize(I, windowSize);

    % obtenim hsv
    Ihsv = rgb2hsv(I);
    H = Ihsv(:,:,1);
    S = Ihsv(:,:,2);
    V = Ihsv(:,:,3);

    % obtenim mesures hsv
    meanH = mean(H, 'all');
    sdH   = std(H, 0, 'all');
    meanS = mean(S, 'all');
    sdS   = std(S, 0, 'all');
    meanV = mean(V, 'all');
    sdV   = std(V, 0, 'all');

    % obtenim histogrames hsv
    histH = histcounts(H, binCount, 'Normalization', 'probability');
    histS = histcounts(S, binCount, 'Normalization', 'probability');
    histV = histcounts(V, binCount, 'Normalization', 'probability');

    % obtenim edge density
    grayI = rgb2gray(I);
    edges = edge(grayI, 'Canny');
    edgeDensity = sum(edges, 'all') / numel(edges);

    % obtenim LBP
    lbpFeatures = extractLBPFeatures(grayI, 'Upright', false, 'Normalization', 'None');
    
    % posem totes les features de l'imatge en un vector
    vec = [ ...
        meanH, sdH, ...
        meanS, sdS, ...
        meanV, sdV, ...
        histH, ...
        histS, ...
        histV, ...
        edgeDensity, ...
        lbpFeatures ...
    ];
end
