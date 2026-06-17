# 🖥️ ARM Cortex-A8 Bare-Metal Kernel

> A bare-metal ARMv7-A kernel implementing interrupt-driven multitasking, MMU-based virtual memory, independent task address spaces, exception handling, and timer-based scheduling — built entirely from scratch in C and ARM Assembly.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Core Components](#core-components)
- [Memory Layout](#memory-layout)
- [Build Instructions](#build-instructions)
- [Concepts Demonstrated](#concepts-demonstrated)

---

## Overview

This project is a fully standalone embedded kernel targeting the **ARM Cortex-A8 (ARMv7-A)** processor. It runs on bare metal — no operating system, no standard library, no runtime — just raw hardware and code.

The kernel boots from reset, configures the MMU, sets up interrupt handling via the ARM Generic Interrupt Controller (GIC), and runs multiple isolated tasks with independent virtual address spaces. A timer-driven scheduler performs preemptive context switching between tasks, with each switch also swapping the active page table to provide basic process isolation.

This project was developed as part of an advanced university-level course on **Operating Systems and Computer Architecture**, and demonstrates a deep understanding of ARM system programming at the lowest possible level.

---

## Features

- **Bare-metal boot sequence** — Custom reset vector, stack initialization, BSS clearing, and section relocation with no OS support
- **ARM exception model** — Full exception vector table handling IRQ, FIQ, SVC, Undefined Instruction, Prefetch Abort, and Data Abort
- **Generic Interrupt Controller (GIC)** — Configures the ARM GIC distributor and CPU interface for peripheral interrupt routing
- **Timer-based preemptive scheduler** — Hardware timer triggers context switches at regular intervals, rotating between Task 1, Task 2, and the Idle Task
- **MMU with virtual memory** — Enables the ARM MMU, builds first-level translation tables, and manages domain access control
- **Multiple independent address spaces** — Each task has its own translation table; TTBR0 is swapped on every context switch to isolate task memory
- **Context switching in assembly** — Full CPU state save/restore (general-purpose registers + SPSR) implemented in ARM Assembly
- **Custom linker script** — Explicit VMA/LMA separation, dedicated memory regions per task, and translation table placement controlled via `td3_memmap.ld`
- **Dual-language implementation** — System-level logic in GNU C99; performance-critical and hardware-interface code in ARMv7-A Assembly

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│                  ARM Cortex-A8                  │
│                                                 │
│  ┌──────────┐   ┌──────────┐   ┌────────────┐  │
│  │  Task 1  │   │  Task 2  │   │  Idle Task │  │
│  │ (own PT) │   │ (own PT) │   │  (own PT)  │  │
│  └────┬─────┘   └────┬─────┘   └─────┬──────┘  │
│       │              │               │          │
│       └──────────────┼───────────────┘          │
│                      │ Timer IRQ                │
│               ┌──────▼──────┐                  │
│               │  Scheduler  │  (handler_irq.c) │
│               │  + TTBR0    │                  │
│               │  swap       │                  │
│               └──────┬──────┘                  │
│                      │                         │
│        ┌─────────────▼──────────────┐          │
│        │         GIC / Timer        │          │
│        │   (gic.c / timer.c)        │          │
│        └────────────────────────────┘          │
│                                                 │
│        ┌────────────────────────────┐           │
│        │     MMU / Page Tables      │           │
│        │  (mmu_tools_.c / paginacion│.c)        │
│        └────────────────────────────┘           │
└─────────────────────────────────────────────────┘
```

**Toolchain:** `arm-none-eabi-gcc`, `arm-none-eabi-as`, `arm-none-eabi-ld`, `arm-none-eabi-objcopy`  
**Target CPU:** ARM Cortex-A8 (`-mcpu=cortex-a8`)  
**Output:** `bin/bios.bin` (raw binary), `obj/bios.elf` (ELF image)

---

## Project Structure

```
.
├── inc/
│   ├── gic.h                   # GIC driver interface
│   ├── low_level_cpu_access.h  # CP15 register access declarations
│   ├── mmu_tools_.h            # MMU utility declarations
│   └── timer.h                 # Timer driver interface
│
├── src/
│   ├── startup.s               # CPU & stack initialization
│   ├── reset.s                 # Reset entry point
│   ├── reset_vector.s          # ARM exception vector table
│   ├── exception_handler.s     # Exception/IRQ handlers (ASM)
│   ├── low_level_cpu_access.s  # CP15 coprocessor wrappers (ASM)
│   ├── tareas.s                # Task definitions (ASM)
│   ├── gic.c                   # GIC driver
│   ├── timer.c                 # Timer driver
│   ├── handler_irq.c           # IRQ dispatcher / scheduler
│   ├── mmu_tools_.c            # MMU control utilities
│   ├── paginacion.c            # Page table construction
│   └── memcpy.c                # Custom memory copy
│
├── td3_memmap.ld               # Linker script (memory layout)
├── makefile
└── lst/                        # Build listings and map files
```

---

## Core Components

### Boot Sequence (`startup.s`, `reset.s`, `reset_vector.s`)
Handles full CPU initialization from power-on: sets processor mode, initializes stacks for all ARM privilege modes, clears BSS, relocates sections, configures the MMU, and enables interrupts before jumping to the main kernel loop.

### Exception Handling (`exception_handler.s`)
Implements the complete ARM exception vector table. The IRQ handler saves all CPU registers and SPSR onto the IRQ stack, then dispatches to the C-level `handler_irq()` function. On return, the saved context is restored and execution resumes via `SUBS PC, LR, #4`.

### Interrupt Controller (`gic.c`)
Configures the ARM Generic Interrupt Controller to route timer interrupts (GIC source 36) to the CPU. Initializes the GIC distributor and CPU interface, sets priority masks, and enables interrupt forwarding.

### Scheduler (`handler_irq.c`)
Implements a round-robin scheduler triggered by the hardware timer. On each interrupt, the scheduler selects the next task, updates TTBR0 to point to that task's translation table (switching address space), and restores the task's saved CPU context to resume execution.

### MMU & Virtual Memory (`mmu_tools_.c`, `paginacion.c`)
Provides C wrappers for ARM CP15 coprocessor registers (TTBR0, DACR, SCTLR). The `MMU_NewPage()` function constructs first-level page table entries. TLB invalidation is performed on every address space switch.

### Tasks (`tareas.s`)
Three tasks are defined in assembly and placed into dedicated linker sections (`.tarea_1_txt`, `.tarea_2_txt`, `.idle_txt`). Each task runs in its own virtual address space.

---

## Memory Layout

Defined entirely in `td3_memmap.ld`. Physical and virtual addresses are separated (VMA/LMA), with the MMU bridging them at runtime.

| Region               | Type               | Description                          |
|----------------------|--------------------|--------------------------------------|
| `KERNEL_TXT/DATA/BSS`| Kernel             | Core kernel code and data            |
| `TAREA_1_TXT/DATA/BSS/PILA` | Task 1    | Task 1 code, data, BSS, and stack   |
| `TAREA_2_TXT/DATA/BSS/PILA` | Task 2    | Task 2 code, data, BSS, and stack   |
| `TAREA_IDLE_TXT`     | Idle Task          | Idle task code                       |
| `SYSTABLES_TAREA_*_PHY` | Translation Tables | Per-task MMU page tables         |

---

## Build Instructions

**Requirements:** GNU ARM Embedded Toolchain (`arm-none-eabi-*`) installed and on your `PATH`.

```bash
# Clone the repository
git clone https://github.com/mtassone1/<repo-name>.git
cd <repo-name>

# Build the project
make

# Outputs:
#   bin/bios.bin   — Raw binary for flashing/emulation
#   obj/bios.elf   — ELF image with debug symbols
#   lst/bios.map   — Linker map file
#   lst/bios.lst   — Disassembly listing

# Clean build artifacts
make clean
```

---

## Running / Emulation (QEMU)

The hardware target is the **BeagleBone Black** (TI AM335x / ARM Cortex-A8). QEMU does not have a native `am335x` machine type; the closest upstream substitute is `-M beagle` (BeagleBoard, OMAP3/Cortex-A8), which correctly emulates the ARM core, MMU, GIC, and generic timer used by this project.

```bash
# Recommended: load the ELF directly (QEMU places segments at correct addresses)
qemu-system-arm \
  -M beagle \
  -cpu cortex-a8 \
  -m 512M \
  -kernel obj/bios.elf \
  -serial stdio \
  -nographic

# Alternative: load the raw binary at the BBB internal SRAM base address
qemu-system-arm \
  -M beagle \
  -cpu cortex-a8 \
  -m 512M \
  -device loader,file=bin/bios.bin,addr=0x402F0400,cpu-num=0 \
  -serial stdio \
  -nographic

# Debug session: pause CPU at startup and open a GDB server on port 1234
qemu-system-arm \
  -M beagle \
  -cpu cortex-a8 \
  -m 512M \
  -kernel obj/bios.elf \
  -serial stdio \
  -nographic \
  -S -gdb tcp::1234

# In a second terminal, connect with GDB:
arm-none-eabi-gdb obj/bios.elf \
  -ex "target remote :1234" \
  -ex "continue"
```

> **Notes:**
> - `-nographic` redirects serial output to your terminal. Press **`Ctrl-A X`** to quit QEMU.
> - The raw binary load address `0x402F0400` matches the AM335x internal SRAM region where the BBB ROM bootloader places the first-stage image. Adjust to match `RESET_PHY` in `td3_memmap.ld` if your layout differs.
> - AM335x-specific peripherals (PRU, PRUSS, certain timers) are not present in the `beagle` machine, but all core ARM functionality exercised by this project will behave correctly.

---

## Concepts Demonstrated

| Category | Topics |
|---|---|
| **ARM Architecture** | Cortex-A8, ARMv7-A, processor modes, CP15 coprocessor |
| **Exception Handling** | IRQ, FIQ, SVC, Abort, exception vectors, SPSR/CPSR management |
| **Interrupt Management** | GIC initialization, interrupt routing, priority masking |
| **Memory Management** | MMU configuration, first-level translation tables, TTBR0/DACR/SCTLR |
| **Virtual Memory** | VMA/LMA separation, per-task address spaces, TLB invalidation |
| **Scheduling** | Timer-driven preemption, round-robin task selection |
| **Context Switching** | Full register save/restore in assembly, SPSR preservation |
| **Embedded Systems** | Bare-metal startup, no-OS execution, custom linker scripts |
| **Languages** | C (GNU99), ARMv7-A Assembly |
