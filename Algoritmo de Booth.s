.section .data
fmt:    .asciz "Resultado: %d\n"  // Formato para imprimir el resultado

.section .text
.global main
.extern printf

main:
    // Inicialización de A, S y P con el ejemplo dado (3 * 2)
    mov x0, #3           // A = 0011
    mvn x1, x0           // S = -A en complemento a 2 (S = 1101)
    add x1, x1, #1
    mov x2, #2           // P = 0010
    mov x3, #0           // Bits superiores de P (inicialmente ceros)
    mov x4, #8           // Número de iteraciones

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
    b shift_right        // No modificar P, solo desplazamiento

caso_01:
    add x2, x2, x0       // P = P + A
    b shift_right

caso_10:
    add x2, x2, x1       // P = P + S

shift_right:
    asr x2, x2, #1       // Desplazamiento aritmético de P a la derecha
    subs x4, x4, #1      // Decrementar el contador de iteraciones
    bne loop

    // Último desplazamiento aritmético
    asr x2, x2, #1

    // Imprimir resultado
    mov x0, fmt
    mov x1, x2
    bl printf

    // Finalizar el programa
    mov x8, #93
    mov x0, #0
    svc #0
