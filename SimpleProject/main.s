       THUMB     
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT Start			; export Start for Startup.s
	   IMPORT Random		; import random from C
		   
MAX_UNSIGNED_HIGH EQU 0xFFFFFFF	
MAX_UNSIGNED_LOW  EQU 0xFFFFFFF
MIN_UNSIGNED	  EQU 0x0000000
MAX_SIGNED_HIGH   EQU 0x7FFFFFF
MIN_SIGNED_HIGH	  EQU 0x8000000
MIN_SIGNED_LOW	  EQU 0x0000000

Start   
       BL add64	; results in r4, r5
	   BL sub64	; results in r5, r6
	   BL endian; results in r4-r13

;	r4 = high result
;	r5 = low result
add64
       MOV r7, LR					; store the return address of the line 'BL add64'
       BL Random					; call random
       MOV r4, r0					; store random value in r4 - low word first number
       BL Random					; call random
       ADDS r5, r0, r4				; add and set flags - low word result
       MOVCS r4, #1					; if C flag is set, move 1 to the high word result 
	   BL Random					; call random
       MOV r6, r0					; store random value in r4 - high word first number
       BL Random					; call random
	   ADD r0, r0, r6
	   ADDS R4, r0, r5 
	   BLVS getUnsignedValues		; this function will return the min/max value based on the N flag
	   PUSH {r4-r5}
       BX r7						; branch link to the address after add64
	   
sub64
       MOV r4, LR					; store the return address of the line 'BL sub64'
       BL Random					; call random
       MOV r4, r0					; store random value in r4 - low word first number
       BL Random					; call random
       SUB r5, r0, r4				; sub and set flags - low word result
       MOVCS r4, #1					; if C flag is set, move 1 to the high word result 
	   BL Random					; call random
       MOV r6, r0					; store random value in r4 - high word first number
       BL Random					; call random
	   SUB r0, r0, r6
	   SUBS R4, r0, r5 
	   BLVS	getUnsignedValues		; this function will return the min/max value based on the N flag
	   PUSH {r6-r7}
       BX r4						; branch link to the address after sub64
	   
endian
	   MOV r12, LR					; store the return address of the line 'BL endian'
	   BL Random
	   REV r4, r0					; rev = Little Endian <-> Big Endian
	   BL Random
	   REV r5, r0
	   BL Random
	   REV r6, r0
	   BL Random
	   REV r7, r0
	   BL Random
	   REV r8, r0
	   BL Random
	   REV r9, r0
	   BL Random
	   REV r10, r0
	   BL Random
	   REV r11, r0
	   PUSH {r4-r11}
	   BX r12
	   
getUnsignedValues
	   MOVMI r4, #MIN_SIGNED_HIGH	; if signed overflow negative
	   MOVMI r5, #MIN_SIGNED_LOW	; we set r4 to min signed high, min signed low
	   MOVPL r4, #MAX_SIGNED_HIGH	; else if signed overflow positive
	   MOVPL r5, #MAX_UNSIGNED_LOW	; we set r4 to max signed upperbits,max signed lower bits ( unsigned low bits are the same )
	   BX LR	; breaks back to the LR
	   
	   ALIGN
	   END