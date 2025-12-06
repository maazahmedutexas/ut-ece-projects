;***********************************************************
; Programming Assignment 4
; Student Name: Maaz
; UT Eid: Ahmed
; -------------------Save Simba (Part II)---------------------
; This is the starter code. You are given the main program
; and some declarations. The subroutines you are responsible for
; are given as empty stubs at the bottom. Follow the contract. 
; You are free to rearrange your subroutines if the need were to 
; arise.

;***********************************************************

.ORIG x4000

;***********************************************************
; Main Program
;***********************************************************
        JSR   DISPLAY_JUNGLE
        LEA   R0, JUNGLE_INITIAL
        TRAP  x22 
        LDI   R0,BLOCKS
        JSR   LOAD_JUNGLE
        JSR   DISPLAY_JUNGLE
        LEA   R0, JUNGLE_LOADED
        TRAP  x22                        ; output end message
HOMEBOUND
        LEA   R0, LC_OUT_STRING
        TRAP  x22
        LDI   R0,LC_LOC
        LD    R4,ASCII_OFFSET_POS
        ADD   R0, R0, R4
        TRAP  x21
        LEA   R0,PROMPT
        TRAP  x22
        TRAP  x20                        ; get a character from keyboard into R0
        TRAP  x21                        ; echo character entered
        LD    R3, ASCII_Q_COMPLEMENT     ; load the 2's complement of ASCII 'Q'
        ADD   R3, R0, R3                 ; compare the first character with 'Q'
        BRz   EXIT                       ; if input was 'Q', exit
;; call a converter to convert i,j,k,l to up(0) left(1),down(2),right(3) respectively
        JSR   IS_INPUT_VALID      
        ADD   R2, R2, #0                 ; R2 will be zero if the move was valid
        BRz   VALID_INPUT
        LEA   R0, INVALID_MOVE_STRING    ; if the input was invalid, output corresponding
        TRAP  x22                        ; message and go back to prompt
        BRnzp    HOMEBOUND
VALID_INPUT                 
        JSR   APPLY_MOVE                 ; apply the move (Input in R0)
        JSR   DISPLAY_JUNGLE
        JSR   SIMBA_STATUS      
        ADD   R2, R2, #0                 ; R2 will be zero if reached Home or -1 if Dead
        BRp  HOMEBOUND                     ; otherwise, loop back
EXIT   
        LEA   R0, GOODBYE_STRING
        TRAP  x22                        ; output a goodbye message
        TRAP  x25                        ; halt
JUNGLE_LOADED       .STRINGZ "\nJungle Loaded\n"
JUNGLE_INITIAL      .STRINGZ "\nJungle Initial\n"
ASCII_Q_COMPLEMENT  .FILL    x-71    ; two's complement of ASCII code for 'q'
ASCII_OFFSET_POS        .FILL    x30
LC_OUT_STRING    .STRINGZ "\n LIFE_COUNT is "
LC_LOC  .FILL LIFE_COUNT
PROMPT .STRINGZ "\nEnter Move up(i) \n left(j),down(k),right(l): "
INVALID_MOVE_STRING .STRINGZ "\nInvalid Input (ijkl)\n"
GOODBYE_STRING      .STRINGZ "\n!Goodbye!\n"
BLOCKS               .FILL x5500

;***********************************************************
; Global constants used in program
;***********************************************************
;***********************************************************
; This is the data structure for the Jungle grid
;***********************************************************
GRID .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
     .STRINGZ "| | | | | | | | |"
     .STRINGZ "+-+-+-+-+-+-+-+-+"
  
;***********************************************************
; this data stores the state of current position of Simba and his Home
;***********************************************************
CURRENT_ROW        .BLKW   #1       ; row position of Simba
CURRENT_COL        .BLKW   #1       ; col position of Simba 
HOME_ROW           .BLKW   #1       ; Home coordinates (row and col)
HOME_COL           .BLKW   #1
LIFE_COUNT         .FILL   #1       ; Initial Life Count is One
                                    ; Count increases when Simba
                                    ; meets a Friend; decreases
                                    ; when Simba meets a Hyena
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
; The code above is provided for you. 
; DO NOT MODIFY THE CODE ABOVE THIS LINE.
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
;***********************************************************
; constants and data block

ASCII_ZERO .FILL x0030      ; value for '0'

ASCII_I    .FILL x0049      ; value for 'I'
ASCII_H    .FILL x0048      ; value for 'H'
ASCII_STAR .FILL x002A      ; value for '*'
ASCII_SPACE  .FILL x20   ; '*'
ASCII_X      .FILL x58     ; 'X'
ASCII_F      .FILL x46     ; 'F'
ASCII_HASH   .FILL x23     ; '#'

ASCII_i_lc   .FILL x69     ; 'i'
ASCII_j_lc   .FILL x6A     ; 'j'
ASCII_k_lc   .FILL x6B     ; 'k'
ASCII_l_lc   .FILL x6C     ; 'l'

SEVEN        .FILL #7

; Status strings
SIMBA_DEAD_STRING .STRINGZ "\nSimba is Dead\n"
SIMBA_HOME_STRING .STRINGZ "\nSimba is Home\n"
CANT_MOVE_STRING  .STRINGZ "\nCannot Move\n"

COL_HEADER .STRINGZ "   0 1 2 3 4 5 6 7 \n" ; serves as the headers
GRID_PTR   .FILL GRID  
CONST_17     .FILL #17
SPACE        .FILL x20
NEWLINE      .FILL x0A

CUR_ROW_PTR   .FILL CURRENT_ROW
CUR_COL_PTR   .FILL CURRENT_COL
HOME_ROW_PTR  .FILL HOME_ROW
HOME_COL_PTR  .FILL HOME_COL
LIFE_PTR      .FILL LIFE_COUNT

ASCII_i_PTR .FILL ASCII_i_lc
ASCII_j_PTR .FILL ASCII_j_lc
ASCII_k_PTR .FILL ASCII_k_lc
ASCII_l_PTR .FILL ASCII_l_lc
;***********************************************************
; DISPLAY_JUNGLE
;   Displays the current state of the Jungle Grid 
;   This can be called initially to display the un-populated jungle
;   OR after populating it, to indicate where Simba is (*), any 
;   Friends (F) and Hyenas(#) are, and Simba's Home (H).
; Input: None
; Output: None
; Notes: The displayed grid must have the row and column numbers
;***********************************************************
DISPLAY_JUNGLE      
; the goal of this is to print the column header + the 17 grid strings and also with the row labels for the logic rows 0-7 (inclusive)

; First lets do callee saves to ensure no destruction of registers
ST   R0, DJ_SAVER0
ST   R1, DJ_SAVER1
ST   R2, DJ_SAVER2
ST   R3, DJ_SAVER3
ST   R4, DJ_SAVER4
ST   R5, DJ_SAVER5
ST   R6, DJ_SAVER6
ST   R7, DJ_SAVER7

LEA R0, COL_HEADER 
TRAP x22 ; prints out the column header
LD R1, GRID_PTR ; R1  = address of GRID
AND R2, R2, #0 ; r2 will hold the physical row index (whuch would be 0 - 16)
AND R3, R3, #0 ; r3 will hold the logical row index (which would be 0-7)

DJ_ROW_LOOP
; if the physical row is greater than or equal to 17, we want to end

LD R5, CONST_17 ; R5 = 17
NOT R5, R5
ADD R5, R5, #1 ; R5 now holds -17
ADD R4, R2, R5 ; R4 = R2 - R5  
BRzp DJ_DONE_ROWS ; if that result is non negative, branch to DONE_ROWS

; check the equality of R2 and 1s

ADD R4, R2, #0
AND R4, R4, #1
BRp DJ_IS_ODD_ROW ;if low bit is equal to 1, its odd row
; if its even, fall through

DJ_IS_EVEN_ROW
; we want to print 2 spaces then
LD R0, SPACE
TRAP x21
TRAP x21
BRnzp DJ_PREFIX_DONE

DJ_IS_ODD_ROW

; we will print the logical row number + space

LD R5, ASCII_ZERO
ADD R0, R5, R3
TRAP x21
LD R0, SPACE
TRAP x21
; now we want to increment the row once per odd physical row
ADD R3, R3, #1

DJ_PREFIX_DONE

; print the actual grid string at R1 place

ADD R0, R1, #0
TRAP x22

; now do a new line

LD R0, NEWLINE
TRAP x21

; now advance R1 to next .STRINGZ in the grid

DJ_SCAN_NEXT

LDR R4, R1, #0 ; loads into R4 R1 0th offset value
BRz  DJ_AFTER_SCAN ; if its 0, go to after scan, if not, incrememtn and come back here
ADD  R1, R1, #1
BRnzp DJ_SCAN_NEXT ; unconditional loop back 

DJ_AFTER_SCAN
ADD R1, R1, #1 ; skip over the null terminated

;look at next physical row:

ADD R2, R2, #1
BR DJ_ROW_LOOP


DJ_DONE_ROWS

; now we need to restore the registers

LD   R0, DJ_SAVER0
LD   R1, DJ_SAVER1
LD   R2, DJ_SAVER2
LD   R3, DJ_SAVER3
LD   R4, DJ_SAVER4
LD   R5, DJ_SAVER5
LD   R6, DJ_SAVER6
LD   R7, DJ_SAVER7
RET

DJ_SAVER7 .BLKW #1
DJ_SAVER0 .BLKW #1
DJ_SAVER1 .BLKW #1
DJ_SAVER2 .BLKW #1
DJ_SAVER3 .BLKW #1
DJ_SAVER4 .BLKW #1
DJ_SAVER5 .BLKW #1
DJ_SAVER6 .BLKW #1

;***********************************************************
; LOAD_JUNGLE
; Input:  R0  has the address of the head of a linked list of
;         gridblock records. Each record has four fields:
;       0. Address of the next gridblock in the list
;       1. row # (0-7)
;       2. col # (0-7)
;       3. Symbol (can be I->Initial,H->Home, F->Friend or #->Hyena)
;    The list is guaranteed to: 
;               * have only one Inital and one Home gridblock
;               * have zero or more gridboxes with Hyenas/Friends
;               * be terminated by a gridblock whose next address 
;                 field is a zero
; Output: None
;   This function loads the JUNGLE from a linked list by inserting 
;   the appropriate characters in boxes (I(*),#,F,H)
;   You must also change the contents of these
;   locations: 
;        1.  (CURRENT_ROW, CURRENT_COL) to hold the (row, col) 
;            numbers of Simba's Initial gridblock
;        2.  (HOME_ROW, HOME_COL) to hold the (row, col) 
;            numbers of the Home gridblock
;       
;***********************************************************
LOAD_JUNGLE 

; First lets do callee saves to ensure no destruction of registers
ST R0, LJ_SAVER0
ST R1, LJ_SAVER1
ST R2, LJ_SAVER2
ST R3, LJ_SAVER3
ST R4, LJ_SAVER4
ST R5, LJ_SAVER5
ST R6, LJ_SAVER6
ST R7, LJ_SAVER7

LJ_LOOP ; R0 will serve as pointer to current record, and we want to save the record base into R4
ADD R4, R0, #0
LDR R1, R0, #1 ;load row
LDR R2, R0, #2 ; load column
LDR R3, R0, #3 ; load the symbol that represents the thing there

JSR GRID_ADDRESS ; next we want to call GRID_ADDRESS ot get the (row,column) into R0

ADD R5, R3, #0 ; default will be set to original symbol

; now lets check if the symbol = I 'initial'

LD R6, ASCII_I ; R6 gets ascii of I
NOT R6, R6 
ADD R6, R6, #1 ; R6 = -R6 (-I in a way)
ADD R6, R5, R6 ; R3 = R3 - I
BRz LJ_IS_INITIAL ; if that result equals zero, that means the tihng there was an I, if not, fall through

LD R6, ASCII_H ; R6 gets ascii of H
NOT R6, R6 
ADD R6, R6, #1 ; R6 = -R6 (-H in a way)
ADD R6, R5, R6 ; R3 = R3 - H
BRz LJ_IS_HOME ; if that result equals zero, that means the tihng there was an H, if not, fall through

; otherwise, its an F or #, so just leave R5 as original

BRnzp LJ_STORE_CHAR ; unconditioanl branch to LJ_STORE_CHAR if we fell through everything else

LJ_IS_INITIAL
; store * in the grid
LD R5, ASCII_STAR

; need to now update the current_row and current_column
LD  R6, CUR_ROW_PTR
STR R1, R6, #0
LD  R6, CUR_COL_PTR
STR R2, R6, #0

BRnzp LJ_STORE_CHAR 

LJ_IS_HOME
; store H (can also reload to be safe)
LD R5, ASCII_H
; need to update home_row and home_column

LD  R6, HOME_ROW_PTR
STR R1, R6, #0
LD  R6, HOME_COL_PTR
STR R2, R6, #0

BRnzp LJ_STORE_CHAR 

LJ_STORE_CHAR

; R0 = GRID ADDRESS and R5 is the char to store
STR R5, R0, #0

; want to get the next pointer from record base[0]

ADD  R0, R4, #0 ; restore the record base
LDR  R0, R0, #0 ; loads the next pointer
BRz  LJ_DONE ; if 0, we hit the end of the list
BRnzp LJ_LOOP ; uncondiitoanl loop back to LJ_LOOP

LJ_DONE

; we need to restore all the registers before we leave the subroutine

LD R0, LJ_SAVER0
LD R1, LJ_SAVER1
LD R2, LJ_SAVER2
LD R3, LJ_SAVER3
LD R4, LJ_SAVER4
LD R5, LJ_SAVER5
LD R6, LJ_SAVER6
LD R7, LJ_SAVER7
RET

; sets aside blocks for these saves 

LJ_SAVER7 .BLKW #1
LJ_SAVER0 .BLKW #1
LJ_SAVER1 .BLKW #1
LJ_SAVER2 .BLKW #1
LJ_SAVER3 .BLKW #1
LJ_SAVER4 .BLKW #1
LJ_SAVER5 .BLKW #1
LJ_SAVER6 .BLKW #1

;***********************************************************
; GRID_ADDRESS
; Input:  R1 has the row number (0-7)
;         R2 has the column number (0-7)
; Output: R0 has the corresponding address of the space in the GRID
; Notes: This is a key routine.  It translates the (row, col) logical 
;        GRID coordinates of a gridblock to the physical address in 
;        the GRID memory.
;***********************************************************
GRID_ADDRESS     
 
; R1 will be set as the logical row
; R2 will be set as the logical column
; R0 will be for the address of that grid cell

; First lets do callee saves to ensure no destruction of registers

ST R7, GA_SAVER7
ST R1, GA_SAVER1
ST R2, GA_SAVER2
ST R3, GA_SAVER3
ST R4, GA_SAVER4

; to calculate physical row, we do row *2 + 1 into R3

ADD R3, R1, R1 ; R3 = R1*2
ADD R3, R3, #1 ; R3 + R3+1

; offset of row = physical row * 18 
; R4 will be set as physical row * 16

ADD R4, R3, R3 ; R4 = *2
ADD R4, R4, R4 ; R4 = *4
ADD R4, R4, R4 ; R4 = *8
ADD R4, R4, R4 ; R4 = *16

;R1 = physical row (R3) *2
ADD R1, R3, R3

ADD R4, R4, R1 ; 16+2 = 18*pr

; base address of GRID
LD R0, GRID_PTR ; R0 is address of GRID base
ADD R0, R0, R4 ; R0 = R0 + R4 , adding row offset

; column offset is just 2 * column + 1, which we will do in R2

ADD R2, R2, R2 ;  R2 = 2*R2
ADD R2, R2, #1 ; R2 = 2*col + 1

ADD R0, R0, R2 ; the final address

; now lets restore the registers so then this subroutine doesnt leave a mess

LD   R1, GA_SAVER1
LD   R2, GA_SAVER2
LD   R3, GA_SAVER3
LD   R4, GA_SAVER4
LD   R7, GA_SAVER7
RET

; sets aside blocks for these saves 
GA_SAVER7 .BLKW #1
GA_SAVER1 .BLKW #1
GA_SAVER2 .BLKW #1
GA_SAVER3 .BLKW #1
GA_SAVER4 .BLKW #1

;***********************************************************
; IS_INPUT_VALID
; Input: R0 has the move (character i,j,k,l)
; Output:  R2  zero if valid; -1 if invalid
; Notes: Validates move to make sure it is one of i,j,k,l
;        Only checks if a valid character is entered
;***********************************************************
; R0 is the char, R2 = 0 if char is i/j/k/l , any of the ones that are valid
; othweise, R2 will be -1, which we define as invalid
IS_INPUT_VALID

BRnzp ISIV_START
ISIV_SAVE_R1 .BLKW #1
ISIV_SAVE_R3 .BLKW #1
ISIV_START
ST R1, ISIV_SAVE_R1
ST R3, ISIV_SAVE_R3
        
; first we want to assume invalid, that's going to be the base case
AND R2, R2, #0
ADD R2, R2, #-1

LD  R1, ASCII_i_PTR
LDR R1, R1, #0
NOT R1, R1
ADD R1, R1, #1 ; gets -I
ADD R3, R0, R1 ; R3 = R0 - R1 ('I')
BRz ISIV_VALID

LD  R1, ASCII_j_PTR
LDR R1, R1, #0
NOT R1, R1
ADD R1, R1, #1 ; gets -J
ADD R3, R0, R1 ; R3 = R0 - R1 ('J')
BRz ISIV_VALID

LD  R1, ASCII_k_PTR
LDR R1, R1, #0
NOT R1, R1
ADD R1, R1, #1 ; gets -K
ADD R3, R0, R1 ; R3 = R0 - R1 ('K')
BRz ISIV_VALID

LD  R1, ASCII_l_PTR
LDR R1, R1, #0
NOT R1, R1
ADD R1, R1, #1 ; gets -L
ADD R3, R0, R1 ; R3 = R0 - R1 ('L')
BRz ISIV_VALID

BRnzp ISIV_DONE ; if none of them matched, keep R2 as -1, indicating invalid

ISIV_VALID
AND R2, R2, #0 ; R2 is set to 0, meaning valid

ISIV_DONE
LD R1, ISIV_SAVE_R1
LD R3, ISIV_SAVE_R3
JMP R7

;***********************************************************
; CAN_MOVE
; This subroutine checks if a move can be made and returns 
; the new position where Simba would go to if the move is made. 
; To be able to make a move is to ensure that movement 
; does not take Simba off the grid; this can happen in any direction.
; In coding this routine you will need to translate a move to 
; coordinates (row and column). 
; Your APPLY_MOVE subroutine calls this subroutine to check 
; whether a move can be made before applying it to the GRID.
; Inputs: R0 - a move represented by 'i', 'j', 'k', or 'l'
; Outputs: R1, R2 - the new row and new col, respectively 
;              if the move is possible; 
;          if the move cannot be made (outside the GRID), 
;              R1 = -1 and R2 is untouched.
; Note: This subroutine does not check if the input (R0) is valid. 
;       You will implement this functionality in IS_INPUT_VALID. 
;       Also, this routine does not make any updates to the GRID 
;       or Simba's position, as that is the job of the APPLY_MOVE function.
;***********************************************************

CAN_MOVE      

BRnzp CM_START
CM_SAVE_R3   .BLKW #1
CM_SAVE_R2   .BLKW #1
CM_SAVE_R4   .BLKW #1
CM_SAVE_R5   .BLKW #1
CM_SAVE_R6   .BLKW #1
CM_SEVEN_VAL .FILL #7

CM_START

ST R3, CM_SAVE_R3
ST R2, CM_SAVE_R2
ST R4, CM_SAVE_R4
ST R5, CM_SAVE_R5
ST R6, CM_SAVE_R6

; want to first load the current row and column

; loads current row into R1
; loads current column into R2

LD  R1, CUR_ROW_PTR
LDR R1, R1, #0

LD  R2, CUR_COL_PTR
LDR R2, R2, #0

ADD R6, R2, #0   ; R6 = oldCol (so we can restore if offgrid)

; i means row -1
; j means col -1
; k means row +1
; l means col +1

; checks for 'i' (which means up)

LD  R3, ASCII_i_PTR
LDR R3, R3, #0
NOT R3, R3
ADD R3, R3, #1 ; R3 now holds -i
ADD R4, R0, R3 ; R4 = R0 - 'i'
BRz CMOVE_UP

LD  R3, ASCII_j_PTR
LDR R3, R3, #0
NOT R3, R3
ADD R3, R3, #1 ; R3 now holds -j
ADD R4, R0, R3 ; R4 = R0 - 'j
BRz CMOVE_LEFT

LD  R3, ASCII_k_PTR
LDR R3, R3, #0
NOT R3, R3
ADD R3, R3, #1 ; R3 now holds -k
ADD R4, R0, R3 ; R4 = R0 - 'k'
BRz CMOVE_DOWN

LD  R3, ASCII_l_PTR
LDR R3, R3, #0
NOT R3, R3
ADD R3, R3, #1 ; R3 now holds -l
ADD R4, R0, R3 ; R4 = R0 - 'l'
BRz CMOVE_RIGHT

BRnzp CMOVE_CHECK_BOUNDS

CMOVE_UP
ADD R1, R1, #-1 ; row = row - 1 (decrements row)
BRnzp CMOVE_CHECK_BOUNDS

CMOVE_DOWN
ADD R1, R1, #1 ; row = row + 1 ; increments row
BRnzp CMOVE_CHECK_BOUNDS

CMOVE_LEFT
ADD R2, R2, #-1 ; col = col - 1 (decrements col)
BRnzp CMOVE_CHECK_BOUNDS

CMOVE_RIGHT
ADD R2, R2, #1 ; col = col +1 1 (increments col)
; we can just fal through at this point

CMOVE_CHECK_BOUNDS ; 0<= row <= 7, 0<= col <= 7

; want to check first if row = 0

ADD R3, R1, #0
BRn CMOVE_OFFGRID

; now check if the row is greater than 7
LD R4, CM_SEVEN_VAL ; .FILL R4 WITH 7
NOT R4, R4
ADD R4, R4, #1
ADD R5, R1, R4 ; R5 = row - 7
BRp CMOVE_OFFGRID

; want to check first if col = 0

ADD R3, R2, #0
BRn CMOVE_OFFGRID

; now check if the col is greater than 7
LD R4, CM_SEVEN_VAL ; .FILL R4 WITH 7
NOT R4, R4
ADD R4, R4, #1
ADD R5, R2, R4 ; R5 = row - 7
BRp CMOVE_OFFGRID

; if we reach here, that means the row and the col were valid

BRnzp CM_RETURN

CMOVE_OFFGRID
AND R1, R1, #0
ADD R1, R1, #-1     ; flag = offgrid
LD R2, CM_SAVE_R2
BRnzp CM_RETURN

CM_RETURN
LD R3, CM_SAVE_R3
LD R4, CM_SAVE_R4
LD R5, CM_SAVE_R5
LD R6, CM_SAVE_R6
JMP R7

;***********************************************************
; APPLY_MOVE
; This subroutine makes the move if it can be completed. 
; It checks to see if the movement is possible by calling 
; CAN_MOVE which returns the coordinates of where the move 
; takes Simba (or -1 if movement is not possible as detailed above). 
; If the move is possible then this routine moves Simba
; symbol (*) to the new coordinates and clears any walls (|'s and -'s) 
; as necessary for the movement to take place. 
; In addition,
;   If the movement is off the grid - Output "Cannot Move" to Console
;   If the move is to a Friend's location then you increment the
;     LIFE_COUNT variable; 
;   If the move is to a Hyena's location then you decrement the
;     LIFE_COUNT variable; IF this decrement causes LIFE_COUNT
;     to become Zero then Simba's Symbol changes to X (dead)
; Input:  
;         R0 has move (i or j or k or l)
; Output: None; However yous must update the GRID and 
;               change CURRENT_ROW and CURRENT_COL 
;               if move can be successfully applied.
;               appropriate messages are output to the console 
; Notes:  Calls CAN_MOVE and GRID_ADDRESS
;***********************************************************

APPLY_MOVE  

BRnzp AM_START          ; skip local data

; -------- local constants/pointers for APPLY_MOVE --------
AM_ASCII_STAR     .FILL x2A
AM_ASCII_SPACE    .FILL x20
AM_ASCII_X        .FILL x58
AM_ASCII_F        .FILL x46
AM_ASCII_HASH     .FILL x23

AM_ASCII_i        .FILL x69
AM_ASCII_j        .FILL x6A
AM_ASCII_k        .FILL x6B
AM_ASCII_l        .FILL x6C

AM_CONST_18       .FILL #18
AM_CONST_18_NEG   .FILL #-18

AM_CUR_ROW_PTR    .FILL CURRENT_ROW
AM_CUR_COL_PTR    .FILL CURRENT_COL
AM_LIFE_PTR       .FILL LIFE_COUNT
AM_CANTMOVE_PTR   .FILL CANT_MOVE_STRING
; ---------------------------------------------------------

AM_START

; first we want to store all of our registers so they're not destroyed for the rest of the program

ST R0, AM_SAVER0
ST R1, AM_SAVER1
ST R2, AM_SAVER2
ST R3, AM_SAVER3
ST R4, AM_SAVER4
ST R5, AM_SAVER5
ST R6, AM_SAVER6
ST R7, AM_SAVER7

; first we want to save the move char to R3 

ADD R3, R0, #0

; now we want to call can move to get the new coordinates

JSR CAN_MOVE ; R1 holds the new row or -1, R2 =  new column

; if R1 is negaitve 1, we cant move so  we will call the AM_CANT_MOVE

ADD R4, R1, #0
BRn AM_CANT_MOVE

ADD R4, R1, #0   ; save newRow
ADD R5, R2, #0   ; save newCol

; now load the old coords before we overwrite

; current col goes into R4
; Current col goes into R5

LD  R1, AM_CUR_ROW_PTR
LDR R1, R1, #0   ; oldRow

LD  R2, AM_CUR_COL_PTR
LDR R2, R2, #0   ; oldCol

JSR GRID_ADDRESS ; goes to grid address
ADD R6, R0, #0 ; R6 now holds the old address

; now we want to get address of new cell into R7

ADD R1, R4, #0   ; newRow
ADD R2, R5, #0   ; newCol
JSR GRID_ADDRESS
ADD R7, R0, #0

LDR R0, R7, #0 ; now we want to check what char is at the new cell

LD R2, AM_ASCII_STAR ; R2 holds the simba character

; if the new cell is F , life_count = life_count + 1

LD R1, AM_ASCII_F
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRnp AM_CHECK_HYENA

; to do LIFE_COUNT++

LD R1, AM_LIFE_PTR
LDR R0, R1, #0
ADD R0, R0, #1
STR R0, R1, #0
BR AM_UPDATE_GRID

AM_CHECK_HYENA ; want to check if hyena, if the cell has a #, its life_count--

LD R1, AM_ASCII_HASH
NOT R1, R1
ADD R1, R1, #1
ADD R1, R0, R1
BRnp AM_UPDATE_GRID

; LIFE_COUNT--

LD  R1, AM_LIFE_PTR
LDR R0, R1, #0
ADD R0, R0, #-1
STR R0, R1, #0

; if the life count is zero, simba is dead so store x

ADD R0, R0, #0
BRp AM_UPDATE_GRID
LD R2, AM_ASCII_X

AM_UPDATE_GRID
; we want to clear the old cell to space
LD R0, AM_ASCII_SPACE
STR R0, R6, #0

; store simba in a new cell (either * or X)

STR R2, R7, #0

; now clear the wall between old and new

LD  R1, AM_ASCII_i
NOT R1, R1
ADD R1, R1, #1
ADD R1, R3, R1
BRz AM_CLEAR_UP

LD  R1, AM_ASCII_k
NOT R1, R1
ADD R1, R1, #1
ADD R1, R3, R1
BRz AM_CLEAR_DOWN

LD  R1, AM_ASCII_j
NOT R1, R1
ADD R1, R1, #1
ADD R1, R3, R1
BRz AM_CLEAR_LEFT

; otherwise it would be right

AM_CLEAR_RIGHT
ADD R0, R6, #1 ; right of old cell
BR AM_DO_CLEAR

AM_CLEAR_LEFT
ADD R0, R6, #-1 ; left of old cell
BR AM_DO_CLEAR

AM_CLEAR_UP

LD R1, AM_CONST_18_NEG ; -18
ADD R0, R6, R1 ; wall above the old cell
BR AM_DO_CLEAR

AM_CLEAR_DOWN
LD R1, AM_CONST_18 ; +18
ADD R0, R6, R1 ; will take to wall below old cell

AM_DO_CLEAR
LD R1, AM_ASCII_SPACE
STR R1, R0, #0

; now we want to update current row and column

ADD R0, R3, #0
JSR CAN_MOVE ; R1 = new row, r2 = new col again

LD R0, AM_CUR_ROW_PTR
STR R1, R0, #0

LD R0, AM_CUR_COL_PTR
STR R2, R0, #0

BR AM_DONE

AM_CANT_MOVE
LD  R0, AM_CANTMOVE_PTR
TRAP x22

AM_DONE

; we want to restore our registers.

LD R0, AM_SAVER0
LD R1, AM_SAVER1
LD R2, AM_SAVER2
LD R3, AM_SAVER3
LD R4, AM_SAVER4
LD R5, AM_SAVER5
LD R6, AM_SAVER6
LD R7, AM_SAVER7
RET

; and now we want to create blkw's for each of these temp registers and local constants

AM_SAVER7 .BLKW #1
AM_SAVER0 .BLKW #1
AM_SAVER1 .BLKW #1
AM_SAVER2 .BLKW #1
AM_SAVER3 .BLKW #1
AM_SAVER4 .BLKW #1
AM_SAVER5 .BLKW #1
AM_SAVER6 .BLKW #1

;***********************************************************
; SIMBA_STATUS
; Checks to see if the Simba has reached Home; Dead or still
; Alive
; Input:  None
; Output: R2 is ZERO if Simba is Home; Also Output "Simba is Home"
;         R2 is +1 if Simba is Alive but not home yet
;         R2 is -1 if Simba is Dead (i.e., LIFE_COUNT =0); Also Output"Simba is Dead"
; 
;***********************************************************

SIMBA_STATUS 

BRnzp SS_START        ; skip local data
SS_SAVE_R0 .BLKW #1
SS_SAVE_R1 .BLKW #1
SS_SAVE_R3 .BLKW #1
SS_SAVE_R4 .BLKW #1
SS_SAVE_R5 .BLKW #1
SS_SAVE_R6 .BLKW #1

; -------- local pointers for SIMBA_STATUS --------
SS_LIFE_PTR      .FILL LIFE_COUNT
SS_CUR_ROW_PTR   .FILL CURRENT_ROW
SS_CUR_COL_PTR   .FILL CURRENT_COL
SS_HOME_ROW_PTR  .FILL HOME_ROW
SS_HOME_COL_PTR  .FILL HOME_COL
SS_DEAD_PTR      .FILL SIMBA_DEAD_STRING
SS_HOME_PTR      .FILL SIMBA_HOME_STRING
; -------------------------------------------------
SS_START
ST R0, SS_SAVE_R0
ST R1, SS_SAVE_R1
ST R3, SS_SAVE_R3
ST R4, SS_SAVE_R4
ST R5, SS_SAVE_R5
ST R6, SS_SAVE_R6

; first we want to check the life count
LD  R0, SS_LIFE_PTR
LDR R1, R0, #0 ; R1 = LIFE_COUNT
ADD R3, R1, #0 ; R3 gets R1
BRp SS_NOT_DEAD ; if its a positive value, simba isnt dead
BRz SS_DEAD ; if its zer0, simba is dead

SS_DEAD
AND R2, R2, #0 ; clears R2
ADD R2, R2, #-1 ; R2 = -1
LD  R0, SS_DEAD_PTR ; will print out that simba has been eliminated
TRAP x22
BRnzp SS_RETURN

SS_NOT_DEAD
; we want to check if hes at home , if the current row and column = the home row and column

LD  R3, SS_CUR_ROW_PTR
LDR R3, R3, #0

LD  R4, SS_CUR_COL_PTR
LDR R4, R4, #0

LD  R5, SS_HOME_ROW_PTR
LDR R5, R5, #0

LD  R6, SS_HOME_COL_PTR
LDR R6, R6, #0

; now we must compare the current and home

NOT R5, R5
ADD R5, R5, #1
ADD R1, R3, R5 ; R1 = CURRENT - HOME row
BRnp SS_NOT_HOME ;  if its not equal to zero, hes not home

; now compare cols

LD  R6, SS_HOME_COL_PTR
LDR R6, R6, #0
NOT R6, R6
ADD R6, R6, #1
ADD R1, R4, R6 ; CURRENT_COL - HOME COL
BRnp SS_NOT_HOME ; if that value is not equal to zero, not home

; if we fall through all the way here, that means hes at home

AND R2, R2, #0 ; CLEAR R2 TO 0
LD  R0, SS_HOME_PTR ; will print out hes home
TRAP x22
BRnzp SS_RETURN

SS_NOT_HOME

AND R2, R2, #0 ; R2 = 0
ADD R2, R2, #1 ; R2 = +1
BRnzp SS_RETURN ; done

SS_RETURN
LD R0, SS_SAVE_R0
LD R1, SS_SAVE_R1
LD R3, SS_SAVE_R3
LD R4, SS_SAVE_R4
LD R5, SS_SAVE_R5
LD R6, SS_SAVE_R6
JMP R7



    .END

; This section has the linked list for the
; Jungle's layout: #(0,1)->H(4,7)->I(2,1)->#(1,1)->#(6,3)->F(3,5)->F(4,4)->#(5,6)
	.ORIG	x5500
	.FILL	Head   ; Holds the address of the first record in the linked-list (Head)
blk2
	.FILL   blk4
	.FILL   #1
    .FILL   #1
	.FILL   x23

Head
	.FILL	blk1
    .FILL   #0
	.FILL   #1
	.FILL   x23

blk1
	.FILL   blk3
	.FILL   #4
	.FILL   #7
	.FILL   x48

blk3
	.FILL   blk2
	.FILL   #2
	.FILL   #1
	.FILL   x49

blk4
	.FILL   blk5
	.FILL   #6
	.FILL   #3
	.FILL   x23

blk7
	.FILL   #0
	.FILL   #5
	.FILL   #6
	.FILL   x23
blk6
	.FILL   blk7
	.FILL   #4
	.FILL   #4
	.FILL   x46
blk5
	.FILL   blk6
	.FILL   #3
	.FILL   #5
	.FILL   x46
	.END