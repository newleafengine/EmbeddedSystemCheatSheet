       THUMB     
       AREA    |.text|, CODE, READONLY, ALIGN=2
       EXPORT Start			; export Start for Startup.s
	   IMPORT Random		; import random from C
Start   
       BL add64
       
add64
       ADD r6, LR			; store the return address of the line 'BL add64'
       BL Random			; call random
       MOV r3, r0			; store random value in r3
       BL Random			; call random
       QADD r0, r0, r3		; this will perform add with saturation on the last random value and r1
       BX r6				; branch link to the address after add64
	   
	   
	   ALIGN
	   END