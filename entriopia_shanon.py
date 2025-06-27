import cv2
import numpy as np
from pathlib import Path

def entriopiacanal(m):
    #Crea un histograma con el valor del canal ingresado
    histograma, _ = np.histogram(m, bins=256, range=(0, 256))
    #Calcula la probabilidad normalizada 
    probabilidades = histograma / histograma.sum()
    #Elimina las probabilidades "0"
    prob_no_cero = probabilidades[probabilidades > 0]
    #Calcula la entriopia
    entriopia = -np.sum(prob_no_cero * np.log2(prob_no_cero))
    return entriopia

#Carga todas las imagenes, la imagen ejemplo y las reescaladas mediante ambas implementaciones 
descargas = Path.home() / "Downloads"
imgreescaladaGPU = "imagen_reescaladaGPU.png"
imgreescaladaCPU = "imagen_reescaladaCPU.png"
imgejemplo = "imagen_ejemplo.png"
ruta1 = descargas / imgejemplo
ruta2 = descargas / imgreescaladaCPU
ruta3 = descargas / imgreescaladaGPU
 
ejemplo = cv2.imread(ruta1)
reescaladaCPU = cv2.imread(ruta2)
reescaladaGPU = cv2.imread(ruta3)

#Obtiene los valores de cada canal RGB
canal_azulej = ejemplo[:, :, 0]
canal_verdeej = ejemplo[:, :, 1]
canal_rojoej = ejemplo[:, :, 2]

#Calcula la entriopia de cada canal, junto a su promedio
entriopia_azulej = entriopiacanal(canal_azulej)
entriopia_verdeej = entriopiacanal(canal_verdeej)
entriopia_rojoej = entriopiacanal(canal_rojoej)
promedioej = (entriopia_azulej + entriopia_rojoej + entriopia_verdeej)/3

print(f"Entriopia RGB-EJEMPLO: {promedioej:.3f}")

#Proceso analogo para la implmentacion GPU Y CPU
canal_azulcpu = reescaladaCPU[:, :, 0]
canal_verdecpu = reescaladaCPU[:, :, 1]
canal_rojocpu = reescaladaCPU[:, :, 2]

entriopia_azulcpu = entriopiacanal(canal_azulcpu)
entriopia_verdecpu = entriopiacanal(canal_verdecpu)
entriopia_rojocpu = entriopiacanal(canal_rojocpu)
promediocpu = (entriopia_azulcpu + entriopia_rojocpu + entriopia_verdecpu)/3

print(f"Entriopia RGB-CPU: {promediocpu:.3f}")

canal_azulgpu = reescaladaGPU[:, :, 0]
canal_verdegpu = reescaladaGPU[:, :, 1]
canal_rojogpu = reescaladaGPU[:, :, 2]

entriopia_azulgpu = entriopiacanal(canal_azulgpu)
entriopia_verdegpu = entriopiacanal(canal_verdegpu)
entriopia_rojogpu = entriopiacanal(canal_rojogpu)
promediogpu = (entriopia_azulgpu + entriopia_rojogpu + entriopia_verdegpu)/3

print(f"Entriopia RGB-GPU: {promediogpu:.3f}")

#Calcula el indice de preservacion
print(f"Preservacion CPU: {promedioej/promediocpu:.3f}")
print(f"Preservacion GPU: {promedioej/promediogpu:.3f}")
