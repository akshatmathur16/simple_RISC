.main:
.encode mov r1, 4
.encode mov r2, 0xc  35
.encode ld r14, 0x4d4[r1]
.encode st r14, 0x f5 5 b[r2]
.print r14
