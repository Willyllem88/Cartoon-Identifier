[file, path] = uigetfile({'*.jpg;*.png','Images (*.jpg,*.png)'}, 'Selecciona una imagen');
if isequal(file,0)
    disp('No se seleccionó ningún archivo.');
    return;
end
imageFile = fullfile(path, file);
sampleRate = 0.1;
threshold = 2;
threshold = 2;
sampleRate = 0.15;
fprintf('Sample rate used to select windows (percentage of 128x128 windows tested): %d\n', sampleRate)
fprintf('Minimum number of windows with spongebob occurance to tell if spongebob is: %d\n', threshold)
result = detection_SPONGEBOB_withCount(imageFile,sampleRate,threshold); %returns true (1) or false (0)
