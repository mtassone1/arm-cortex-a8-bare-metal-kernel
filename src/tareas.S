.global main_T1
.global main_T2
.global IDLE
.global t1_stack_init
.global t2_stack_init
.global kernel_stack_init
.global load_context
.code 32                        @ Modo arm 32 bits

.extern tarea1_irq_stack_top
.extern tarea1_fiq_stack_top
.extern tarea1_sys_stack_top
.extern tarea1_abt_stack_top
.extern tarea1_und_stack_top
.extern tarea1_svc_stack_top

.extern tarea2_irq_stack_top
.extern tarea2_fiq_stack_top
.extern tarea2_sys_stack_top
.extern tarea2_abt_stack_top
.extern tarea2_und_stack_top
.extern tarea2_svc_stack_top

//Equ para interrupciones
.equ USR_MODE, 0x10
.equ FIQ_MODE, 0x11
.equ IRQ_MODE, 0x12
.equ SVC_MODE, 0x13
.equ ABT_MODE, 0x17
.equ UND_MODE, 0x1B
.equ SYS_MODE, 0x1F

.equ I_BIT, 0x80
.equ F_BIT, 0x40

.equ palabra, 0x55AA55AA 

.section .tarea_1_txt, "a"

main_T1:

    LDR R0, =palabra
    LDR R1, =TAREA1_READING_AREA_VMA
    LDR R2, =TAREA1_READING_AREA_VMA
    ADD R2, R2, #0x1000

tarea1_loop:
    LDR R5, [R1], #0      /* Guardo lo que está escrito en la dirección de memoria */
    STR R0, [R1], #0      /* Cargo la palabra en la dirección de memoria */
    LDR R3, [R1], #0      /* Reviso que se haya cargado correctamente la dirección de memoria */
    STR R5, [R1], #4      /* Vuelvo a cargar lo que había anteriormente en la dirección de memoria */

    CMP R1,R2
    BNE tarea1_loop
    ADD R4, R4, #1          /* Cuento cuantas veces se realizó el ciclo */
    WFI
    B main_T1

t1_stack_init:

    MSR cpsr_c, #(FIQ_MODE | I_BIT | F_BIT)
    LDR SP, =tarea1_fiq_stack_top

    MSR cpsr_c, #(SYS_MODE | I_BIT | F_BIT)         /*Comparte registros con el modo USR */
    LDR SP, =tarea1_sys_stack_top

    MSR cpsr_c, #(ABT_MODE | I_BIT | F_BIT)
    LDR SP, =tarea1_abt_stack_top

    MSR cpsr_c, #(UND_MODE | I_BIT | F_BIT)
    LDR SP, =tarea1_und_stack_top

    MSR cpsr_c, #(SVC_MODE | I_BIT | F_BIT)
    LDR SP, =tarea1_svc_stack_top

    MSR cpsr_c, #(IRQ_MODE | I_BIT | F_BIT)                 
    LDR SP, =tarea1_irq_stack_top

    SUB SP, SP, #64                                 /*Apunta al tope de la pila */

    /*Carga de contexto de nueva tarea */
    POP {R7, R8}
    MOV SP, R7
    MSR SPSR, R8
    LDMFD SP!, {R0-R12, PC}^         

.section .tarea_2_txt, "a"

main_T2:

    LDR R1, =TAREA2_READING_AREA_VMA
    LDR R2, =TAREA2_READING_AREA_VMA
    ADD R2, R2, #0x1000

tarea2_loop:

    LDR R0, [R1], #0      /* Leo lo que había en la dirección de memoria */
    MOV R3, #0xFFFFFFFF     
    EORS R0, R0, R3         /* Hago un XOR con lo que había en la dirección de memoria */
    STR R0, [R1], #0      /* Cargo el contenido modificado en la dirección de memoria */
    LDR R3, [R1], #0      /* Reviso que se haya cargado correctamente */
    ADD R1, R1, #4

    CMP R1,R2
    BNE tarea2_loop
    ADD R4, R4, #1          /* Cuento cuantas veces se realizó el ciclo */
    WFI
    B main_T2

t2_stack_init:

    MSR cpsr_c, #(FIQ_MODE | I_BIT | F_BIT)
    LDR SP, =tarea2_fiq_stack_top

    MSR cpsr_c, #(SYS_MODE | I_BIT | F_BIT)         /*Comparte registros con el modo USR */
    LDR SP, =tarea2_sys_stack_top

    MSR cpsr_c, #(ABT_MODE | I_BIT | F_BIT)
    LDR SP, =tarea2_abt_stack_top

    MSR cpsr_c, #(UND_MODE | I_BIT | F_BIT)
    LDR SP, =tarea2_und_stack_top

    MSR cpsr_c, #(SVC_MODE | I_BIT | F_BIT)
    LDR SP, =tarea2_svc_stack_top

    MSR cpsr_c, #(IRQ_MODE | I_BIT | F_BIT)         
    LDR SP, =tarea2_irq_stack_top

    SUB SP, SP, #64                                 /*Apunta al tope de la pila */

    /*Carga de contexto de nueva tarea */
    POP {R7, R8}
    MOV SP, R7
    MSR SPSR, R8
    LDMFD SP!, {R0-R12, PC}^   

.section .idle_txt, "a"

IDLE:

    WFI
    B IDLE  

kernel_stack_init:

    MSR cpsr_c, #(FIQ_MODE | I_BIT | F_BIT)
    LDR SP, =kernel_fiq_stack_top

    MSR cpsr_c, #(SYS_MODE | I_BIT | F_BIT)         /*Comparte registros con el modo USR */
    LDR SP, =kernel_sys_stack_top

    MSR cpsr_c, #(ABT_MODE | I_BIT | F_BIT)
    LDR SP, =kernel_abt_stack_top

    MSR cpsr_c, #(UND_MODE | I_BIT | F_BIT)
    LDR SP, =kernel_und_stack_top

    MSR cpsr_c, #(SVC_MODE | I_BIT | F_BIT)
    LDR SP, =kernel_svc_stack_top

    MSR cpsr_c, #(IRQ_MODE | I_BIT | F_BIT)         /*Pone el valor resultado en la parte baja del CPSR */
    LDR SP, =kernel_irq_stack_top

    SUB SP, SP, #64                                 /*Apunta al tope de la pila */

    /*Carga de contexto de nueva tarea */
    POP {R7, R8}
    MOV SP, R7
    MSR SPSR, R8
    LDMFD SP!, {R0-R12, PC}^   

.end
