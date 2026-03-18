/* ECE319K_Lab4main.c
 * Traffic light FSM
 * ECE319H students must use pointers for next state
 * ECE319K students can use indices or pointers for next state
 * Put your names here or look silly
 Maaz Ahmed
  */

#include <ti/devices/msp/msp.h>
#include "../inc/LaunchPad.h"
#include "../inc/Clock.h"
#include "../inc/UART.h"
#include "../inc/Timer.h"
#include "../inc/Dump.h"  // student's Lab 3
#include <stdio.h>
#include <string.h>
// put your EID in the next line
const char EID1[] = "MA69299"; //  ;replace abc123 with your EID
// Hint implement Traffic_Out before creating the struct, make struct match your Traffic_Out

// initialize all 6 LED outputs and 3 switch inputs
// assumes LaunchPad_Init resets and powers A and B

struct State {
  uint32_t West;
  uint32_t South;
  uint32_t Walk;
  uint32_t Time;
  uint32_t Next[8];
};
typedef const struct State STyp;

#define goSouth 0
#define waitSouth 1
#define allRed1 2
#define goWalk 3
#define walkWarning1 4
#define walkWarning2 5
#define walkWarning3 6
#define walkWarning4 7
#define walkWarning5 8
#define allRed2 9
#define goWest 10
#define waitWest 11
#define allRed3 12

STyp FSM[13] = {
  // 0: goSouth
  {4, 1, 2, 30, {goSouth, waitSouth, goSouth, waitSouth, waitSouth, waitSouth, waitSouth, waitSouth}},
  // 1: waitSouth
  {4, 2, 2, 5, {allRed1, allRed1, allRed1, allRed1, allRed1, allRed1, allRed1, allRed1}},
  // 2: allRed1 
  {4, 4, 2, 5, {goSouth, goWest, goSouth, goWest, goWalk, goWalk, goWalk, goWalk}},
  // 3: goWalk 
  {4, 4, 7, 30, {goWalk, walkWarning1, walkWarning1, walkWarning1, goWalk, walkWarning1, walkWarning1, walkWarning1}},
  // 4: walkWarning1 (Red)
  {4, 4, 2, 5, {walkWarning2, walkWarning2, walkWarning2, walkWarning2, walkWarning2, walkWarning2, walkWarning2, walkWarning2}},
  // 5: walkWarning2 (Off)
  {4, 4, 0, 5, {walkWarning3, walkWarning3, walkWarning3, walkWarning3, walkWarning3, walkWarning3, walkWarning3, walkWarning3}},
  // 6: walkWarning3 (Red)
  {4, 4, 2, 5, {walkWarning4, walkWarning4, walkWarning4, walkWarning4, walkWarning4, walkWarning4, walkWarning4, walkWarning4}},
  // 7: walkWarning4 (Off)
  {4, 4, 0, 5, {walkWarning5, walkWarning5, walkWarning5, walkWarning5, walkWarning5, walkWarning5, walkWarning5, walkWarning5}},
  // 8: walkWarning5 (Red)
  {4, 4, 2, 5, {allRed2, allRed2, allRed2, allRed2, allRed2, allRed2, allRed2, allRed2}},
  // 9: allRed2
  {4, 4, 2, 5, {goWalk, goWest, goSouth, goWest, goWalk, goWest, goSouth, goWest}},
  // 10: goWest 
  {1, 4, 2, 30, {goWest, goWest, waitWest, waitWest, waitWest, waitWest, waitWest, waitWest}},
  // 11: waitWest 
  {2, 4, 2, 5, {allRed3, allRed3, allRed3, allRed3, allRed3, allRed3, allRed3, allRed3}},
  // 12: allRed3
  {4, 4, 2, 5, {goWest, goWest, goSouth, goSouth, goWalk, goWalk, goSouth, goSouth}}
};

void Traffic_Init(void){ 
 
  IOMUX->SECCFG.PINCM[PB0INDEX] = 0x81;
  IOMUX->SECCFG.PINCM[PB1INDEX] = 0x81;
  IOMUX->SECCFG.PINCM[PB2INDEX] = 0x81;
  IOMUX->SECCFG.PINCM[PB6INDEX] = 0x81;
  IOMUX->SECCFG.PINCM[PB7INDEX] = 0x81;
  IOMUX->SECCFG.PINCM[PB8INDEX] = 0x81;

  
  IOMUX->SECCFG.PINCM[PB15INDEX] = 0x00040081;
  IOMUX->SECCFG.PINCM[PB16INDEX] = 0x00040081;
  IOMUX->SECCFG.PINCM[PB17INDEX] = 0x00040081;


  GPIOB->DOE31_0 |= 0x000001C7;
  GPIOB->DOE31_0 |= 0x0C400000;
  

  GPIOB->DOE31_0 &= ~0x00038000; 
}

void Traffic_Out(uint32_t west, uint32_t south, uint32_t walk){
  
uint32_t clear_mask = 0x0C4001C7;
uint32_t out = GPIOB->DOUT31_0 & ~clear_mask;
out |= (south & 0x07);
out |= ((west & 0x07) << 6);

if(walk & 0x01) out |= (1<<22); 
if(walk & 0x02) out |= (1<<26);
if(walk & 0x04) out |= (1<<27);
GPIOB->DOUT31_0 = out;

}
uint32_t Traffic_In(void){
    uint32_t in = GPIOB->DIN31_0;
    

    return (in >> 15) & 0x07;
}
void Lab4Grader(int mode);
void Grader_Init(void);
int main1(void){ // main1
  Clock_Init80MHz(0);
  LaunchPad_Init();
  Lab4Grader(0);
  while(1){
  }
}

int main2(void){ // main2
  Clock_Init80MHz(0);
  LaunchPad_Init();
  Grader_Init(); 
  LaunchPad_LED1off();
  Traffic_Init();
  if((GPIOB->DOE31_0 & 0x20)==0){
    UART_OutString("access to GPIOB->DOE31_0 should be friendly.\n\r");
  }
  UART_Init();
  UART_OutString("Lab 4, Spring 2026, Step 1. Debug LEDs\n\r");
  UART_OutString("EID1= "); UART_OutString((char*)EID1); UART_OutString("\n\r");
  while(1){
    
    Traffic_Out(0, 1, 0); Debug_Dump(GPIOB->DOUT31_0); Clock_Delay(8000000); 
    Traffic_Out(0, 2, 0); Debug_Dump(GPIOB->DOUT31_0); Clock_Delay(8000000); 
    Traffic_Out(0, 4, 0); Debug_Dump(GPIOB->DOUT31_0); Clock_Delay(8000000); 
    
    
    Traffic_Out(1, 0, 0); Debug_Dump(GPIOB->DOUT31_0); Clock_Delay(8000000); 
    Traffic_Out(2, 0, 0); Debug_Dump(GPIOB->DOUT31_0); Clock_Delay(8000000); 
    Traffic_Out(4, 0, 0); Debug_Dump(GPIOB->DOUT31_0); Clock_Delay(8000000); 
    
   
    Traffic_Out(0, 0, 2); Debug_Dump(GPIOB->DOUT31_0); Clock_Delay(8000000); 
    Traffic_Out(0, 0, 7); Debug_Dump(GPIOB->DOUT31_0); Clock_Delay(8000000); 
    if((GPIOB->DOE31_0&0x20) == 0){
    UART_OutString("DOUT not friendly\n\r");
    
    }
  }
}

int main3(void){ // main3
  uint32_t last=0,now;
  Clock_Init80MHz(0);
  LaunchPad_Init();
  Traffic_Init(); //  Lab 4 initialization
  Debug_Init();   // Lab 3 debugging
  UART_Init();
  __enable_irq(); // UART uses interrupts
  UART_OutString("Lab 4, Spring 2026, Step 2. Debug switches\n\r");
  UART_OutString("EID1= "); UART_OutString((char*)EID1); UART_OutString("\n\r");
  while(1){
    now = Traffic_In(); 
    if(now != last){ // 
      UART_OutString("Switch= 0x"); UART_OutUHex(now); UART_OutString("\n\r");
      Debug_Dump(now);
    }
    last = now;
    Clock_Delay(800000); // 10ms
  }
}
int main4(void){
  uint32_t input;
  uint32_t S = goSouth; 
  
  Clock_Init80MHz(0);
  LaunchPad_Init();
  LaunchPad_LED1off();
  Traffic_Init(); 
  
  Debug_Init();  
  UART_Init();
  __enable_irq(); 
  UART_OutString("Lab 4, Spring 2026, Step 3. Debug FSM cycle\n\r");
  UART_OutString("EID1= "); UART_OutString((char*)EID1); UART_OutString("\n\r");

  SysTick_Init();  

  while(1){
      
      Traffic_Out(FSM[S].West, FSM[S].South, FSM[S].Walk);
      
     
      uint32_t dumpData = (S << 24) | (FSM[S].West << 16) | (FSM[S].South << 8) | FSM[S].Walk;
      Debug_Dump(dumpData);
      
     
      for(uint32_t i = 0; i < FSM[S].Time; i++) {
          Clock_Delay(800000); // 10ms delay per tick
      }
      
      
      input = 7;
      
     
      S = FSM[S].Next[input];
  }
}

int main(void){// main5
  uint32_t input;
  uint32_t S = goSouth; 

  Clock_Init80MHz(0);
  LaunchPad_Init();
  Grader_Init(); 
  LaunchPad_LED1off();
  Traffic_Init(); 

  SysTick_Init();  
  
  Lab4Grader(1); 
  
  while(1){

      Traffic_Out(FSM[S].West, FSM[S].South, FSM[S].Walk);
      
      uint32_t dumpData = (S << 24) | (FSM[S].West << 16) | (FSM[S].South << 8) | FSM[S].Walk;
      Debug_Dump(dumpData);
      
      for(uint32_t i = 0; i < FSM[S].Time; i++) {
          Clock_Delay(800000); // 10ms delay per tick
      }
      
      input = Traffic_In();
      
      S = FSM[S].Next[input];
  }
}

