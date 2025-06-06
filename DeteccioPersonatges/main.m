% main.m
% Script principal per la part de deteccio de characters: l'usuari
% introdueix una opcio (1) o (2):
% 
% Amb l'opcio (1), l'usuari podra selccionar una imatge al seu sistema de 
% carpetes. i el programa imprimira si creu que hi ha el personatge 
% spongebob o no.
%
% Amb l'opcio (2), l'usuari podra seleccionar una carpeta de TEST (que
% contingui subcarpetes "positives" i "negatives" amb aquests noms!). El
% programa llavors, predira cada imatge, i finalment es mostra la matriu de
% confussio donada per les imatges de TEST.

fprintf('--- SpongeBob Detection Main Menu ---\n');
fprintf('1) Test a single image\n');
fprintf('2) Test a folder with positives and negatives\n');

choice = input('Select an option (1 or 2): ');

switch choice
    case 1
        test_image_spongebob();
    case 2
        test_folder_spongebob();
    otherwise
        disp('Invalid choice. Please run again and select 1 or 2.');
end
