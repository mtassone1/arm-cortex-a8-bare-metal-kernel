.code 32

.extern UND_Handler
.extern SVC_Handler
.extern PREF_Handler
.extern ABT_Handler
.extern IRQ_Handler
.extern FIQ_Handler
.extern IDLE
.extern reset

.global reset_vector_code

.section .reset_vector_text

reset_vector_code:

    LDR PC, addr_reset
    LDR PC, addr_UND_Handler
    LDR PC, addr_SVC_Handler
    LDR PC, addr_PREF_Handler
    LDR PC, addr_ABT_Handler
    LDR PC, addr_IDLE                   /* reservado, relleno con algo */
    LDR PC, addr_IRQ_Handler
    LDR PC, addr_FIQ_Handler

    /*Si escribo el handler acá me ahorro el salto al FIQ Handler */

addr_reset: 	    .word reset
addr_UND_Handler:   .word UND_Handler
addr_SVC_Handler:   .word SVC_Handler
addr_PREF_Handler:  .word PREF_Handler
addr_ABT_Handler:   .word ABT_Handler
addr_IDLE:          .word IDLE
addr_IRQ_Handler:   .word IRQ_Handler
addr_FIQ_Handler:   .word FIQ_Handler

.end