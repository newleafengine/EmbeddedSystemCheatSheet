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

add64
       MOV r7, LR					; store the return address of the line 'BL add64'
       BL Random					; call random
       MOV r4, r0					; store random value in r4
       BL Random					; call random
       ADDS r5, r0, r4				; add and set flags
       MOVCS r4, #MAX_UNSIGNED_HIGH	; if C flag is set, max r4 and r5
	   MOVCS r5, #MAX_UNSIGNED_LOW	; sets the lower 32 bits to their max value
	   BLVS getUnsignedValues		; this function will return the min/max value based on the N flag
	   PUSH {r4-r5}
       BX r7						; branch link to the address after add64
	   
sub64
       MOV r4, LR					; store the return address of the line 'BL sub64'
       BL Random					; call random
       MOV r3, r0					; store random value in r3
       BL Random					; call random
       SUBS r7, r0, r3				; add and set flags
       MOVCS r6, #MIN_UNSIGNED		; if C flag is set, max r4 and r5
	   MOVCS r7, #MIN_UNSIGNED		; sets the lower 32 bits to their max value
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