module register_access
import riscv_params_pkg::*;
(
    input clk,
    input rst,
    input bit decode_en, // input from top,( for now)
    input control_signal ctrl_sig_reg, // input from (decode unit)
    input bit [INSTR_WIDTH-1:0] result,  // input from writeback unit
    input bit [ADDR_WIDTH-1:0] rd_addr_1, // input from decode unit
    input bit [ADDR_WIDTH-1:0] rd_addr_2, // input from decode unit
    input bit [ADDR_WIDTH-1:0] reg_wb_addr, //input from wb unit
    input fw_sig fw_dd, // input from forwarding unit
    output bit [INSTR_WIDTH-1:0] op1, op2 // output to decode unit 
    

);

bit [INSTR_WIDTH-1:0] register_mem[(2**ADDR_WIDTH)-1:0];

// Initializing register memory for simulation

`ifndef PROC_SYNTH
initial begin
    //register_mem[0] = 'b0; // hardcoded x0 to 0
    register_mem[0] = 'd8; 
    for(int i=1; i< 16; i++)
    begin
        register_mem[i] = $urandom_range(1,8);
    end
end
`endif

initial begin
    register_mem[14] = 'd4092;
    register_mem[15] = 'b0;
end


// Read from register memory - done by decode unit
always @(posedge clk)
begin
    if(rst)
    begin
        op1 <= 'b0;
        op2 <= 'b0;
    end
    else
    begin
        if(decode_en)
        begin
            //AM op1 <= register_mem[rd_addr_1];
            //AM op2 <= register_mem[rd_addr_2];

            op1 <= fw_dd.wb_dd_rs1_conflict ? fw_dd.wb_fw_result:register_mem[rd_addr_1];
            op2 <= fw_dd.wb_dd_rs2_conflict ? fw_dd.wb_fw_result:register_mem[rd_addr_2];
        end
        else
        begin
            op1 <= op1;
            op2 <= op2;
        end
    end
end

// writing into register memory, done by register WB unit
always @(posedge clk)
begin
    if(rst)
    begin
        for(int i=0; i<15; i++ )
        begin
            register_mem[i] <= 'b0;
        end
    end
    else
    begin
        if(ctrl_sig_reg.isWb)
        begin
            // in Simplerisc we can write on r0 also 
            register_mem[reg_wb_addr] <= result;
            $display($time,"register access: reg_wb_addr=%h, register_mem[reg_wb_addr]=%h",reg_wb_addr, register_mem[reg_wb_addr]);
        end
        else
            register_mem[reg_wb_addr] <=register_mem[reg_wb_addr];
    end
end





endmodule
