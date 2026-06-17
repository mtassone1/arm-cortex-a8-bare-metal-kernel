.extern bss_start
.extern bss_end

.extern reset_vector_end
.extern reset_vector_code

.extern kernel_irq_stack_top
.extern kernel_fiq_stack_top
.extern kernel_abt_stack_top
.extern kernel_und_stack_top
.extern kernel_sys_stack_top
.extern kernel_svc_stack_top

.extern gic_init
.extern timer_init
.extern MMU_NewPage
.extern td3_memcopy
.extern IDLE
.extern main_T1
.extern main_T2

.extern KERNEL_TXT_LMA
.extern KERNEL_TXT_VMA
.extern KERNEL_TXT_PHY
.extern kernel_size
.extern KERNEL_DATA_LMA
.extern KERNEL_DATA_VMA
.extern KERNEL_DATA_PHY
.extern kernel_data_size
.extern PUBLIC_STACK_PHY
.extern PUBLIC_STACK_VMA

.extern TAREA_IDLE_TXT_LMA
.extern TAREA_IDLE_TXT_VMA
.extern TAREA_IDLE_TXT_PHY
.extern txt_tarea_idle_size

.extern TAREA_1_TXT_LMA
.extern TAREA_1_TXT_VMA
.extern TAREA_1_TXT_PHY
.extern txt_tarea_1_size
.extern TAREA_1_BSS_LMA
.extern TAREA_1_BSS_VMA
.extern TAREA_1_BSS_PHY
.extern bss_tarea_1_size
.extern TAREA_1_DATA_LMA
.extern TAREA_1_DATA_VMA
.extern TAREA_1_DATA_PHY
.extern data_tarea_1_size
.extern TAREA_1_PILA_PHY
.extern TAREA_1_PILA_VMA
.extern tarea1_irq_stack_top

.extern TAREA_2_TXT_LMA
.extern TAREA_2_TXT_VMA
.extern TAREA_2_TXT_PHY
.extern txt_tarea_2_size
.extern TAREA_2_BSS_LMA
.extern TAREA_2_BSS_VMA
.extern TAREA_2_BSS_PHY
.extern bss_tarea_2_size
.extern TAREA_2_DATA_LMA
.extern TAREA_2_DATA_VMA
.extern TAREA_2_DATA_PHY
.extern data_tarea_2_size
.extern TAREA_2_PILA_PHY
.extern TAREA_2_PILA_VMA
.extern tarea2_irq_stack_top

.extern SYSTABLES_PHY
.extern SYSTABLES_END_PHY
.extern RESET_PHY
.extern RESET_VMA
.extern ISR_TABLE_PHY
.extern ISR_TABLE_VMA

.extern SYSTABLES_TAREA_1_PHY
.extern SYSTABLES_TAREA_2_PHY
.extern SYSTABLES_TAREA_IDLE_PHY

.extern TAREA1_READING_AREA_VMA
.extern TAREA1_READING_AREA_PHY
.extern TAREA2_READING_AREA_VMA
.extern TAREA2_READING_AREA_PHY

.global startup
.code 32

/*  Modo = [0;4] bits del CPSR 
    I_BIT = bit 7 del CPSR
    F_BIT = bit 6 del CPSR */

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

.section .startup_text

startup:

/*Limpio la bss */

    LDR R0, =bss_start
    LDR R1, =bss_end
    MOV R2, #0

clear_bss:

    CMP R0, R1
    BEQ table_copy
    LDR R2, [R0], #4
    B clear_bss

/*Inicializo la tabla de interrupciones */

table_copy:

    MOV R0, #0                                      /*Direccion destino, en este caso 0x0000 */
    LDR R1, =reset_vector_code
    LDR R2, =reset_vector_end

table_loop:

    LDR R3, [R1], #4
    STR R3, [R0], #4
    
    CMP R1, R2
    BNE table_loop

stck_load:

    MSR cpsr_c, #(IRQ_MODE | I_BIT | F_BIT)         /*Pone el valor resultado en la parte baja del CPSR */
    LDR SP, =kernel_irq_stack_top

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

/*Copio el código al lugar de memoria físico indicado por el ejercicio 5*/
code_cpy:

    LDR R0, =TAREA_IDLE_TXT_PHY
    LDR R1, =TAREA_IDLE_TXT_LMA
    LDR R2, =txt_tarea_idle_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

    LDR R0, =KERNEL_TXT_PHY
    LDR R1, =KERNEL_TXT_LMA
    LDR R2, =kernel_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

    LDR R0, =KERNEL_DATA_PHY
    LDR R1, =KERNEL_DATA_LMA
    LDR R2, =kernel_data_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

    LDR R0, =TAREA_1_TXT_PHY
    LDR R1, =TAREA_1_TXT_LMA
    LDR R2, =txt_tarea_1_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

    LDR R0, =TAREA_1_BSS_PHY
    LDR R1, =TAREA_1_BSS_LMA
    LDR R2, =bss_tarea_1_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

    LDR R0, =TAREA_1_DATA_PHY
    LDR R1, =TAREA_1_DATA_LMA
    LDR R2, =data_tarea_1_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

    LDR R0, =TAREA_2_TXT_PHY
    LDR R1, =TAREA_2_TXT_LMA
    LDR R2, =txt_tarea_2_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

    LDR R0, =TAREA_2_BSS_PHY
    LDR R1, =TAREA_2_BSS_LMA
    LDR R2, =bss_tarea_2_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

    LDR R0, =TAREA_2_DATA_PHY
    LDR R1, =TAREA_2_DATA_LMA
    LDR R2, =data_tarea_2_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

    LDR R0, =TAREA_IDLE_TXT_PHY
    LDR R1, =TAREA_IDLE_TXT_LMA
    LDR R2, =txt_tarea_idle_size

    LDR R10, =td3_memcopy
    MOV LR, PC
    BX R10

/*Inicializo GIC y Timer */

    LDR R10, =gic_init
    MOV LR, PC
    BX R10

    LDR R10, =timer_init
    MOV LR, PC
    BX R10

/*Borrar las tablas de paginación */

    MOV R0, #0
    LDR R1, =SYSTABLES_TAREA_IDLE_PHY
    LDR R2, =SYSTABLES_END_PHY

clear_tables:

    LDR R0, [R1], #4
    CMP R1, R2
    BNE clear_tables

//Llenado de tablas
/*--------------------- Tarea 1 ------------------------ */
//Interrupt vector

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =ISR_TABLE_PHY
    LDR R2, =ISR_TABLE_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//GICC0

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =0x1E000000
    LDR R2, =0x1E000000

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//GICD0

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =0x1E001000
    LDR R2, =0x1E001000

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Timer0

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =0x10011000
    LDR R2, =0x10011000

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Kernel

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =KERNEL_TXT_PHY
    LDR R2, =KERNEL_TXT_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =KERNEL_DATA_PHY
    LDR R2, =KERNEL_DATA_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Startup

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =RESET_PHY
    LDR R2, =RESET_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10    

//Código tarea 1

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =TAREA_1_TXT_PHY
    LDR R2, =TAREA_1_TXT_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//BSS tarea 1

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =TAREA_1_BSS_PHY
    LDR R2, =TAREA_1_BSS_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//DATA tarea 1

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =TAREA_1_DATA_PHY
    LDR R2, =TAREA_1_DATA_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//PILA tarea 1

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =TAREA_1_PILA_PHY
    LDR R2, =TAREA_1_PILA_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Reading area tarea 1

    LDR R0, =SYSTABLES_TAREA_1_PHY
    LDR R1, =TAREA1_READING_AREA_PHY
    LDR R2, =TAREA1_READING_AREA_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

/*--------------------- Tarea 2 ------------------------ */
//Interrupt vector

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =ISR_TABLE_PHY
    LDR R2, =ISR_TABLE_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//GICC0

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =0x1E000000
    LDR R2, =0x1E000000

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//GICD0

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =0x1E001000
    LDR R2, =0x1E001000

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Timer0

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =0x10011000
    LDR R2, =0x10011000

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Kernel

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =KERNEL_TXT_PHY
    LDR R2, =KERNEL_TXT_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =KERNEL_DATA_PHY
    LDR R2, =KERNEL_DATA_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Startup

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =RESET_PHY
    LDR R2, =RESET_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10      

//Código tarea 2

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =TAREA_2_TXT_PHY
    LDR R2, =TAREA_2_TXT_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//BSS tarea 2

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =TAREA_2_BSS_PHY
    LDR R2, =TAREA_2_BSS_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//DATA tarea 2

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =TAREA_2_DATA_PHY
    LDR R2, =TAREA_2_DATA_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//PILA tarea 2

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =TAREA_2_PILA_PHY
    LDR R2, =TAREA_2_PILA_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Reading area tarea 2

    LDR R0, =SYSTABLES_TAREA_2_PHY
    LDR R1, =TAREA2_READING_AREA_PHY
    LDR R2, =TAREA2_READING_AREA_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

/*--------------------- Tarea IDLE ------------------------ */

//Interrupt vector

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY
    LDR R1, =ISR_TABLE_PHY
    LDR R2, =ISR_TABLE_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//GICC0

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY
    LDR R1, =0x1E000000
    LDR R2, =0x1E000000

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//GICD0

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY
    LDR R1, =0x1E001000
    LDR R2, =0x1E001000

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Timer0

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY
    LDR R1, =0x10011000
    LDR R2, =0x10011000

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Kernel

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY
    LDR R1, =KERNEL_TXT_PHY
    LDR R2, =KERNEL_TXT_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY
    LDR R1, =KERNEL_DATA_PHY
    LDR R2, =KERNEL_DATA_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Kernel stack

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY
    LDR R1, =PUBLIC_STACK_PHY
    LDR R2, =PUBLIC_STACK_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Startup

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY
    LDR R1, =RESET_PHY
    LDR R2, =RESET_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

//Codigo tarea IDLE

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY
    LDR R1, =TAREA_IDLE_TXT_PHY
    LDR R2, =TAREA_IDLE_TXT_VMA

    LDR R10, =MMU_NewPage
    MOV LR, PC
    BX R10

task_preload:
//tarea 1

    LDR R10, =tarea1_irq_stack_top      
    ADD R10, R10, #0x0F800000           /* VMA a PHY */
    LDR R11, =TAREA_1_TXT_VMA           /* VMA codigo tarea 1 */
    MOV R0, #0
    MOV R1, #0
    MOV R2, #0
    MOV R3, #0
    
    /*Pusheo los registros a pila */
    STMFD R10!,{R11,R0}                    /* Abajo de todo, el pc */
    STMFD R10!,{R0-R3}                  /* Cargo R0-R12 todos en 0 */
    STMFD R10!,{R0-R3}       
    STMFD R10!,{R0-R3}       
    
    SUB R11, R10, #0x0F800000           /* PHY a VMA del valor actual de la pila después de la carga de registros */
    MRS R0, CPSR                        /* Cargo en R0 el CPSR actual */
    BIC R0, R0, #0x80                   /* Habilito interrupciones para el futuro CPSR */
    STMFD R10!,{R0}
    STMFD R10!,{R11}               

//tarea 2

    LDR R10, =tarea2_irq_stack_top
    ADD R10, R10, #0x0F800000      
    LDR R11, =TAREA_2_TXT_VMA           /*VMA codigo tarea 2 */
    MOV R0, #0
    MOV R1, #0
    MOV R2, #0
    MOV R3, #0
    
    /*Pusheo los registros a pila */
    STMFD R10!,{R11,R0}      
    STMFD R10!,{R0-R3}       
    STMFD R10!,{R0-R3}       
    STMFD R10!,{R0-R3}       

    SUB R11, R10, #0x0F800000           /* PHY a VMA del valor actual de la pila después de la carga de registros */
    MRS R0, CPSR                        /* Cargo en R0 el CPSR actual */
    BIC R0, R0, #0x80                   /* Habilito interrupciones para el futuro CPSR */
    STMFD R10!,{R0}
    STMFD R10!,{R11}    

//Cargo TTBR0

    LDR R0, =SYSTABLES_TAREA_IDLE_PHY         /*Esto va a cambiar según la tarea */
    MCR P15, 0, R0, C2, C0, 0                 /*Cargo TTBR0, accedo al coprocesador 15, HW para acceso a registros*/

    LDR R0, =0x55555555
    MCR P15, 0, R0, C3, C0, 0                 /*Todos los dominios van a ser cliente */

//Prendo MMU
pag_start:

    MRC P15, 0, R1, C1, C0, 0
    ORR R1, R1, #0X1
    MCR P15, 0, R1, C1, C0, 0 

//Habilito interrupciones
    MRS R0, cpsr
    BIC R0, R0, #0x80              
    MSR cpsr_c, R0

startup_end:
    
    B TAREA_IDLE_TXT_VMA        

.end