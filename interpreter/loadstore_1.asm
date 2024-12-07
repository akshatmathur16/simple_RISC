.main:
.encode mov r2, 6
.encode mov r1, 0
.encode st r2, 0x10 [r1]
.encode mov r2, 0x2
.encode st r2, 0x11[r2]
.encode ld r14, 0x10[r4]
.encode ld r15, 0x11[r2]

.encode ld r1, 4[r4]
.encode st r1, 10[r3]



.print sp, ra
.print r0, r1, r2, r14, r15
