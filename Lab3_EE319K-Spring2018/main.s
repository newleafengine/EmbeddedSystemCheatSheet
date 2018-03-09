;****************** main.s ***************
; Program written by: ***Omar Martinez***
; Date Created: 2/4/2017
; Last Modified: 1/15/2018
; Brief description of the program
;   The LED toggles at 8 Hz and a varying duty-cycle
; Hardware connections (External: One button and one LED)
;  PE1 is Button input  (1 means pressed, 0 means not pressed)
;  PE0 is LED output (1 activates external LED on protoboard)
;  PF4 is builtin button SW1 on Launchpad (Internal) 
;        Negative Logic (0 means pressed, 1 means not pressed)
; Overall functionality of this system is to operate like this
;   1) Make PE0 an output and make PE1 and PF4 inputs.
;   2) The system starts with the the LED toggling at 8Hz,
;      which is 8 times per second with a duty-cycle of 20%.
;      Therefore, the LED is ON for (0.2*1/8)th of a second
;      and OFF for (0.8*1/8)th of a second.
;   3) When the button on (PE1) is pressed-and-released increase
;      the duty cycle by 20% (modulo 100%). Therefore for each
;      press-and-release the duty cycle changes from 20% to 40% to 60%
;      to 80% to 100%(ON) to 0%(Off) to 20% to 40% so on
;   4) Implement a "breathing LED" when SW1 (PF4) on the Launchpad is pressed:
;      a) Be creative and play around with what "breathing" means.
;         An example of "breathing" is most computers power LED in sleep mode
;         (e.g., https://www.youtube.com/watch?v=ZT6siXyIjvQ).
;      b) When (PF4) is released while in breathing mode, resume blinking at 8Hz.
;         The duty cycle can either match the most recent duty-
;         cycle or reset to 20%.
;      TIP: debugging the breathing LED algorithm and feel on the simulator is impossible.
; PortE device registers
GPIO_PORTE_DATA_R  EQU 0x400243FC
GPIO_PORTE_DIR_R   EQU 0x40024400
GPIO_PORTE_AFSEL_R EQU 0x40024420
GPIO_PORTE_DEN_R   EQU 0x4002451C
; PortF device registers
GPIO_PORTF_DATA_R  EQU 0x400253FC
GPIO_PORTF_DIR_R   EQU 0x40025400
GPIO_PORTF_AFSEL_R EQU 0x40025420
GPIO_PORTF_PUR_R   EQU 0x40025510
GPIO_PORTF_DEN_R   EQU 0x4002551C
GPIO_PORTF_LOCK_R  EQU 0x40025520
GPIO_PORTF_CR_R    EQU 0x40025524
GPIO_LOCK_KEY      EQU 0x4C4F434B  ; Unlocks the GPIO_CR register
SYSCTL_RCGCGPIO_R  EQU 0x400FE608
SYSCTL_RCGC2_GPIOE EQU 0x00000012   ; port E Clock Gating Control
DELAYTIME		   EQU 2500000
LED_OFF			   EQU 0x00	
LED_ON			   EQU 0x01
PERCENT			   EQU 100

	 IMPORT  TExaS_Init
     THUMB
     AREA    DATA, ALIGN=2
;global variables go here
     AREA    |.text|, CODE, READONLY, ALIGN=2
     THUMB
     EXPORT  Start
	
; R0 = Percentage of delay time to delay by
; R1 = DELAY TIME = 2.5 mil cycles
; Delay will do R1 * R0 / R13 to delay by a percentage
delay
	LDR R1, =DELAYTIME
	LDR R2, =PERCENT
	MUL R0, R1
	UDIV R0, R2
	ADD R0, #1		; make sure to add 1 so that we don't subtract by 0 / negative vals
delayloop
    subs    r0, #1
    bne     delayloop
    bx      lr
	
	; REMINDERS
	;R0~R4 = Data for functions, never assume any data from those registers
	;R5 = PE0 Button Status
	;R6 = SW1 status 1 - pressed 0 - off
	;R7 = DirectionBool
	;R8 = PE0 Button Address
	;R9 = PE0 bool to check pressed / released
	;R10 = SW1 Address
	;R11 = Duty On Time
	;R12 = Duty Off Time
	
Start
 ; TExaS_Init sets bus clock at 80 MHz
    BL  TExaS_Init ; voltmeter, scope on PD3
 ; Initialization goes here
	; here we init the port F
    LDR R1, =SYSCTL_RCGCGPIO_R      ; 1) activate clock for Port F
    LDR R0, [R1]
    ORR R0, R0, #0x20               ; set bit 5 to turn on clock
    STR R0, [R1]
    NOP
    NOP
	; here we init the port E
    LDR R1, =SYSCTL_RCGCGPIO_R      ; 1) activate clock for Port E
    LDR R0, [R1]
    ORR R0, R0, #SYSCTL_RCGC2_GPIOE  ; set bit 0x12 to turn on clock for port e
    STR R0, [R1]
    NOP
    NOP
; allow time for clock to finish
    LDR R1, =GPIO_PORTF_LOCK_R      ; 2) unlock the lock register
    LDR R0, =0x4C4F434B             ; unlock GPIO Port F Commit Register
    STR R0, [R1]
    LDR R1, =GPIO_PORTF_CR_R        ; enable commit for Port F
    MOV R0, #0xFF                   ; 1 means allow access
    STR R0, [R1]
    LDR R1, =GPIO_PORTF_DIR_R       ; 5) set direction register
    MOV R0,#0x0E                    ; PF0 and PF7-4 input, PF3-1 output
    STR R0, [R1]
    LDR R1, =GPIO_PORTF_AFSEL_R     ; 6) regular port function
    MOV R0, #0                      ; 0 means disable alternate function
    STR R0, [R1]
    LDR R1, =GPIO_PORTF_PUR_R       ; pull-up resistors for PF4,PF0
    MOV R0, #0x11                   ; enable weak pull-up on PF0 and PF4
    STR R0, [R1]
    LDR R1, =GPIO_PORTF_DEN_R       ; 7) enable Port F digital port
    MOV R0, #0xFF                   ; 1 means enable digital I/O
    STR R0, [R1]
	
	; do the same for port E for DEN,AFSEL, DIR
	LDR R1, =GPIO_PORTE_DIR_R       ; 5) set direction register
    MOV R0,#0x01                    ; PF0 and PF7-4 input, PF3-1 output
    STR R0, [R1]
	
	LDR R1, =GPIO_PORTE_AFSEL_R     ; 6) regular port function
    MOV R0, #0                      ; 0 means disable alternate function
    STR R0, [R1]
	
	LDR R1, =GPIO_PORTE_DEN_R       ; 7) enable Port F digital port
    MOV R0, #0xFF                   ; 1 means enable digital I/O
    STR R0, [R1]
	; initialize variables before we start our loop
	LDR R8, =GPIO_PORTE_DATA_R	; points to Port E Data
	MOV R11, #20						; LED ON TIME
	MOV R12, #80						; LED OFF TIME
	MOV R6, #0							; SW is not pressed
    CPSIE  I    ; TExaS voltmeter, scope runs on interrupts
loop 
; main engine goes here
; check if SW status
	LDR R10, =GPIO_PORTF_DATA_R		; points to Port F Data
	LDR R6, [R10]					; put the data from r10 to r6
	LSR R6, R6, #4					; left shift by 4 to get the second button value 
	EOR R6, R6, #1					; flip from 0 <-> 1
	CMP R6, #1						; if SW1 is pressed, then start breathing
	BLEQ breath
; check PE0 status
	LDR R5, [R8]
	CMP R5, #2
	MOVEQ R9, #1
	BLNE checkButtonStatus
	CMP R11, #100
	BLHI dutyReset
; Handle default LED behaviour
	BL toggleLED
    B loop

increaseDutyCycle	; this increases the duty cycle by R0
	ADD R11, R11, R0
	SUB R12, R12, R0
	CMP R11, #100
	MOVHI R7, #1
	BX LR
	
decreaseDutyCycle	; this decreases the duty cycle by R0
	SUB R11, R11, R0
	ADD R12, R12, R0
	CMP R12, #100
	MOVHI R7, #0
	BX LR

dutyReset
	MOV R11, #0
	MOV R12, #100
	BX LR

checkButtonStatus
	MOV R4, LR
	CMP R9, #1
	MOV R0, #20
	BLEQ increaseDutyCycle
	MOV R9, #0
	MOV LR, R4
	BX LR;

breath
	MOV R3, LR
	MOV R0, #2
	CMP R7, #0	; check if R11 is 100
	BLEQ increaseDutyCycle
	CMP R7, #1
	BLEQ decreaseDutyCycle
	; check if we have a delay bigger than 100 or less than 0
	CMP R11, #0
	BLMI dutyReset	
	CMP R12, #0
	BLMI dutyReset
	BL toggleLED
	MOV LR, R3
	BX LR;
	
toggleLED
	MOV R4, LR
	LDR R0, =LED_ON
	STR R0, [R8]	; turn led on
	MOV R0, R11
	BL delay
	LDR R0, =LED_OFF
	STR R0, [R8]	; turn led off
	MOV R0, R12
	BL delay
	MOV LR, R4
	BX LR;
	

     ALIGN      ; make sure the end of this section is aligned
     END        ; end of file

