;;***********************************************************
; Programming Assignment 3
; Student Name: Maaz Ahmed
; UT Eid: ma69299
; Simba in the Jungle
; This is the starter code. You are given the main program
; and some declarations. The subroutines you are responsible for
; are given as empty stubs at the bottom. Follow the contract. 
; You are free to rearrange your subroutines if the need were to 
; arise.
; Note: Remember "Callee-Saves" (Cleans its own mess)

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
    TRAP  x25                        ; halt
JUNGLE_LOADED       .STRINGZ "\nJungle Loaded\n"
JUNGLE_INITIAL      .STRINGZ "\nJungle Initial\n"
BLOCKS          .FILL x5500

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
SPACE      .FILL x0020      ; value for space: ' '
NEWLINE    .FILL x000A      ; new line ascii: '\n'
CONST_17   .FILL #17        ; 17 is hardcoded for this number of physical GRID rows

ASCII_I    .FILL x0049      ; value for 'I'
ASCII_H    .FILL x0048      ; value for 'H'
ASCII_STAR .FILL x002A      ; value for '*'

COL_HEADER .STRINGZ "   0 1 2 3 4 5 6 7 \n" ; serves as the headers

GRID_PTR   .FILL GRID  
;***********************************************************
; DISPLAY_JUNGLE
;   Displays the current state of the Jungle Grid 
;   This can be called initially to display the un-populated jungle
;   OR after populating it, to indicate where Simba is (*), any 
;   Hyena's(#) are, and Simba's Home (H).
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
;       3. Symbol (can be I->Initial,H->Home or #->Hyena)
;    The list is guaranteed to: 
;               * have only one Inital and one Home gridblock
;               * have zero or more gridboxes with Hyenas
;               * be terminated by a gridblock whose next address 
;                 field is a zero
; Output: None
;   This function loads the JUNGLE from a linked list by inserting 
;   the appropriate characters in boxes (I(*),#,H)
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
ADD R6, R3, R6 ; R3 = R3 - I
BRz LJ_IS_INITIAL ; if that result equals zero, that means the tihng there was an I, if not, fall through

LD R6, ASCII_H ; R6 gets ascii of H
NOT R6, R6 
ADD R6, R6, #1 ; R6 = -R6 (-H in a way)
ADD R6, R3, R6 ; R3 = R3 - H
BRz LJ_IS_HOME ; if that result equals zero, that means the tihng there was an H, if not, fall through

; otherwise, its an F or #, so just leave R5 as original

BRnzp LJ_STORE_CHAR ; unconditioanl branch to LJ_STORE_CHAR if we fell through everything else

LJ_IS_INITIAL
; store * in the grid
LD R5, ASCII_STAR

; need to now update the current_row and current_column
LEA R6, CURRENT_ROW
STR R1, R6, #0
LEA R6, CURRENT_COL
STR R2, R6, #0
BRnzp LJ_STORE_CHAR 

LJ_IS_HOME
; store H (can also reload to be safe)
LD R5, ASCII_H
; need to update home_row and home_column
LEA R6, HOME_ROW
STR R1, R6, #0
LEA R6, HOME_COL
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