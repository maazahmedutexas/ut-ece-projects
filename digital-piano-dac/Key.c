/* Key.c
 * Students: Maaz Ahmed
 * Modified: March 1st, 2026
 * 4-bit keyboard connected to PB19-PB16
 */
#include <ti/devices/msp/msp.h>
#define PB16INDEX 32 
#define PB17INDEX 42 
#define PB18INDEX 43 
#define PB19INDEX 44 
#include "../inc/LaunchPad.h"

// **************Key_Init*********************
// Initialize piano key inputs on PB19-PB16
void Key_Init(void){
    // Assumes LaunchPad_Init has been called
    // Configure PB19-PB16 as GPIO inputs with internal pull-down resistors [cite: 45, 604]
    // 0x00040081: Bit 18=1 for pull-down, Bit 17=0 for pull-up/down enable, Bit 7=1 for input 
    IOMUX->SECCFG.PINCM[PB16INDEX] = 0x00040081;
    IOMUX->SECCFG.PINCM[PB17INDEX] = 0x00040081;
    IOMUX->SECCFG.PINCM[PB18INDEX] = 0x00040081;
    IOMUX->SECCFG.PINCM[PB19INDEX] = 0x00040081;
    
    // Set direction of PB19-PB16 to input (clear bits 19-16) 
    GPIOB->DOE31_0 &= ~0x000F0000; 
}

// **************Key_In*********************
// Input: none
// Output: 0 to 15 depending on keys
// 0x01 is Key0 (PB16), 0x02 is Key1 (PB17), 0x04 is Key2 (PB18), 0x08 is Key3 (PB19) 
uint32_t Key_In(void){
    // Read Port B, isolate bits 19-16, then shift right by 16 to get a 4-bit value 
    uint32_t data = (GPIOB->DIN31_0 & 0x000F0000) >> 16;
    return data; 
}