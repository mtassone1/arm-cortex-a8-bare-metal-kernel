/*Definiciones*/
OUTPUT_FORMAT("elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(reset)

IRQ_STACK_SIZE = 128;
FIQ_STACK_SIZE = 128;
ABT_STACK_SIZE = 128;
UND_STACK_SIZE = 128;
SVC_STACK_SIZE = 128;
C_STACK_SIZE = 4K;

/* ----------------- PHY ----------------- */
/* Vector de reset y código de startup */
RESET_PHY  	 		  = 0x70010000;
PUBLIC_STACK_PHY  	  = 0x70020000;						
ISR_TABLE_PHY  		  = 0x00000000;						

/* Kernel */
KERNEL_TXT_PHY  	  = 0x70030000;
KERNEL_BSS_PHY  	  = 0x70022000;
KERNEL_DATA_PHY  	  = 0x70031000;
KERNEL_RODATA_PHY  	  = 0x70023000;

/* Tablas de paginación */
SYSTABLES_TAREA_IDLE_PHY = 0x70430000;
SYSTABLES_TAREA_1_PHY = 0x70830000;    					/* TTBR0 de cada tarea */
SYSTABLES_TAREA_2_PHY = 0x70C30000;
SYSTABLES_END_PHY 	  = 0x71030000;

/* Tareas */

TAREA_1_TXT_PHY   	  = 0x80750000;
TAREA_1_BSS_PHY   	  = 0x80753000;
TAREA_1_DATA_PHY      = 0x80751000;
TAREA_1_RODATA_PHY    = 0x80754000;
TAREA_1_PILA_PHY  	  = 0x80752000;

TAREA_2_TXT_PHY   	  = 0x80740000;
TAREA_2_BSS_PHY   	  = 0x80743000;
TAREA_2_DATA_PHY      = 0x80741000;
TAREA_2_RODATA_PHY    = 0x80744000;
TAREA_2_PILA_PHY  	  = 0x80742000;

TAREA_IDLE_TXT_PHY    = 0x80760000;

/* ------------------ VMA ------------------ */
RESET_VMA       	  = 0x70010000;
PUBLIC_STACK_VMA      = 0x70020000;				
ISR_TABLE_VMA         = 0x00000000;

KERNEL_TXT_VMA        = 0x70030000;
KERNEL_BSS_VMA        = 0x70022000;
KERNEL_DATA_VMA       = 0x70031000;
KERNEL_RODATA_VMA     = 0x70023000;

SYSTABLES_TAREA_IDLE_VMA = 0x70031000;
SYSTABLES_TAREA_1_VMA = 0x70431000;    					/* TTBR0 de cada tarea */
SYSTABLES_TAREA_2_VMA = 0x70831000;

/*Tareas*/

TAREA_1_TXT_VMA   	  = 0x70F50000;
TAREA_1_BSS_VMA   	  = 0x70F53000;
TAREA_1_DATA_VMA      = 0x70F51000;
TAREA_1_RODATA_VMA    = 0x70F54000;
TAREA_1_PILA_VMA  	  = 0x70F52000;

TAREA_2_TXT_VMA   	  = 0x70F40000;
TAREA_2_BSS_VMA   	  = 0x70F43000;
TAREA_2_DATA_VMA      = 0x70F41000;
TAREA_2_RODATA_VMA    = 0x70F44000;
TAREA_2_PILA_VMA  	  = 0x70F42000;

TAREA_IDLE_TXT_VMA    = 0x70F60000;

/* ------------------ LMA ------------------ */

RESET_LMA       	  = 0x70010000;
PUBLIC_STACK_LMA      = 0x70020000;
ISR_TABLE_LMA         = 0x00000000;

SYSTABLES_TAREA_IDLE_LMA = 0x50020000;
SYSTABLES_TAREA_1_LMA = 0x50820000;
SYSTABLES_TAREA_2_LMA = 0x50C20000;

/* -------------- READING AREA ------------- */

TAREA1_READING_AREA_VMA = 0x70A00000;
TAREA1_READING_AREA_PHY = 0x80000000;

TAREA2_READING_AREA_VMA = 0x70A10000;
TAREA2_READING_AREA_PHY = 0x80010000;

/*Mapa de memoria*/

MEMORY
{
    public_ram : org = RESET_PHY, len = 512M
    public_stack : org = PUBLIC_STACK_PHY, len = 64k
}

SECTIONS
{   
    . = RESET_VMA;
    .text : {
        *(.reset_text*)
		*(.startup_text*)
		*(.c_init_text*)
		*(.reset_vector_text*)
		reset_vector_end = .;
        . = ALIGN(4);
        } > public_ram
    reset_size = SIZEOF(.text);

    .data : { 
        *(.data*);
        *(.comment*);
        *(.ARM.*);
    } > public_ram

    .bss : {
        . = ALIGN(4);
        bss_start = .;
        *(.bss*)
        bss_end = .;
        } > public_ram

    /* ------------------------------ Kernel ------------------------------ */
    /* Código de kernel */    
    KERNEL_TXT_LMA = .;
    .kernel KERNEL_TXT_VMA : AT (KERNEL_TXT_LMA)
    { 
        *(.kernel_text*)
		*(.c_kernel_text*)
        *(.c_interrupt_text*) 
        . = ALIGN(4); 
        } > public_ram
    kernel_size = SIZEOF(.kernel);

    /* BSS de kernel */ 
    KERNEL_BSS_LMA = kernel_size + LOADADDR(.kernel);
    .kernel_bss KERNEL_BSS_VMA : AT(KERNEL_BSS_LMA)
        {
            *(.kernel_bss*);
            . = ALIGN(4); 
        } > public_ram
    kernel_bss_size = SIZEOF(.kernel_bss);

    /* Data de kernel */ 
    KERNEL_DATA_LMA = kernel_bss_size + LOADADDR(.kernel_bss);
    .kernel_data KERNEL_DATA_VMA : AT(KERNEL_DATA_LMA)
        {
            *(.kernel_data*);
            . = ALIGN(4);
        } > public_ram
    kernel_data_size = SIZEOF(.kernel_data);

	/* ------------------------------ Tarea 1 ------------------------------ */

    /* Código de Tarea 1 */ 
    TAREA_1_TXT_LMA = kernel_data_size + LOADADDR(.kernel_data);
    .txt_tarea_1 TAREA_1_TXT_VMA : AT(TAREA_1_TXT_LMA)
        {
            *(.tarea_1_txt*);
            . = ALIGN(4);
        } > public_ram
    txt_tarea_1_size = SIZEOF(.txt_tarea_1);    

    /* BSS de Tarea 1 */ 
    TAREA_1_BSS_LMA = txt_tarea_1_size + LOADADDR(.txt_tarea_1);
    .bss_tarea_1 TAREA_1_BSS_VMA : AT(TAREA_1_BSS_LMA)
        {
            *(.tarea_1_bss*);
            . = ALIGN(4); 
        } > public_ram
    bss_tarea_1_size = SIZEOF(.bss_tarea_1);

    /* Data de Tarea 1 */ 
    TAREA_1_DATA_LMA = bss_tarea_1_size + LOADADDR(.bss_tarea_1);
    .data_tarea_1 TAREA_1_DATA_VMA : AT(TAREA_1_DATA_LMA)
        {
            *(.tarea_1_data*);
            . = ALIGN(4);
        } > public_ram
    data_tarea_1_size = SIZEOF(.data_tarea_1);

	/* ------------------------------ Tarea 2 ------------------------------ */

    /* Código de Tarea 2 */ 
    TAREA_2_TXT_LMA = data_tarea_1_size + LOADADDR(.data_tarea_1);
    .txt_tarea_2 TAREA_2_TXT_VMA : AT(TAREA_2_TXT_LMA)
        {
            *(.tarea_2_txt*);
            . = ALIGN(4);
        } > public_ram
    txt_tarea_2_size = SIZEOF(.txt_tarea_2);    

    /* BSS de Tarea 2 */ 
    TAREA_2_BSS_LMA = txt_tarea_2_size + LOADADDR(.txt_tarea_2);
    .bss_tarea_2 TAREA_2_BSS_VMA : AT(TAREA_2_BSS_LMA)
        {
            *(.tarea_2_bss*);
            . = ALIGN(4); 
        } > public_ram
    bss_tarea_2_size = SIZEOF(.bss_tarea_2);

    /* Data de Tarea 2 */ 
    TAREA_2_DATA_LMA = bss_tarea_2_size + LOADADDR(.bss_tarea_2);
    .data_tarea_2 TAREA_2_DATA_VMA : AT(TAREA_2_DATA_LMA)
        {
            *(.tarea_2_data*);
            . = ALIGN(4);
        } > public_ram
    data_tarea_2_size = SIZEOF(.data_tarea_2);

    /* ------------------------------ Tarea IDLE ------------------------------ */

    /* Código de Tarea IDLE */ 
    TAREA_IDLE_TXT_LMA = data_tarea_2_size + LOADADDR(.data_tarea_2);
    .txt_tarea_idle TAREA_IDLE_TXT_VMA : AT(TAREA_IDLE_TXT_LMA)
        {
            *(.idle_txt*);
            . = ALIGN(4);
        } > public_ram
    txt_tarea_idle_size = SIZEOF(.txt_tarea_idle);    

    /* ------------------------------- Pilas ---------------------------------- */

	/*Pila Kernel*/

    . = PUBLIC_STACK_PHY;
    .kernel_stack PUBLIC_STACK_VMA : AT(PUBLIC_STACK_LMA)
    {
        kernel_stack_start = .;
        . += IRQ_STACK_SIZE;
        . = ALIGN(4);
        kernel_irq_stack_top = .;

        . += FIQ_STACK_SIZE;
        . = ALIGN(4);
        kernel_fiq_stack_top = .;

        . += SVC_STACK_SIZE;
        . = ALIGN(4);
        kernel_svc_stack_top = .;

        . += ABT_STACK_SIZE;
        . = ALIGN(4);
        kernel_abt_stack_top = .;

        . += UND_STACK_SIZE;
        . = ALIGN(4);
        kernel_und_stack_top = .;

        . += C_STACK_SIZE;
        . = ALIGN(4);
        kernel_sys_stack_top = .;

        kernel_stack_end = .;
    } > public_ram

    /*Pila tarea 1*/

    . = TAREA_1_PILA_PHY;
    .tarea1_stack TAREA_1_PILA_VMA : AT(TAREA_1_PILA_VMA)
    {
        tarea1_stack_start = .;
        . += IRQ_STACK_SIZE;
        . = ALIGN(4);
        tarea1_irq_stack_top = .;

        . += FIQ_STACK_SIZE;
        . = ALIGN(4);
        tarea1_fiq_stack_top = .;

        . += SVC_STACK_SIZE;
        . = ALIGN(4);
        tarea1_svc_stack_top = .;

        . += ABT_STACK_SIZE;
        . = ALIGN(4);
        tarea1_abt_stack_top = .;

        . += UND_STACK_SIZE;
        . = ALIGN(4);
        tarea1_und_stack_top = .;

        . += C_STACK_SIZE;
        . = ALIGN(4);
        tarea1_sys_stack_top = .;

        tarea1_stack_end = .;
    } > public_ram
    
    /*Pila tarea 2*/

    . = TAREA_2_PILA_PHY;
    .tarea2_stack TAREA_2_PILA_VMA : AT(TAREA_2_PILA_VMA)
    {
        tarea2_stack_start = .;
        . += IRQ_STACK_SIZE;
        . = ALIGN(4);
        tarea2_irq_stack_top = .;

        . += FIQ_STACK_SIZE;
        . = ALIGN(4);
        tarea2_fiq_stack_top = .;

        . += SVC_STACK_SIZE;
        . = ALIGN(4);
        tarea2_svc_stack_top = .;

        . += ABT_STACK_SIZE;
        . = ALIGN(4);
        tarea2_abt_stack_top = .;

        . += UND_STACK_SIZE;
        . = ALIGN(4);
        tarea2_und_stack_top = .;

        . += C_STACK_SIZE;
        . = ALIGN(4);
        tarea2_sys_stack_top = .;

        tarea2_stack_end = .;
    } > public_ram

}