import pycuda.autoinit
import pycuda.driver as cuda
import numpy as np
import cv2
from pathlib import Path
from pycuda.compiler import SourceModule
from matplotlib import pyplot as plt

mod = SourceModule("""
__global__ void procesarImagen(unsigned char* entrada, unsigned char* salida){
    __shared__ int temp[16*3];
    int in_x = blockIdx.x * 4 + threadIdx.x;
    int in_y = blockIdx.y * 4 + threadIdx.y;
    int temp_pos = threadIdx.x + 4*threadIdx.y;
    int salida_pos = blockIdx.x + gridDim.x * blockIdx.y;
    if (in_x < 4096 && in_y < 4096){
        temp[temp_pos*3]     = entrada[(in_y*4096+in_x)*3];
        temp[temp_pos*3 + 1] = entrada[(in_y*4096+in_x)*3 + 1];
        temp[temp_pos*3 + 2] = entrada[(in_y*4096+in_x)*3 + 2];
    }
    __syncthreads();
    if(temp_pos == 0){
        int r = 0;
        int g = 0;
        int b = 0;
        for(int i = 0; i < 16; i++){
            r += temp[3*i];
            g += temp[3*i + 1];
            b += temp[3*i + 2];
        }
        salida[salida_pos*3]     = r/16;
        salida[salida_pos*3 + 1] = g/16;
        salida[salida_pos*3 + 2] = b/16;
    }
}
""")
descargas = Path.home() / "Downloads"
archivo = "imagen_ejemplo.png"
ruta = descargas / archivo
ejemplo = cv2.imread(str(ruta))

procesarImagen = mod.get_function("procesarImagen")

# Cargar imagen
px= np.array(ejemplo).astype(np.uint8)
px = px.flatten()

output = np.zeros(1024*1024*3, dtype=np.uint8)

# Asignación de memoria
pic_gpu = cuda.mem_alloc(px.nbytes)
output_gpu = cuda.mem_alloc(output.nbytes)
cuda.memcpy_htod(pic_gpu, px)

# Crear eventos CUDA
start = cuda.Event()
end = cuda.Event()

# Iniciar medición
start.record()

# Llamar al kernel
procesarImagen(pic_gpu, output_gpu, block=(4, 4, 1), grid=(1024, 1024, 1))

# Finalizar medición
end.record()
end.synchronize()

# Tiempo en milisegundos
tiempo_ms = start.time_till(end)
print(f"⏱️ Tiempo de ejecución del kernel: {tiempo_ms:.4f} ms")

# Recuperar y guardar imagen
cuda.memcpy_dtoh(output, output_gpu)
output = output.reshape(1024, 1024, 3).astype(np.uint8)
archivo = "imagen_reescaladaCPU.png"
ruta = descargas / archivo

cv2.imwrite(str(ruta),output)