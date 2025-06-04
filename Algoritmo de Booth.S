.section .data
fmt: .asciz "Resultado: %d\nTiempo de ejecucion: %ld.%09ld segundos\n"

.section .bss
.align 8
start_time: .skip 16
end_time:   .skip 16

.section .text
.global main
.extern printf
.extern clock_gettime

main:
    // Obtener tiempo de inicio
    MOV X0, #1                     // CLOCK_REALTIME
    LDR X1, =start_time
    BL clock_gettime

    // Entradas: 2 y 4
    MOV X2, #2                 
    MOV X3, #4                 

    // Convierte las entradas a 4 bits en complemento a dos
    AND X2, X2, #0xF
    AND X3, X3, #0xF

    // Ajusta los números para estar un rango de 4 bits en complemento a dos (-8-7)
    CMP X2, #8
    BLT skip_neg_m           //Si el multiplicando es <8 revisa el multiplicador
    MOV X10, #16
    SUB X2, X2, X10          //Si es >=8 resta 16 para dejarlo expresado como 4 bits en complemento a 2

skip_neg_m:                 //Realiza el mismo procedimiento pero para el multiplicador
    CMP X3, #8
    BLT skip_neg_r
    MOV X10, #16
    SUB X3, X3, X10

skip_neg_r:

    // P = multiplicador << 1
    MOV X4, X3
    LSL X4, X4, #1

    // A = multiplicando << 5
    MOV X5, X2
    LSL X5, X5, #5

    // S = (-multiplicando) << 5
    MOV X6, X2
    NEG X6, X6
    LSL X6, X6, #5

    MOV X7, #4        // 4 iteraciones para 4 bits

booth_loop:          //Se realiza el proceso de los ciclos del algoritmo de Booth, verificando los casos 10 y 01 para saltar a add_A o add_S
    AND X8, X4, #0b11
    CMP X8, #0b01
    B.EQ add_A
    CMP X8, #0b10
    B.EQ add_S
    B shift

add_A:               //Caso 01, donde se realiza P = P + A
    ADD X4, X4, X5  
    B shift

add_S:               //Caso 10, donde se realiza P = P + S
    ADD X4, X4, X6
    B shift

shift:                //Realiza los ciclos correspondientes
    ASR X4, X4, #1    
    SUBS X7, X7, #1
    B.GT booth_loop

    // Último desplazamiento
    ASR X4, X4, #1

    // Resultado está en X4 (9 bits)
    MOV X9, X4
    AND X9, X9, #0x1FF      // máscara 9 bits

    // Si X9 >= 256 → resultado negativo en complemento a dos
    MOV X10, #256
    CMP X9, X10
    BLT skip_convert
    MOV X11, #512
    SUB X9, X9, X11

skip_convert:

    // Obtener tiempo de fin
    MOV X0, #1
    LDR X1, =end_time
    BL clock_gettime

    // Calcular diferencia
    LDR X12, =start_time
    LDR X13, =end_time

    LDR X14, [X12]        // start sec
    LDR X15, [X12, #8]    // start nsec
    LDR X16, [X13]        // end sec
    LDR X17, [X13, #8]    // end nsec

    SUB X18, X16, X14     // delta sec
    SUB X19, X17, X15     // delta nsec

    CMP X19, #0
    B.GE time_ready
    SUB X18, X18, #1
    LDR X20, =1000000000
    ADD X19, X19, X20

time_ready:
    // Llamada a printf
    LDR X0, =fmt
    MOV X1, X9        // resultado
    MOV X2, X18       // segundos
    MOV X3, X19       // nanosegundos
    BL printf

    // Salida del programa con código 0
    MOV X8, #93       // syscall number for exit in AArch64 Linux
    MOV X0, #0        // exit code
    SVC #0
