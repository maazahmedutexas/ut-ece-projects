# UT Austin ECE Projects — Maaz Ahmed

Hardware, embedded systems, and software projects from my Electrical and Computer Engineering coursework at The University of Texas at Austin.

---

## ⚡ Buck Converter — ECE 302H

Designed, assembled, and tested a PWM-controlled DC–DC buck converter that steps down 10–16 V inputs using discrete power electronics.

**Highlights:** NMOS power MOSFETs with gate driver IC, LC output filter, op-amp high-side current sensing, tested under 10 W resistive load.

**Skills:** Power Electronics, PCB Assembly, Soldering, Oscilloscope Debugging, KiCad, Analog Feedback

📁 `buck-converter/`

---

## 🚦 Traffic Light FSM — ECE 319H

Finite state machine controller for a two-road intersection with pedestrian crossing, built entirely with a linked data structure in C — no conditional branches in the engine. Three sensor inputs (south, west, walk) drive nine LED outputs through the FSM with safe all-red transitions and a flashing don't-walk sequence.

**Highlights:** Moore FSM with ~15 states and 8-way branching per state, SysTick timer delays, Darlington transistor LED drivers, positive-logic switch interfaces on the MSPM0G3507.

**Skills:** Finite State Machines, Embedded C, GPIO Interfacing, Hardware Debugging

📁 `traffic-light-fsm/`

---

## 🎹 Digital Piano — ECE 319H

Four-key synthesizer built around a 5-bit binary-weighted resistor DAC. A SysTick interrupt service routine outputs a sampled sine wave to the DAC at a rate that sets the pitch, while the main loop polls the keyboard — a simple two-thread foreground/background architecture.

**Highlights:** Custom resistor-network DAC (0.75 kΩ–12 kΩ), interrupt-driven waveform generation, four-switch keyboard with frequency verification on an oscilloscope and spectrum analyzer.

**Skills:** DACs, SysTick Interrupts, Multithreading (ISR + main loop), Analog Circuit Design, Embedded C

📁 `digital-piano-dac/`

---

## 🖥️ LCD Device Driver — ECE 319H

Bare-metal device driver for the Sitronix ST7735R 160×128 LCD, written in ARM assembly on the MSPM0G3507. Implements SPI busy-wait synchronization, integer-to-decimal string conversion with stack-based local variables, and fixed-point number display.

**Highlights:** SPI command/data output routines in assembly, recursive `OutDec` for integer-to-ASCII conversion, scope-verified byte and character transmission timing.

**Skills:** ARM Assembly, SPI Protocol, Device Drivers, Busy-Wait Synchronization, Fixed-Point Arithmetic

📁 `lcd-device-driver/`

---

## 🧠 Memory Pool Allocator — ECE 312H

Custom memory manager that operates on a fixed 4096-byte pool — essentially a simplified `malloc`/`free` implementation. Manages allocations with a doubly-linked, address-ordered free list, first-fit search, block splitting, and coalescing of adjacent free blocks.

**Highlights:** Doubly-linked free list with address-ordered insertion, block splitting with external heap headers, multi-block coalescing chains, fragmentation tracking, double-free and invalid-pointer detection.

**Skills:** C, Dynamic Memory Management, Linked Lists, Systems Programming

📁 `memory-pool-allocator/`

---

## 📦 Data Structures in C — ECE 312H

Implementations of core data structures from scratch: a **dynamic array** (auto-resizing with `realloc`, similar to `std::vector`) and a **singly linked list** with full insert/remove/traverse operations. Both are Valgrind-clean with no memory leaks.

**Skills:** C, Pointers, `malloc`/`realloc`/`free`, Edge-Case Handling

📁 `dynamic-array/` · `linked-list/`

---

## About Me

ECE Honors student at UT Austin focused on computer architecture, embedded systems, and low-level software. Interested in hardware/software interaction, firmware, digital systems, data science, and human-machine interaction.

[LinkedIn](https://www.linkedin.com/in/maaz-ahmed-utexas) · maazahmed@utexas.edu
