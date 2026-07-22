.section .kernel_text

.global UND_Handler
.global SVC_Handler
.global PREF_Handler
.global ABT_Handler
.global IRQ_Handler
.global FIQ_Handler
.extern handler_irq

.equ SVC_txt1, 0x0053       /*0S*/
.equ SVC_txt2, 0x5643       /*VC*/
.equ INV_txt1, 0x0049       /*0I*/
.equ INV_txt2, 0x4E56       /*NV*/
.equ MEM_txt1, 0x004D       /*0M*/
.equ MEM_txt2, 0x454D       /*EM*/

UND_Handler:

    MOVW R10, INV_txt2
    MOVT R10, INV_txt1
    MOVS PC, R14

SVC_Handler:

    /*Si no funciona hacer R10=txt2 y R10 = (R10 & 0xFFFF) | (0xtxt1 0000) */
    MOVW R10, SVC_txt2
    MOVT R10, SVC_txt1
    MOVS PC, R14

PREF_Handler:

    MOVW R10, MEM_txt2
    MOVT R10, MEM_txt1
    SUBS PC, R14, #4

ABT_Handler:

    MOVW R10, MEM_txt2
    MOVT R10, MEM_txt1
    SUBS PC, R14, #8

IRQ_Handler:

    SUB LR, LR, #4
    /*Guardo contexto de la tarea */
    STMFD SP!, {R0-R12, LR}            
    MOV R7, SP                          /*Nuevo valor de stack pointer después de guardar contexto */
    MRS R8, SPSR
    PUSH {R7, R8}

    /*Atiendo la interrupción */
    MOV R0, SP
    BL handler_irq

FIQ_Handler:

    SUBS PC, R14, #4

.end