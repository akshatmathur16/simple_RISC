`timescale 1ns/1ps
module tb_fd_execute_unit();
import riscv_params_pkg::*;

bit clk;
bit rst;
bit fetch_en;
bit isBranchTaken;
bit [INSTR_WIDTH-1:0]branchPC;
bit [INSTR_WIDTH-1:0]pc_out;
bit [INSTR_WIDTH-1:0]instr_out;
bit decode_en_reg_access;
control_signal ctrl_sig_out;
control_signal ctrl_sig_reg;
address_reg address_reg_decode_in;
address_reg address_reg_in_ex;
address_reg address_reg_in_mem;
address_reg address_reg_out_mem;
bit [INSTR_WIDTH-1:0] immx;
bit [INSTR_WIDTH-1:0] branchTarget;
bit [INSTR_WIDTH-1:0] op1, op2; //operands 1 ,2
//Register Read signals
bit [ADDR_WIDTH-1:0] rd_addr_1;
bit [ADDR_WIDTH-1:0] rd_addr_2;
bit [INSTR_WIDTH-1:0] operand1, operand2;
bit [INSTR_WIDTH-1:0] wb_result;  // input from writeback unit
bit [INSTR_WIDTH-1:0] ldResult; // connect with WB unit 
bit [17:0] imm_in; // connect with decode and execute unit
bit [ADDR_WIDTH-1:0] reg_wb_addr; // connect bw WB and register access unit
bit [ADDR_WIDTH-1:0] rd_in_ex; // connect with execute unit 
bit [ADDR_WIDTH-1:0] rd_in_mem; // output to memory unit
bit [ADDR_WIDTH-1:0] rd_in_wb; // output to WB unit
bit [INSTR_WIDTH-1:0]pc_out_in_ex; // input to execute unit
bit [INSTR_WIDTH-1:0]pc_out_in_mem; // input to memory unit
bit [INSTR_WIDTH-1:0]pc_out_in_wb; // input to wb unit
bit [INSTR_WIDTH-1:0] aluResult_out_mem; // input to wb unit

flag flags;
bit [INSTR_WIDTH-1:0] aluResult;
bit [INSTR_WIDTH-1:0] op2_out; 
control_signal ctrl_sig_reg_exec_out;
control_signal ctrl_sig_reg_mem_out;

bit decode_en;
bit execute_en;
bit mem_en;

//forwarding signals
fw_sig fw; // connect with forwarding unit and share with all other units
bit [INSTR_WIDTH-1:0] mem_fw_result;


assign mem_en= ctrl_sig_reg_exec_out.isLd || ctrl_sig_reg_exec_out.isSt ? 1'b1: 1'b0;

// for load use case toggling for 1 cycle
always @(posedge clk)
begin
    fetch_en <= 1'b1;
    decode_en <= 1'b1;
    execute_en <= 1'b1;
    if(fw.ld_use_conflict)
    begin
        fetch_en <= 1'b0;
        decode_en <= 'b0;
        execute_en <= 'b0;
    end
end

//always @(posedge clk)
//begin
//    if(fw.ld_use_conflict && !toggle)
//    begin
//        decode_en <= 'b0;
//        execute_en <= 'b0;
//    end
//    else 
//    begin
//        decode_en <= 'b1;
//        execute_en <= 'b1;
//    end
//
//    toggle <= fw.ld_use_conflict ? toggle: 1'b0;
//end


fetch_unit inst_fetch_unit
(
    .clk(clk),
    .rst(rst),
    .fetch_en(fetch_en),
    .isBranchTaken(isBranchTaken), //input from execute unit
    .branchPC(branchPC), // input from execute unit
    .pc_out(pc_out),
    .instr_out(instr_out)
);

decode_unit inst_decode_unit
(
    .clk(clk),
    .rst(rst),
    .pc_out(pc_out), //input from fetch unit
    .instr_in(instr_out),
    .operand1(operand1),
    .operand2(operand2), 
    .decode_en(decode_en),
    //AM .fw_dd(fw), // input from forwarding unit
    .isBranchTaken(isBranchTaken), //input from execute unit
    .address_reg_decode_in(address_reg_decode_in),
    .address_reg_decode(address_reg_in_ex),
    .decode_en_reg_access(decode_en_reg_access),
    .ctrl_sig_reg(ctrl_sig_reg),
    .immx(immx),
    .imm_out(imm_in),
    .branchTarget(branchTarget),
    .rd_out_decode(rd_in_ex), 
    .pc_out_decode(pc_out_in_ex), // output to execute unit
    .op1(op1),
    .op2(op2), 
    .ctrl_sig_out(ctrl_sig_out),
    .rd_addr_1(rd_addr_1),
    .rd_addr_2(rd_addr_2)

);

register_access inst_register_access
(
    .clk(clk),
    .rst(rst),
    .decode_en(decode_en_reg_access),
    //AM TODO check .ctrl_sig_reg(ctrl_sig_out),
    .ctrl_sig_reg(ctrl_sig_reg_mem_out),
    .result(wb_result),
    .rd_addr_1(rd_addr_1),
    .rd_addr_2(rd_addr_2),
    .reg_wb_addr(reg_wb_addr),
    .fw_dd(fw), // input from forwarding unit
    .op1(operand1),
    .op2(operand2)
    

);
execute_unit inst_execute_unit
(
        .clk(clk),
        .rst(rst),
        .execute_en(execute_en),
        .ctrl_sig_reg(ctrl_sig_reg),
        .rd_in_ex(rd_in_ex), 
        .pc_out_in_ex(pc_out_in_ex), // input from decode unit
        .address_reg_in_ex(address_reg_in_ex), //input from decode unit
        .immx(immx),
        .imm_in(imm_in),
        .branchTarget(branchTarget), //input from decode unit
        .op1(op1), // input from decode unit
        .op2(op2), //input from decode unit
        .fw_exec(fw), // connect with forwarding unit
        .isBranchTaken(isBranchTaken),
        .branchPC(branchPC), //output to fetch unit
        .flags(flags),
        .aluResult(aluResult), // output to memory access unit
        .ctrl_sig_reg_exec_out(ctrl_sig_reg_exec_out),
        .rd_out_ex(rd_in_mem), // output to memory unit
        .pc_out_out_ex(pc_out_in_mem), //output to memory unit 
        .address_reg_out_ex(address_reg_in_mem), // output to memory unit
        .op2_out(op2_out)
);

memory_access_unit inst_memory_access_unit 
(
    .clk(clk),
    .rst(rst),
    .mem_en(mem_en),
    .rd_in_mem(rd_in_mem), //input from execute unit 
    .pc_out_in_mem(pc_out_in_mem), // input from execute unit
    .address_reg_in_mem(address_reg_in_mem), //input from execute unit
    .op2(op2_out),
    .aluResult(aluResult),
    .fw_mem(fw),
    .ctrl_sig_reg(ctrl_sig_reg_exec_out), 
    .ctrl_sig_reg_mem_out(ctrl_sig_reg_mem_out), 
    .rd_out_mem(rd_in_wb), //output to WB unit 
    .pc_out_out_mem(pc_out_in_wb), //output to WB unit 
    .aluResult_out_mem(aluResult_out_mem),
    .address_reg_out_mem(address_reg_out_mem), //output to WB unit
    .mem_fw_result(mem_fw_result), 
    .ldResult(ldResult)

);

register_wb inst_register_wb
(
    .clk(clk),
    .rst(rst),
    .rd(rd_in_wb), // connect with memory unit Registered - originally coming from Decode unit
    .pc_out(pc_out_in_wb), //input from fetch unit
    .aluResult(aluResult_out_mem), //input from memory unit registered - originally comming from decode unit
    .ldResult(ldResult), // input from memory access unit
    .ctrl_sig_reg(ctrl_sig_reg_mem_out),// input from memory access unit
    .result(wb_result), //output to register access unit
    .reg_wb_addr(reg_wb_addr) // output to register access unit
);

forwarding_unit inst_forwarding_unit
(
    .address_reg_dd(address_reg_decode_in),
    .address_reg_exec( address_reg_in_ex),
    .address_reg_mem( address_reg_in_mem),
    .address_reg_wb(address_reg_out_mem),
    .wb_fw_result(wb_result),
    .mem_fw_result(mem_fw_result),
    .fw(fw)
);




initial begin
    rst = 0;
    #5 fetch_en = 1;
    //#5 decode_en = 1;
    //#5 execute_en=1;    
    //#5 mem_en =1;



    #100 $stop;
    
end


initial begin
    $monitor($time,"pc_out=%d, instr_out=%h", pc_out, instr_out);
end



always #5 clk = ~clk;








endmodule


