       THUMB     
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT Start			; export Start for Startup.s
	   IMPORT Random		; import random from C
		   
MAX_UNSIGNED_HIGH EQU 0xFFFFFFF
MAX_UNSIGNED_LOW  EQU 0xFFFFFFF
MAX_SIGNED_HIGH   EQU 0x7FFFFFF
MIN_SIGNED_HIGH	  EQU 0x8000000
MIN_SIGNED_LOW	  EQU 0x0000000

Start   
       BL add64

add64
       ADD r7, LR					; store the return address of the line 'BL add64'
       BL Random					; call random
       MOV r3, r0					; store random value in r3
       BL Random					; call random
       ADDS r5, r0, r3				; add and set flags
       MOVCS r4, #MAX_UNSIGNED_HIGH	; if C flag is set, max r4 and r5
	   MOVCS r5, #MAX_UNSIGNED_LOW	; sets the lower 32 bits to their max value
	   BLVS	getUnsignedValues
       BX r7				; branch link to the address after add64
	   
getUnsignedValues
	   MOVMI r4, #MIN_SIGNED_HIGH	; if signed underflow
	   MOVMI r5, #MIN_SIGNED_LOW	; we set r4 to min signed high, min signed low
	   MOVPL r4, #MAX_SIGNED_HIGH	; else if signed overflow 
	   MOVSPL r5, #MAX_UNSIGNED_LOW	; we set r4 to max signed upperbits,max signed lower bits ( unsigned low bits are the same )
	   BX LR
	   
	   ALIGN
	   END