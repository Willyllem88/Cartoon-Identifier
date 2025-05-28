function vec = extractFeatures_SPONGEBOB(I, binCount, windowSize)
% extractFeatures  Extracts handcrafted features for SpongeBob detection
%   vec = extractFeatures(I, binCount, windowSize) resizes the RGB image I to
%   windowSize, computes color moments (mean & std of S and V channels in HSV),
%   a normalized hue histogram with binCount bins, and the edge density.

    % Resize to consistent window size
    I = imresize(I, windowSize);
    % Convert to HSV
    Ihsv = rgb2hsv(I);
    S = Ihsv(:,:,2);
    V = Ihsv(:,:,3);

    % 1) Color moments
    meanS = mean(S, 'all');
    sdS   = std(S, 0, 'all');
    meanV = mean(V, 'all');
    sdV   = std(V, 0, 'all');

    % 2) Hue histogram (normalized)
    H = Ihsv(:,:,1);
    histH = histcounts(H, binCount, 'Normalization', 'probability');

    % 3) Edge density (Canny detector)
    grayI = rgb2gray(I);
    edges = edge(grayI, 'Canny');
    edgeDensity = sum(edges, 'all') / numel(edges);

    % Combine into a single feature vector
    vec = [meanS, sdS, meanV, sdV, histH, edgeDensity];
end
