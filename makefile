CHAIN=arm-none-eabi
CFLAGS=-std=gnu99 -Wall -mcpu=cortex-a8
LDEXTRAS= -lc -L /usr/lib/arm-none-eabi/newlib/

OBJ=obj/
BIN=bin/
INC=inc/
SRC=src/
LST=lst/

all: $(BIN)bios.bin $(OBJ)bios.elf

#Genero el binario

$(BIN)bios.bin: $(OBJ)bios.elf

	$(CHAIN)-objcopy -O binary $(OBJ)bios.elf $(BIN)bios.bin
	@echo "Binario creado"

#Linkeo objetos en archivo .elf

$(OBJ)bios.elf: $(OBJ)tareas.o $(OBJ)gic.o $(OBJ)exception_handler.o $(OBJ)startup.o $(OBJ)reset.o $(OBJ)reset_vector.o $(OBJ)handler_irq.o $(OBJ)timer.o $(OBJ)paginacion.o $(OBJ)mmu_tools_.o $(OBJ)memcpy.o
	
	@echo "Linkeando"
	mkdir -p obj
	mkdir -p lst
	$(CHAIN)-ld -T td3_memmap.ld $(OBJ)*.o -o $(OBJ)bios.elf -Map $(LST)bios.map
	@echo "Linkeado"
	@echo "Creando archivos de informacion"
	readelf -a $(OBJ)bios.elf > $(LST)bios_elf.txt
	$(CHAIN)-objdump -D $(OBJ)bios.elf > $(LST)bios.lst

#Ensamblado de archivo assembler, genero los objetos

$(OBJ)tareas.o: $(SRC)tareas.s
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando tareas.s"
	$(CHAIN)-as $(SRC)tareas.s -o $(OBJ)tareas.o -a > $(LST)tareas.lst

$(OBJ)reset.o: $(SRC)reset.s
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando reset.s"
	$(CHAIN)-as $(SRC)reset.s -o $(OBJ)reset.o -a > $(LST)reset.lst

$(OBJ)reset_vector.o: $(SRC)reset_vector.s
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando reset_vector.s"
	$(CHAIN)-as $(SRC)reset_vector.s -o $(OBJ)reset_vector.o -a > $(LST)reset_vector.lst

$(OBJ)startup.o: $(SRC)startup.s
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando startup.s"
	$(CHAIN)-as $(SRC)startup.s -o $(OBJ)startup.o -a > $(LST)startup.lst

$(OBJ)exception_handler.o: $(SRC)exception_handler.s
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando exception_handler.s"
	$(CHAIN)-as $(SRC)exception_handler.s -o $(OBJ)exception_handler.o -a > $(LST)exception_handler.lst

#Ensamblado de archivo en c, genero los objetos

$(OBJ)gic.o: $(SRC)gic.c
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando gic.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)gic.c -o $(OBJ)gic.o

$(OBJ)timer.o: $(SRC)timer.c
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando timer.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)timer.c -o $(OBJ)timer.o

$(OBJ)handler_irq.o: $(SRC)handler_irq.c
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando handler_irq.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)handler_irq.c -o $(OBJ)handler_irq.o

$(OBJ)paginacion.o: $(SRC)paginacion.c
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando paginacion.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)paginacion.c -o $(OBJ)paginacion.o

$(OBJ)memcpy.o: $(SRC)memcpy.c
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando memcpy.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)memcpy.c -o $(OBJ)memcpy.o

$(OBJ)mmu_tools_.o: $(SRC)mmu_tools_.c
	
	mkdir -p bin
	mkdir -p obj
	mkdir -p lst
	@echo "Compilando mmu_tools_.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)mmu_tools_.c -o $(OBJ)mmu_tools_.o

clean:

	rm -rf $(OBJ)*.o
	rm -rf $(OBJ)*.elf
	rm -rf $(BIN)*.bin
	rm -rf $(LST)*.lst
	rm -rf $(LST)*.txt
	rm -rf $(LST)*.map