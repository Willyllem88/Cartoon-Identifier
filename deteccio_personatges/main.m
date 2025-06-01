[file, path] = uigetfile({'*.jpg;*.png','Images (*.jpg,*.png)'}, 'Selecciona una imagen');
if isequal(file,0)
    disp('No se seleccionó ningún archivo.');
    return;
end
imageFile = fullfile(path, file);
sampleRate = 0.1;
threshold = 2;
doResize = 0;
result = detection_SPONGEBOB_withCount(imageFile,sampleRate,threshold, doResize); %returns true (1) or false (0)