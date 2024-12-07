module fetch_unit
import riscv_params_pkg::*;
(
    input clk,
    input rst,
    input bit fetch_en,
    input bit isBranchTaken,
    input bit [INSTR_WIDTH-1:0]branchPC,
    output bit [INSTR_WIDTH-1:0]pc_out,
    output bit [INSTR_WIDTH-1:0]instr_out
);


//bit [INSTR_WIDTH-1:0] instr_mem[MEM_DEPTH-1:0];
bit [7:0] instr_mem[MEM_DEPTH-1:0];
bit [INSTR_WIDTH-1:0] pc;


initial begin
    $readmemh("instr_file.hex", instr_mem);
end


bit [INSTR_WIDTH-1:0]instr_out_temp;
//AM bit [INSTR_WIDTH-1:0]instr_out_temp_temp;
//AM bit [7:0] instr_mem_temp[MEM_DEPTH-1:0];
//AM 
//AM 
//AM always_comb
//AM begin
//AM     for(int i=0; i<MEM_DEPTH; i++)
//AM     begin
//AM         for(int j=0; j<4; j=j+2)
//AM         begin
//AM             instr_mem_temp[i] = instr_mem[i][j];
//AM             $display("instr_mem_temp[i][j]=%h", instr_mem_temp[i][j]);
//AM         end
//AM     end
//AM end



//assign instr_out_temp = {instr_mem[pc], instr_mem[pc+1], instr_mem[pc+2], instr_mem[pc+3]};
assign instr_out_temp = {instr_mem[pc_out], instr_mem[pc_out+1], instr_mem[pc_out+2], instr_mem[pc_out+3]};


always @(posedge clk)
begin
    if(rst)
    begin
        //pc <= 'b0;
        pc_out <= 'b0;
        instr_out <= 'b0;
    end
    else
    begin
        if(fetch_en)
        begin
            if(isBranchTaken)
            begin
                pc_out <= branchPC;
                //taking care of branching instructions
                instr_out <= {NOP, 27'd0}; 
            end
            else
            begin
                // pc <= pc+4;
                //pc_out <= pc;
                pc_out <= pc_out+4;
                instr_out <= instr_out_temp;
            end
              
            //pc <=isBranchTaken? branchPC: pc +4; //incrementing pc=pc+4
            //AM instr_out <= instr_out_temp;
        end
        else
        begin
            instr_out <= instr_out;
            //pc <= pc;
        end
    end
end




endmodule
