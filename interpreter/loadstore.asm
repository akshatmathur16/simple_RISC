.main:
.encode mov r0, 1234
.encode mov r1, 0
.encode st r0, 0x    4		 d  4 [r1]
.encode mov r2, 0xc  35
.encode st r2, 0x f5 5 b[r2]
.encode ld r14, 0x4d4[r1]
.encode ld r15, 0xf55b[r2]
.print sp, ra
.print r0, r1, r2, r14, r15
