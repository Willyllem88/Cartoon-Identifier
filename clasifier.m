% Limpiar el espacio de trabajo
clear; clc; close all;

traindir = './TRAIN';
testdir = './TEST';

dirs = dir(traindir);
for i = 1:length(dirs)
    if startsWith(dirs(i).name, '.')
        continue;
    end

    disp(['Directorio: ' dirs(i).name]);

    files = dir(fullfile(traindir, dirs(i).name, '*'));
    for j = 1:length(files)
            
    end
end
