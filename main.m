function main()
    % Preguntar al usuario si quiere provar un archivo o un directorio recursivo
    choice = input('¿Quieres probar un archivo (f) o un directorio (d)? ', 's');


    % Abrir un dialogo para seleccionar un directorio o un archivo jpg
    if choice == 'f'
        [file, path] = uigetfile({'*.jpg'}, 'Selecciona un archivo');
        if isequal(file, 0)
            disp('No se seleccionó ningún archivo.');
            return;
        end
        filePath = fullfile(path, file);
        % Leer el archivo y mostrar su contenido
        im = imread(filePath);
        imshow(im);
    elseif choice == 'd'
        % Abrir un dialogo para seleccionar un directorio
        dirPath = uigetdir(pwd, 'Selecciona un directorio');
        if isequal(dirPath, 0)
            disp('No se seleccionó ningún directorio.');
            return;
        end
        % Listar todos los archivos jpg en el directorio y sus subdirectorios
        files = dir(fullfile(dirPath, '**', '*.jpg'));
        
        % print number of files found
        fprintf('Se encontraron %d archivos jpg en el directorio y sus subdirectorios.\n', length(files));
    end
end

