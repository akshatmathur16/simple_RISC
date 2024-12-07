package riscv_params_pkg;
    parameter INSTR_WIDTH=32;
    parameter MEM_DEPTH=2**12;
    parameter ADDR_WIDTH = 4;
    parameter DATA_MEM_DEPTH=2**12;


    typedef struct packed
    {
        bit isSt;
        bit isLd;
        bit isBeq ;
        bit isBgt ;
        bit isRet ;
        bit isImmediate;
        bit isWb ;
        bit isUBranch ;
        bit isCall ;
        bit isAdd ;
        bit isSub ;
        bit isCmp ;
        bit isMul ;
        bit isDiv ;
        bit isMod ;
        bit isLsl ;
        bit isLsr ;
        bit isAsr ;
        bit isOr ;
        bit isAnd ;
        bit isNot ;
        bit isMov;
    } control_signal;

    typedef struct packed
    {
        bit E;
        bit GT;
    } flag;

    typedef struct packed 
    {
        bit [4:0] opcode;
        bit I_bit;
        bit [ADDR_WIDTH-1:0] rs1;
        bit [ADDR_WIDTH-1:0] rs2;
        bit [ADDR_WIDTH-1:0] rd; 
        bit valid;
    } address_reg;

    typedef struct packed 
    {
        // WB-decode forwarding path signals
        bit wb_dd_rs1_conflict;
        bit wb_dd_rs2_conflict;

        // mem - exec forwarding path signals
        bit mem_exec_rs1_conflict;
        bit mem_exec_rs2_conflict;

        // wb - mem forwarding path signals
        bit wb_mem_rs1_conflict;
        bit wb_mem_rs2_conflict;


        // wb - exec forwarding path signals
        bit wb_exec_rs1_conflict;
        bit wb_exec_rs2_conflict;

        //load use stall signal
        bit ld_use_conflict;
    
        // wb-decode fw signal
        // wb-mem fw signal
        bit [INSTR_WIDTH-1:0] wb_fw_result;
        //mem-exec fw signal
        bit [INSTR_WIDTH-1:0] mem_fw_result;
        


    } fw_sig;

        parameter ADD = 5'b00000;
        parameter SUB = 5'b00001;
        parameter MUL = 5'b00010;
        parameter DIV = 5'b00011;
        parameter MOD = 5'b00100;
        parameter CMP = 5'b00101;
        parameter AND = 5'b00110;
        parameter OR  = 5'b00111;
        parameter NOT = 5'b01000;
        parameter MOV = 5'b01001;
        parameter LSL = 5'b01010;
        parameter LSR = 5'b01011;
        parameter ASR = 5'b01100;
        parameter NOP = 5'b01101;
        parameter LD  = 5'b01110;
        parameter ST  = 5'b01111;
        parameter BEQ = 5'b10000;
        parameter BGT = 5'b10001;
        parameter B   = 5'b10010; //TODO check if this works
        parameter CALL= 5'b10011;
        parameter RET = 5'b10100;

        parameter RA = 4'd15; // as per book return address is at 15 location



endpackage
