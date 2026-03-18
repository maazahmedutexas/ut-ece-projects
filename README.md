# UT Austin ECE Projects — Maaz Ahmed

Hardware, embedded systems, and software projects from my ECE coursework at The University of Texas at Austin.

---

## 🔧 ECE 319H PCB — Embedded Game System Board *(In Progress)*

**Course:** ECE 319H — Introduction to Embedded Systems (Honors)

Custom two-layer PCB designed in KiCad for a handheld embedded game system built around the TI MSPM0G3507 microcontroller. The board consolidates all hardware interfaces from Labs 5–9 onto a single manufactured circuit board, replacing breadboard wiring with proper routed traces, test points, and mounting hardware.

**Hardware on board:**
- 5-bit binary-weighted DAC with speaker output for sound generation
- ST7735R SPI LCD interface (160×128) for graphics rendering
- 4 tactile switches with 10kΩ pull-down resistors and ULN2003A Darlington driver for LEDs
- Slide potentiometer on ADC input with dedicated test point
- 3-pin jumper headers for UART loopback (Lab 8 IR communication)
- TSOP31438 IR receiver and IR LED output interface for wireless serial communication
- TExaS oscilloscope analog mux (jumper-selectable between DAC output and slide pot)
- 4-40 mounting holes and dual 20-pin headers for LaunchPad connection

**Design process:** Schematic capture → ERC validation → component placement for ergonomic handheld use → power/ground star routing (0.5mm traces) → signal routing (0.2mm traces) → DRC → Gerber generation → fabrication by JLCPCB

**Tools:** KiCad 9, JLCPCB

📁 `pcb-game-system/`

---

## ⚡ Buck Converter — ECE 302H

PWM-controlled DC–DC buck converter designed to step down 10–16V inputs using discrete power electronics. Assembled and tested under a 10W resistive load.

- NMOS power MOSFETs with gate driver IC
- LC output filter with op-amp–based high-side current sensing
- Designed in KiCad, hand-soldered, debugged with oscilloscope

**Tools:** KiCad, Oscilloscope, Soldering

📁 `buck-converter/`

---

## 🎮 Embedded Systems Labs — ECE 319K

### Traffic Light FSM Controller (Lab 4)

Finite state machine controller for a traffic intersection with pedestrian crossing, implemented entirely with a linked data structure — no conditional branching. States, transitions, and output logic are encoded in a struct array indexed by next-state pointers.

**Tools:** C, TI MSPM0G3507, GPIO

📁 `traffic-light-fsm/`

### Digital Piano with DAC (Lab 5)

Built a 5-bit binary-weighted DAC from discrete resistors to generate audio waveforms. Wrote interrupt-driven sound routines (SysTick at 11kHz) with a foreground/background multithreaded architecture. Piano keys are read via GPIO and mapped to frequency lookup tables.

**Tools:** C, SysTick Interrupts, DAC Design, GPIO

📁 `digital-piano-dac/`

### ST7735R LCD Device Driver (Lab 6)

SPI device driver for the ST7735R 160×128 LCD. Implemented busy-wait synchronization for SPI transactions and wrote fixed-point decimal and integer-to-string conversion routines in ARM assembly (`StringConversion.s`). Driver supports pixel drawing, line rendering, and formatted text output.

**Tools:** C, ARM Assembly, SPI, Busy-Wait Synchronization

📁 `lcd-device-driver/`

---

## 🧠 Software Design Labs — ECE 312

### Memory Pool Allocator (Lab 3)

Custom memory allocator built from scratch — manages a fixed-size memory pool using an explicit free list with first-fit allocation. Handles allocation, deallocation, and coalescing of adjacent free blocks to reduce fragmentation. No calls to `malloc` or `free`.

**Tools:** C, Pointers, Dynamic Memory Management

📁 `memory-pool-allocator/`

### Foundational Data Structures (Labs 1–2)

Implementations of a dynamic array with amortized-doubling resize strategy and a singly linked list with insert, delete, search, and reversal operations. Both use manual heap allocation and pointer manipulation.

📁 `dynamic-array/` · `linked-list/`

---

## About Me

ECE Honors student at UT Austin. Interested in computer architecture, embedded systems, firmware, digital design, and hardware-software interaction. Also into data science, predictive analytics, and human-machine interaction.

[LinkedIn](https://www.linkedin.com/in/maaz-ahmed-utexas) · maazahmed@utexas.edu
