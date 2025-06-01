% extractFeatures_SPONGEBOB.m
% Enhanced feature extraction for SpongeBob detection, including:
%   • Color moments (mean & std of H, S, V)
%   • Separate normalized histograms for H, S, and V channels
%   • Edge density (Canny)
%   • Local Binary Pattern (LBP) histogram (59-bin "uniform" patterns)

function vec = extractFeatures_SPONGEBOB(I, binCount, windowSize)
    % Resize to consistent window size
    I = imresize(I, windowSize);

    % Convert to HSV
    Ihsv = rgb2hsv(I);
    H = Ihsv(:,:,1);
    S = Ihsv(:,:,2);
    V = Ihsv(:,:,3);

    % ---------------------------------------------------------------------
    % 1) Color moments (mean & std) for H, S, V
    % ---------------------------------------------------------------------
    meanH = mean(H, 'all');
    sdH   = std(H, 0, 'all');
    meanS = mean(S, 'all');
    sdS   = std(S, 0, 'all');
    meanV = mean(V, 'all');
    sdV   = std(V, 0, 'all');

    % ---------------------------------------------------------------------
    % 2) Normalized histograms for H, S, V (each with binCount bins)
    % ---------------------------------------------------------------------
    histH = histcounts(H, binCount, 'Normalization', 'probability');
    histS = histcounts(S, binCount, 'Normalization', 'probability');
    histV = histcounts(V, binCount, 'Normalization', 'probability');

    % ---------------------------------------------------------------------
    % 3) Edge density via Canny on grayscale
    % ---------------------------------------------------------------------
    grayI = rgb2gray(I);
    edges = edge(grayI, 'Canny');
    edgeDensity = sum(edges, 'all') / numel(edges);

    % ---------------------------------------------------------------------
    % 4) Local Binary Pattern (LBP) histogram
    %    Uses default 'Uniform' LBP with radius=1, neighbors=8, producing 59 bins
    % ---------------------------------------------------------------------
    % Make sure you have the Computer Vision Toolbox for extractLBPFeatures
    lbpFeatures = extractLBPFeatures(grayI, 'Upright', false, 'Normalization', 'None');
    % extractLBPFeatures returns a 1×59 feature vector for 'Uniform' patterns

    % ---------------------------------------------------------------------
    % 5) Combine all features into a single row vector
    % ---------------------------------------------------------------------
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
