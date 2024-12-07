module control_unit
import riscv_params_pkg::*;
( 
    input bit [4:0] opcode,
    input bit I_bit,
    output control_signal ctrl_sig
);


assign ctrl_sig.isSt        = opcode==ST ? 1'b1: 1'b0;
assign ctrl_sig.isLd        = opcode==LD ? 1'b1: 1'b0;
assign ctrl_sig.isBeq       = opcode==BEQ ? 1'b1: 1'b0;
assign ctrl_sig.isBgt       = opcode==BGT ? 1'b1: 1'b0;
assign ctrl_sig.isRet       = opcode==RET ? 1'b1 : 1'b0;
assign ctrl_sig.isImmediate = I_bit ? 1'b1 : 1'b0;
assign ctrl_sig.isWb =      opcode==ADD || opcode==SUB || opcode==MUL || opcode==DIV || opcode==MOD || opcode==AND || opcode==OR || opcode==NOT || opcode==MOV || opcode==LD || opcode==LSL || opcode==LSR || opcode==ASR || opcode==CALL ? 1'b1 : 1'b0;
assign ctrl_sig.isUBranch   = opcode==B || opcode==CALL || opcode==RET ? 1'b1 : 1'b0;
assign ctrl_sig.isCall      = opcode==CALL ? 1'b1 : 1'b0;
assign ctrl_sig.isAdd       = opcode==ADD ? 1'b1 : 1'b0;
assign ctrl_sig.isSub       = opcode==SUB ? 1'b1 : 1'b0;
assign ctrl_sig.isCmp       = opcode==CMP ? 1'b1 : 1'b0;
assign ctrl_sig.isMul       = opcode==MUL ? 1'b1 : 1'b0;
assign ctrl_sig.isDiv       = opcode== DIV ? 1'b1 : 1'b0;
assign ctrl_sig.isMod       = opcode==MOD ? 1'b1 : 1'b0;
assign ctrl_sig.isLsl       = opcode==LSL ? 1'b1 : 1'b0;
assign ctrl_sig.isLsr       = opcode==LSR ? 1'b1 : 1'b0;
assign ctrl_sig.isAsr       = opcode==ASR ? 1'b1 : 1'b0;
assign ctrl_sig.isOr        = opcode==OR ? 1'b1 : 1'b0;
assign ctrl_sig.isAnd       = opcode==AND ? 1'b1 : 1'b0;
assign ctrl_sig.isNot       = opcode==NOT ? 1'b1 : 1'b0;
assign ctrl_sig.isMov       = opcode==MOV ? 1'b1 : 1'b0;


endmodule
