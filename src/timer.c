#include "../inc/timer.h"

__attribute__((section(".c_init_text"))) void timer_init()
{
    _timer_t* const TIMER0 = ( _timer_t* )TIMER0_ADDR;

    TIMER0->Timer1Load     = 0x00000100;            //Cargo el valor de contador de timer
    TIMER0->Timer1Ctrl     = 0x00000002;            //TimerSize = 1 ==> Timer de 32 bits
    TIMER0->Timer1Ctrl    |= 0x00000040;            //TimerMode = 1 ==> Periódico
    TIMER0->Timer1Ctrl    |= 0x00000020;            //IntEnable = 1 ==> Habilito la interrupción del timer
    TIMER0->Timer1Ctrl    |= 0x00000080;            //TimerEn = 1   ==> Prendo el timer

}