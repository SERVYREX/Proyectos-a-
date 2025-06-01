.global main
main:
    // Inicialización de A, S y P
    mov x0, #3             // Se inicializa el multiplicando, correspondiente a A
    mvn x1, x0             // Se calcula el complemento a 2 del número, que corresponde a S
    add x1, x1, #1
    mov x2, #-2            // Se inicializa el multiplicador, correspondiente a P
    mov x4, #8             // Número de iteraciones, en este caso 8 para poder realizar multiplicaciones con signo
    mov x6, #0             // Inicialización de Q-1 en 0

loop:
    and x5, x2, #1         // Obtener el bit menos significativo actual de P (Q0)
    lsl x5, x5, #1         // Desplazar Q0 a la izquierda (Q0 << 1)
    orr x5, x5, x6         // Combinar con Q-1 para obtener (Q0, Q-1)

    cmp x5, #0
    beq caso_00_11         // Si es 00, no modificar P

    cmp x5, #3
    beq caso_00_11         // Si es 11, tampoco modificar P

    cmp x5, #1
    beq caso_01            // Si es 01, P = P + A

    cmp x5, #2
    beq caso_10            // Si es 10, P = P + S

caso_00_11:
    b mover_derecha        // No modificar P, solo desplazamiento

caso_01:
    add x2, x2, x0         // P = P + A
    b mover_derecha

caso_10:
    add x2, x2, x1         // P = P + S
    b mover_derecha

mover_derecha:
    and x6, x2, #1         // Guardar el bit menos significativo (Q0) en Q-1 para próxima iteración
    asr x2, x2, #1         // Desplazamiento aritmético de P a la derecha
    subs x4, x4, #1        // Decrementar el contador de iteraciones
    bne loop
    
    // Finalizar el programa
    mov x8, #93
    mov x0, #0
    svc #0
