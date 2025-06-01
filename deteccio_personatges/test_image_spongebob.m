% test_image_spongebob.m
% Script que demana a l'usuari NOMES una imatge d'entrada. s'aplcia la
% prediccio a la imatge (s'utilitza el script detection_spongebob), i
% s'imprimeix per pantalla el resultat de la prediccio.
% Comentari: els atributs sampleRate i threshold estan exlicats al script,
% detection_spongebob.m

[file, path] = uigetfile({'*.jpg;*.png','Images (*.jpg,*.png)'}, 'Selecciona una imagen');
if isequal(file,0)
    disp('No file selected.');
    return;
end
imageFile = fullfile(path, file);
threshold = 2;
sampleRate = 0.15;
fprintf('Sample rate used to select windows (percentage of 128x128 windows tested): %d\n', sampleRate)
fprintf('Minimum number of windows with spongebob occurance to tell if spongebob is: %d\n', threshold)
result = detection_spongebob(imageFile,sampleRate,threshold); %returns true (1) or false (0)
