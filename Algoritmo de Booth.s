.section .data
fmt:    .asciz "Resultado: %d\n"  // Formato para imprimir el resultado

.section .text
.global main
.extern printf

main:
    // Inicialización de A, S y P
    mov x0, #3           // Se inicializa el multiplicando, correspondiente a A
    mvn x1, x0           // Se calcula el completo a 2 del número, que corresponde a S
    add x1, x1, #1
    mov x2, #-2           // Se inicializa el multiplicador, correspondiente a P
    mov x3, #0           // Bits superiores de P (inicialmente ceros)
    mov x4, #8           // Número de iteraciones, en este caso 8 para poder realizar multiplicaciones con signo

loop:
    and x5, x2, #3       // Obtener los 2 bits menos significativos de P
    cmp x5, #0
    beq caso_00_11       // Si es 00 o 11, no modificar P

    cmp x5, #3
    beq caso_00_11       // También para el caso 11

    cmp x5, #1
    beq caso_01          // Si es 01, P = P + A

    cmp x5, #2
    beq caso_10          // Si es 10, P = P + S

caso_00_11:
    b mover_derecha        // No modificar P, solo desplazamiento

caso_01:
    add x2, x2, x0       // P = P + A
    b mover_derecha

caso_10:
    add x2, x2, x1       // P = P + S

mover_derecha:
    asr x2, x2, #1       // Desplazamiento aritmético de P a la derecha
    subs x4, x4, #1      // Decrementar el contador de iteraciones
    bne loop

    // Último desplazamiento aritmético
    asr x2, x2, #1

    // Imprimir resultado
    adrp x0, fmt
    add x0, x0, :lo12:fmt
    mov x1, x2
    bl printf

    // Finalizar el programa
    mov x8, #93
    mov x0, #0
    svc #0
