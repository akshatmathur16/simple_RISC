.main: 
.encode mov r0, 371
.encode mov r1,0   
.encode mov r2,r0
.encode mov r5,0
.encode b check


loop:
.encode mod r3,r2,10
.encode mul r4,r3, r3
.encode mul r4,r4,r3
.encode add  r5, r5,	r4
.encode div r2,r2,0x 00     0A
.encode b check


check:
.encode cmp r2, 0
.encode bgt loop
.encode beq end


end:
.encode cmp r5,r0
.encode beq return
.encode b final

return:
.encode mov r1,1

final:
.print r1
.print r0
.print r2
.print r5
.print r2
.print sp
.print ra

			
   
      

