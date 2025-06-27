import numpy as np
import cv2
from pathlib import Path

#Lectura y carga de la imagen a reescalar
descargas = Path.home() / "Downloads"  
archivo = "imagen_ejemplo.png"
ruta = descargas / archivo
ejemplo = cv2.imread(str(ruta))

#Matriz para la nueva imagen
matriz_promedio = np.zeros((1024,1024,3))

#Recorre la imagen de 4 en 4 pixeles, calculando el promedio RGB de los bloques 4x4
for alto in range(0,4096,4):
    for ancho in range (0,4096,4):
        bloque = ejemplo[alto:alto+4, ancho:ancho+4, :]
        aux = np.mean(bloque, axis=(0, 1))
        matriz_promedio[alto//4, ancho//4, :] = aux  # Se agrega el promedio a la nueva matriz 

#Transforma la matriz resultante a "int" para poder procesar la nueva imagen
matriz_promedio = matriz_promedio.astype(np.uint8)

#Crea la nueva imagen en la ruta seleccionada
archivo = "imagen_reescaladaCPU.png"
ruta = descargas / archivo

cv2.imwrite(str(ruta),matriz_promedio)
