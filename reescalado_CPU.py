import numpy as np
import cv2
from pathlib import Path

descargas = Path.home() / "Downloads"
archivo = "imagen_ejemplo.png"
ruta = descargas / archivo

ejemplo = cv2.imread(str(ruta))

matriz_promedio = np.zeros((1024,1024,3))

for alto in range(0,4096,4):
    for ancho in range (0,4096,4):
        bloque = ejemplo[alto:alto+4, ancho:ancho+4, :]
        aux = np.mean(bloque, axis=(0, 1))
        matriz_promedio[alto//4, ancho//4, :] = aux

matriz_promedio = matriz_promedio.astype(np.uint8)

archivo = "imagen_reescaladaCPU.png"
ruta = descargas / archivo

cv2.imwrite(str(ruta),matriz_promedio)
