#include <stdint.h>

__attribute__((section(".c_init_text"))) void MMU_NewPage(uint32_t TTBR0, uint32_t PHY_ADDR, uint32_t VIR_ADDR)
{

    uint32_t* direccion_n1;
    uint32_t descriptor_n1;
    uint32_t* direccion_n2;
    uint32_t descriptor_n2;
    uint32_t buffer;
    uint8_t n_pages=0;
    uint8_t ready=0;

    buffer = TTBR0 + (((VIR_ADDR & 0xFFF00000)>>20)*4);
    direccion_n1 = buffer;

    while(ready==0){

        if(*direccion_n1==0){

            buffer =  TTBR0 + 0x4000 + 0x100 * n_pages * 4 + (((VIR_ADDR & 0x000FF000)>>12)*4);      //las paginas de nivel 2 están pegadas 16k más abajo de TTBR0 y separadas 4k entre sí
            direccion_n2 = buffer;              //base de la tabla n de nivel 2 + slot 

            if(*direccion_n2==0){
                descriptor_n1 = TTBR0 + 0x4000 + 0x100 * n_pages * 4 + 0x1;       //base de la tabla n de nivel 2    
                *direccion_n1 = descriptor_n1;
            
                descriptor_n2 = PHY_ADDR | 0x32;
                *direccion_n2 = descriptor_n2;
                ready = 1;
            }else{
                n_pages++;
            }

        }else{

            buffer = *direccion_n1 - 0x1 + (((VIR_ADDR & 0x000FF000)>>12)*4);             //le saco los flags, le sumo el slot
            direccion_n2 = buffer;
            if(*direccion_n2==0){
                descriptor_n2 = PHY_ADDR | 0x32;
                *direccion_n2 = descriptor_n2;
                ready = 1;
            }
        }
    }
}