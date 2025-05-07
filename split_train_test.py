# Este script sirve para separar las imagenes de train en dos, un 30% 
# de las imagenes se irá a TEST/<nombre-serie> y las otras se quedarán en
# TRAIN/<nombre-serie>.

import os
import shutil
import random

# Rutas base
train_dir = 'TRAIN'
test_dir = 'TEST'
test_ratio = 0.3  # 30%

# Crear carpeta TEST si no existe
os.makedirs(test_dir, exist_ok=True)

# Recorrer cada subcarpeta de TRAIN
for subfolder in os.listdir(train_dir):
    train_subfolder = os.path.join(train_dir, subfolder)
    test_subfolder = os.path.join(test_dir, subfolder)

    if os.path.isdir(train_subfolder):
        # Crear subcarpeta en TEST
        os.makedirs(test_subfolder, exist_ok=True)

        # Obtener imágenes
        images = [f for f in os.listdir(train_subfolder) if os.path.isfile(os.path.join(train_subfolder, f))]
        num_to_move = int(len(images) * test_ratio)
        selected_images = random.sample(images, num_to_move)

        # Mover imágenes
        for image in selected_images:
            src_path = os.path.join(train_subfolder, image)
            dst_path = os.path.join(test_subfolder, image)
            shutil.move(src_path, dst_path)

print("Proceso completado: 30% de las imágenes movidas a TEST.")
