CHAIN=arm-none-eabi
CFLAGS=-std=gnu99 -Wall -mcpu=cortex-a8
ASFLAGS=-x assembler-with-cpp -mcpu=cortex-a8
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

#Ensamblado de archivos .S con preprocesador C habilitado
$(OBJ)tareas.o: $(SRC)tareas.S
	mkdir -p bin obj lst
	@echo "Compilando tareas.S"
	$(CHAIN)-gcc $(ASFLAGS) -c $(SRC)tareas.S -o $(OBJ)tareas.o

$(OBJ)reset.o: $(SRC)reset.S
	mkdir -p bin obj lst
	@echo "Compilando reset.S"
	$(CHAIN)-gcc $(ASFLAGS) -c $(SRC)reset.S -o $(OBJ)reset.o

$(OBJ)reset_vector.o: $(SRC)reset_vector.S
	mkdir -p bin obj lst
	@echo "Compilando reset_vector.S"
	$(CHAIN)-gcc $(ASFLAGS) -c $(SRC)reset_vector.S -o $(OBJ)reset_vector.o

$(OBJ)startup.o: $(SRC)startup.S
	mkdir -p bin obj lst
	@echo "Compilando startup.S"
	$(CHAIN)-gcc $(ASFLAGS) -c $(SRC)startup.S -o $(OBJ)startup.o

$(OBJ)exception_handler.o: $(SRC)exception_handler.S
	mkdir -p bin obj lst
	@echo "Compilando exception_handler.S"
	$(CHAIN)-gcc $(ASFLAGS) -c $(SRC)exception_handler.S -o $(OBJ)exception_handler.o

#Compilacion de archivos C
$(OBJ)gic.o: $(SRC)gic.c
	mkdir -p bin obj lst
	@echo "Compilando gic.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)gic.c -o $(OBJ)gic.o

$(OBJ)timer.o: $(SRC)timer.c
	mkdir -p bin obj lst
	@echo "Compilando timer.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)timer.c -o $(OBJ)timer.o

$(OBJ)handler_irq.o: $(SRC)handler_irq.c
	mkdir -p bin obj lst
	@echo "Compilando handler_irq.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)handler_irq.c -o $(OBJ)handler_irq.o

$(OBJ)paginacion.o: $(SRC)paginacion.c
	mkdir -p bin obj lst
	@echo "Compilando paginacion.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)paginacion.c -o $(OBJ)paginacion.o

$(OBJ)memcpy.o: $(SRC)memcpy.c
	mkdir -p bin obj lst
	@echo "Compilando memcpy.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)memcpy.c -o $(OBJ)memcpy.o

$(OBJ)mmu_tools_.o: $(SRC)mmu_tools_.c
	mkdir -p bin obj lst
	@echo "Compilando mmu_tools_.c"
	$(CHAIN)-gcc -O3 $(CFLAGS) -c $(SRC)mmu_tools_.c -o $(OBJ)mmu_tools_.o

clean:
	rm -rf $(OBJ)*.o
	rm -rf $(OBJ)*.elf
	rm -rf $(BIN)*.bin
	rm -rf $(LST)*.lst
	rm -rf $(LST)*.txt
	rm -rf $(LST)*.map
