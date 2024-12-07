module register_wb
import riscv_params_pkg::*;
(
    input clk,
    input rst,
    input [ADDR_WIDTH-1:0] rd, // connect with decode unit but Registered 
    input bit [INSTR_WIDTH-1:0] pc_out, // connect with Fetch unit but registered
    input bit [INSTR_WIDTH-1:0] aluResult, // connect with execute unit but registered
    input bit [INSTR_WIDTH-1:0] ldResult, // connect with memory unit
    input control_signal ctrl_sig_reg, // connect with memory unit
    output bit [INSTR_WIDTH-1:0] result, 
    output bit [ADDR_WIDTH-1:0] reg_wb_addr
);



assign result = ctrl_sig_reg.isLd=='b0 && ctrl_sig_reg.isCall=='b0 ? aluResult
                                  : ctrl_sig_reg.isLd =='b1 && ctrl_sig_reg.isCall=='b0 ? ldResult
                                  : ctrl_sig_reg.isLd=='b0 && ctrl_sig_reg.isCall=='b1 ? pc_out
                                  : result;  
assign reg_wb_addr = ctrl_sig_reg.isCall ? RA : rd; 

//Instantiate register access here


endmodule
