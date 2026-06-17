#include "../inc/gic.h"
#include "../inc/timer.h"
#include "../inc/mmu_tools_.h"
asm(".code 32");

extern const void SYSTABLES_TAREA_1_PHY;
extern const void SYSTABLES_TAREA_2_PHY;
extern const void SYSTABLES_TAREA_IDLE_PHY;
extern void t1_stack_init();
extern void t2_stack_init();
extern void kernel_stack_init();
extern void MMU_Set_FirstLevelTranslationTable_PhysicalAddress(uint32_t);

typedef struct ctx_t{

    uint32_t cpsr, pc, gpr[13], sp, lr;

}ctx_t;

__attribute__((section(".c_interrupt_text"))) void handler_irq(void *stack_pointer)
{
    _timer_t* const TIMER0 = (_timer_t*) TIMER0_ADDR;
    _gicc_t* const GICC0 = (_gicc_t*) GICC0_ADDR;
    uint32_t id = GICC0->IAR;
    __attribute__((section(".kernel_data"))) uint32_t static i = 0;
    
    switch (id)
    {
    case GIC_SOURCE_TIMER0:                          //Valor 36

            TIMER0->Timer1IntClr = 0x01;             //Limpio la interrupción del timer

            if(i==10)
            i=0;
            else
            i++;

            switch (i)
            {
            case 1:
                /* Pongo en contexto tarea 1 */
                //MMU_Set_FirstLevelTranslationTable_PhysicalAddress((uint32_t)&SYSTABLES_TAREA_1_PHY);           /*Seteo TTBR0*/
                
                asm("LDR R0,=SYSTABLES_TAREA_1_PHY");     
                asm("MCR P15, 0, R0, C2, C0, 0");                 

                asm("LDR R0, =0x55555555");
                asm("MCR P15, 0, R0, C3, C0, 0");                 
                
                GICC0->EOIR = id;
                t1_stack_init();                                                                                /*Cargo los SPs*/
                break;

            case 2:
                
                //MMU_Set_FirstLevelTranslationTable_PhysicalAddress((uint32_t)&SYSTABLES_TAREA_2_PHY); 

                asm("LDR R0,=SYSTABLES_TAREA_2_PHY");     
                asm("MCR P15, 0, R0, C2, C0, 0");                 

                asm("LDR R0, =0x55555555");
                asm("MCR P15, 0, R0, C3, C0, 0");

                GICC0->EOIR = id;         
                t2_stack_init();                                                                                
                break;  

            default:
                //MMU_Set_FirstLevelTranslationTable_PhysicalAddress((uint32_t)&SYSTABLES_TAREA_IDLE_PHY);   

                asm("LDR R0,=SYSTABLES_TAREA_IDLE_PHY");     
                asm("MCR P15, 0, R0, C2, C0, 0");                 

                asm("LDR R0, =0x55555555");
                asm("MCR P15, 0, R0, C3, C0, 0");

                GICC0->EOIR = id;        
                kernel_stack_init();                                                                           
                break;
            }

        break;
    
    default:
        break;
    }

}