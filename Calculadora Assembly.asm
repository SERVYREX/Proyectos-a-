section .data
    a dd 50               ; primer número
    b dd 2                ; segundo número (cambia para probar división)
    modo_operacion dd 4     ; SUMA = 1, RESTA = 2,  MULTIPLICACIÓN = 3, DIVISIÓN = 4  
    result dd 0             ; Resultado de la operacion seleccionada 

  ;Texto para poder mostrar mensajes de error etc, ademas de incluir el simbolo de menos para numeros negativos

    texto_suma db 'Suma: ', 0
    texto_resta db 'Resta: ', 0
    texto_mul db 'Mult: ', 0
    texto_div db 'Div:  ', 0
    texto_div0 db 'Error: Division por 0', 0
    texto_excess db 'No es posible representar',0
    signo_menos db '-', 0                   

section .bss
    buffer resb 3           ; Creamos un buffer con espacio para 2 digitos

section .text
    global _start

_start:
  ; Comprobamos en cada caso si a y b, son menores que -99 o mayores a 99, para respetar la restricciones de 2 digitos 
  ; En caso de comprobarse, enviaremos el programa a "passdig" el cual es una función que se definirá mas adelante
    mov eax, [a]              
    cmp eax, 99
    jg passdig
    cmp eax, -99
    jl passdig
    mov eax, [b]
    cmp eax, 99
    jg passdig
    cmp eax, -99
    jl passdig
    
    ;Se lee la operacion seleccionada previamente y se salta a la operacion correspondiente 
    mov eax, [modo_operacion]
    cmp eax, 1
    je hacer_suma
    cmp eax, 2
    je hacer_resta
    cmp eax, 3
    je hacer_mul
    cmp eax, 4
    je hacer_div
    
; ========== SUMA ==========
hacer_suma:
  ;Presentamos en pantalla el texto de la operacion seleccionada 
    mov eax, 4
    mov ebx, 1
    mov ecx, texto_suma
    mov edx, 6
    int 0x80
    ; Movemos el primer numero a "aex" y le aplicamos la operacion correspondiente
    mov eax, [a]          
    add eax, [b]
    mov [result],eax   ; Movemos a result el resultado de la operacion
    cmp eax, 99
    jg passdig        ; Luego comparamos si el resultado supera 99 o es menor a -99 en caso de ser asi usamos "passdig"
    jbe mostrar       ; En caso de no ser negativo usamos la funcion "mostrar" para mostrar el resultado
    cmp eax, -99
    jl passdig
    jge neg           ; Y en caso de ser negativo, llamamos a "neg" para mostrar el numero negativo
  
  ; Este proceso es analogo para cada operacion
; ========== RESTA ==========
hacer_resta:
    mov eax, 4
    mov ebx, 1
    mov ecx, texto_resta
    mov edx, 7
    int 0x80

    mov eax, [a]
    sub eax, [b]
    mov [result],eax
    cmp eax, 99
    jg passdig
    jbe mostrar
    cmp eax, -99
    jl passdig
    jge neg

    
; ========== MULTIPLICACIÓN ==========
hacer_mul:
    mov eax, 4
    mov ebx, 1
    mov ecx, texto_mul
    mov edx, 6
    int 0x80

    mov eax, [a]
    imul eax, [b]
    mov [result],eax
    cmp eax, 99
    jbe mostrar
    jg passdig
    cmp eax, -99
    jl passdig
    jge neg
    


; ========== DIVISIÓN ==========
hacer_div:
    mov eax, [b]
    cmp eax, 0
    je .div_cero

    mov eax, 4
    mov ebx, 1
    mov ecx, texto_div
    mov edx, 6
    int 0x80

    xor edx, edx
    mov eax, [a]
    cdq            ;cambia el bit de signo para evitar problemas con las divisiones de numeros negativos
    idiv dword [b]
    mov [result],eax
    cmp eax, 99
    jbe mostrar
    jg passdig
    cmp eax, -99
    jl passdig
    jge neg

.div_cero:   ;En caso de que se detecte una divison por 0, se ejecutara esta funcion que muestra un mensaje y llama a salida
    mov eax, 4
    mov ebx, 1
    mov ecx, texto_div0
    mov edx, 22
    int 0x80
    jmp salida


; ========== SALIDA ===========
salida:                  
    mov eax, 1             ;Termina el programa liberando la memoria y llamando al kernel          
    xor ebx, ebx
    int 0x80

; ========== FUNCIONES ==========

convertir_a_ascii: 
    mov ecx, eax
    mov edi, buffer+2
    mov byte [edi], 0
    mov esi, 0
    
.Conversion:
    cmp esi, 2             ; Comprueba si se convirtieron ambos digitos (Como maximo)
    je .fin                ; Termina en caso de haberlo hecho
    dec edi                ; Retrocede una posición en el buffer
    xor edx, edx           ; Limpia EDX 
    mov eax, ecx           ; Copia el número a dividir
    mov ebx, 10            ; Queremos dividir entre 10 para obtener la decena 
    div ebx                ; eax = resultado, edx = resto
    add dl, '0'            ; Convierte el valor a ASCII
    mov [edi], dl          ; Guarda el carácter en el buffer
    inc esi                ; Aumenta el contador de dígitos
    mov ecx, eax           ; Guarda el cociente para el siguiente dígito
    test eax, eax          ; Revisa si eax es 0
    jnz .Conversion              ; En caso de no serlo, repetimos el ciclo
.fin:
    ret  ; Vuelve al punto donde fue llamada                   


imprimir_buffer:  ;Calcula el largo del buffer y muestra su contenido
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, buffer+2
    sub edx, edi
    int 0x80
    ret
  
mostrar:                        ; Llamamos a convertir e imprimir para mostrar el numero
    call convertir_a_ascii
    call imprimir_buffer
    jmp salida
    
passdig:             ; En caso de que el numero comprobado sea mayor a 99 o menor -99 mostramos un texto y salimos
    mov eax, 4
    mov ebx, 1
    mov ecx, texto_excess
    mov edx, 26
    int 0x80
    jmp salida
      
neg:               ; En caso de ser negativo, ponemos un signo menos por delante y mostramos el numero calculado 
    mov eax, 4
    mov ebx, 1
    mov ecx, signo_menos
    mov edx, 1
    int 0x80
    mov eax, [result]
    neg eax        
    jmp mostrar