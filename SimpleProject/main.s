       THUMB     
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT Start			; export Start for Startup.s
	   IMPORT Random		; import random from C
Start   
       BL add64
add64
       ADD r7, LR			; store the return address of the line 'BL add64'
       BL Random			; call random
       MOV r3, r0			; store random value in r3
       BL Random			; call random
	   ADDS	r5, r0, r3		; add and set flags
	   MOVCS r4, #1			; if C flag is set, add 1 to r4
       BX r7				; branch link to the address after add64
	   
	   ALIGN
	   END