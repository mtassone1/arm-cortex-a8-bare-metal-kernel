#include "../inc/gic.h"

__attribute__((section(".c_init_text"))) void gic_init()
{
        //Header para definir estructura de datos y que funcione como puntero a memoria
        _gicc_t* const GICC0 = (_gicc_t*)GICC0_ADDR;
        _gicd_t* const GICD0 = (_gicd_t*)GICD0_ADDR;

        GICC0->PMR  = 0x000000F0;                       // Priority mask [7:4] = 1111  ==> enmascaro interrupciones de prioridad 0xF, de 0x0 a 0xE no
        // ISENABLER[1] maneja las interrupciones de la 32 a la 63
        GICD0->ISENABLER[1] |= 0x00000010;              // Habilito la interrupción del bit 4  ==> interrupción 36 (TIMER0)
        //GICD0->ISENABLER[1] |= 0x00001000;            // Habilito la interrupción del bit 12 ==> interrupción 44 (UART0)
        GICC0->CTLR         = 0x00000001;               // Habilito el CPU interface para el GIC 0
        GICD0->CTLR         = 0x00000001;               // Habilito las interrupciones para el GIC 0

}