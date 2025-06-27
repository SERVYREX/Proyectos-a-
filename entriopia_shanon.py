import cv2
import numpy as np
from pathlib import Path

def entropiacanal(m):
    #Crea un histograma con el valor del canal ingresado
    histograma, _ = np.histogram(m, bins=256, range=(0, 256))
    #Calcula la probabilidad normalizada 
    probabilidades = histograma / histograma.sum()
    #Elimina las probabilidades "0"
    prob_no_cero = probabilidades[probabilidades > 0]
    #Calcula la entropia
    entropia = -np.sum(prob_no_cero * np.log2(prob_no_cero))
    return entropia

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

#Calcula la entropia de cada canal, junto a su promedio
entropia_azulej = entropiacanal(canal_azulej)
entropia_verdeej = entropiacanal(canal_verdeej)
entropia_rojoej = entropiacanal(canal_rojoej)
promedioej = (entropia_azulej + entropia_rojoej + entropia_verdeej)/3

print(f"Entropia RGB-EJEMPLO: {promedioej:.3f}")

#Proceso analogo para la implmentacion GPU Y CPU
canal_azulcpu = reescaladaCPU[:, :, 0]
canal_verdecpu = reescaladaCPU[:, :, 1]
canal_rojocpu = reescaladaCPU[:, :, 2]

entropia_azulcpu = entropiacanal(canal_azulcpu)
entropia_verdecpu = entropiacanal(canal_verdecpu)
entropia_rojocpu = entropiacanal(canal_rojocpu)
promediocpu = (entropia_azulcpu + entropia_rojocpu + entropia_verdecpu)/3

print(f"Entropia RGB-CPU: {promediocpu:.3f}")

canal_azulgpu = reescaladaGPU[:, :, 0]
canal_verdegpu = reescaladaGPU[:, :, 1]
canal_rojogpu = reescaladaGPU[:, :, 2]

entropia_azulgpu = entropiacanal(canal_azulgpu)
entropia_verdegpu = entropiacanal(canal_verdegpu)
entropia_rojogpu = entropiacanal(canal_rojogpu)
promediogpu = (entropia_azulgpu + entropia_rojogpu + entropia_verdegpu)/3

print(f"Entropia RGB-GPU: {promediogpu:.3f}")

#Calcula el indice de preservacion
print(f"Preservacion CPU: {promedioej/promediocpu:.3f}")
print(f"Preservacion GPU: {promedioej/promediogpu:.3f}")
