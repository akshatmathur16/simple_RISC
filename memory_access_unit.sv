module memory_access_unit
import riscv_params_pkg::*;
(
    input clk,
    input rst,
    input mem_en,
    input bit [ADDR_WIDTH-1:0] rd_in_mem, //input from execute unit 
    input bit [INSTR_WIDTH-1:0]pc_out_in_mem, // input from execute unit
    input address_reg address_reg_in_mem, //input from execute unit
    // coming from decode unit
    input bit [INSTR_WIDTH-1:0] op2,
    input bit [INSTR_WIDTH-1:0] aluResult,
    input fw_sig fw_mem, // connect with fw unit
    input control_signal ctrl_sig_reg, 
    output control_signal ctrl_sig_reg_mem_out, 
    output bit [ADDR_WIDTH-1:0] rd_out_mem, //output to WB unit 
    output bit [INSTR_WIDTH-1:0]pc_out_out_mem, //output to WB unit 
    output bit [INSTR_WIDTH-1:0] aluResult_out_mem,
    output address_reg address_reg_out_mem, //output to WB unit
    output bit [INSTR_WIDTH-1:0] mem_fw_result, 
    output bit [INSTR_WIDTH-1:0] ldResult // connect with Wb unit and forwarding unit


);

bit [INSTR_WIDTH-1:0] mdr;
bit [INSTR_WIDTH-1:0] mar;
bit [INSTR_WIDTH-1:0] mar_temp;

bit [INSTR_WIDTH-1:0] data_mem[DATA_MEM_DEPTH-1:0];

assign mdr = fw_mem.wb_mem_rs2_conflict ? fw_mem.wb_fw_result: op2;
assign mar_temp = aluResult;
assign mar = mar_temp[32-1:0];

assign mem_fw_result = ctrl_sig_reg.isLd ? ldResult: aluResult;

// TAKE THIS TO TOP assign mem_en= ctrl_sig_reg.isLd || ctrl_sig_reg.isSt ? 1'b1: 1'b0;

initial begin
    for(int i=0; i< DATA_MEM_DEPTH; i++)
    begin
        data_mem[i] = $urandom_range(1,100);
    end
end


always @(posedge clk)
begin
    if(rst)
    begin
        ldResult <= 'b0;
        ctrl_sig_reg_mem_out <= 'b0;
        rd_out_mem <= 'b0; 
        pc_out_out_mem <= 'b0;
        aluResult_out_mem <= 'b0;
        address_reg_out_mem <= 'b0;
    end
    else
    begin
        ctrl_sig_reg_mem_out <= ctrl_sig_reg;
        rd_out_mem <= rd_in_mem;
        pc_out_out_mem <= pc_out_in_mem;
        aluResult_out_mem <= aluResult;
        address_reg_out_mem <= address_reg_in_mem;

        if(mem_en)
        begin
            if(ctrl_sig_reg.isSt) // Store instruction 
            begin
                if(mar <= DATA_MEM_DEPTH-1)
                    data_mem[mar] <= mdr;
                else
                    $display($time, "Memory access unit: Trying to write in memory(Store) mar should be less than 65536\n");
            end
            else if(ctrl_sig_reg.isLd) // Load instruction
            begin
                if(mar <= DATA_MEM_DEPTH-1)
                    ldResult <= data_mem[mar];
                else
                    $display($time, "Memory access unit:trying to read from memory(Load):  mar should be less than 65536\n");
            end	
        end

    end
end


endmodule
