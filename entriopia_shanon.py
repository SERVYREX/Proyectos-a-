import cv2
import numpy as np
from pathlib import Path

def entriopiacanal(m):
    histograma, _ = np.histogram(m, bins=256, range=(0, 256))
    probabilidades = histograma / histograma.sum()
    prob_no_cero = probabilidades[probabilidades > 0]
    entropia = -np.sum(prob_no_cero * np.log2(prob_no_cero))
    return entropia

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

canal_azulej = ejemplo[:, :, 0]
canal_verdeej = ejemplo[:, :, 1]
canal_rojoej = ejemplo[:, :, 2]

entriopia_azulej = entriopiacanal(canal_azulej)
entriopia_verdeej = entriopiacanal(canal_verdeej)
entriopia_rojoej = entriopiacanal(canal_rojoej)
promedioej = (entriopia_azulej + entriopia_rojoej + entriopia_verdeej)/3

print(f"Entriopia RGB-EJEMPLO: {promedioej:.3f}")

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

print(f"Preservacion CPU: {promedioej/promediocpu:.3f}")
print(f"Preservacion GPU: {promedioej/promediogpu:.3f}")