module execute_unit
import riscv_params_pkg::*;
(
        input clk,
        input rst,
        input execute_en,
        input control_signal ctrl_sig_reg,
        input [ADDR_WIDTH-1:0] rd_in_ex, // input from decode unit
        input bit [INSTR_WIDTH-1:0]pc_out_in_ex, // input from decode unit
        input address_reg address_reg_in_ex, //input from decode unit
        input bit [INSTR_WIDTH-1:0] immx, // input from decode unit
        input bit [17:0] imm_in, // input from decode unit //TODO
        input bit [INSTR_WIDTH-1:0] branchTarget, // input from decode unit
        input bit [INSTR_WIDTH-1:0] op1, op2, // input from decode unit
        input fw_sig fw_exec, // connect with forwarding unit
        //to fetch unit
        output bit isBranchTaken, //output to fetch unit, and decode unit to take care of branch bubbles
        output bit [INSTR_WIDTH-1:0]branchPC, // output to fetch unit
        // to memory unit
        output flag flags, // output to memory unit
        output bit [INSTR_WIDTH-1:0] aluResult,  // output to memory unit
        output control_signal ctrl_sig_reg_exec_out, //output to memory unit
        output bit [ADDR_WIDTH-1:0] rd_out_ex, // output to memory unit
        output bit [INSTR_WIDTH-1:0]pc_out_out_ex, //output to memory unit 
        output address_reg address_reg_out_ex, // output to memory unit
        output bit [INSTR_WIDTH-1:0] op2_out // output to memory unit
);


bit [INSTR_WIDTH-1:0] aluinput_A, aluinput_B, aluinput_B_temp;
bit adder_en;
bit mul_en;
bit div_en;
bit shift_unit_en;
bit logical_unit_en;
bit mov_en;
bit [1:0] sel_m3, sel_m4;


// forwarding logic select line
always_comb
begin
    if( fw_exec.mem_exec_rs1_conflict && fw_exec.wb_exec_rs1_conflict)
        sel_m3 = 2'b11; //merge 
    else if(fw_exec.mem_exec_rs1_conflict=='b0 && fw_exec.wb_exec_rs1_conflict=='b1)
        sel_m3 = 2'b01; 
    else if(fw_exec.mem_exec_rs1_conflict=='b1 && fw_exec.wb_exec_rs1_conflict=='b0)
        sel_m3 = 2'b10;//merge
    else
        sel_m3 = 2'b00;

    if( fw_exec.mem_exec_rs2_conflict && fw_exec.wb_exec_rs2_conflict)
        sel_m4 = 2'b11; //merge 
    else if(fw_exec.mem_exec_rs2_conflict=='b0 && fw_exec.wb_exec_rs2_conflict=='b1)
        sel_m4 = 2'b01; 
    else if(fw_exec.mem_exec_rs2_conflict=='b1 && fw_exec.wb_exec_rs2_conflict=='b0)
        sel_m4 = 2'b10;//merge
    else
        sel_m4 = 2'b00;

end

// implementing muxed M3, M4 for forwarding
always_comb
begin
    // M3
    if(sel_m3==2'b11 || sel_m3==2'b10)
        aluinput_A =  fw_exec.mem_fw_result;
    else if(sel_m3==2'b01)
        aluinput_A = fw_exec.wb_fw_result;
    else 
        aluinput_A = op1;

    // M4
    if(sel_m4==2'b11 || sel_m4==2'b10)
        aluinput_B =  fw_exec.mem_fw_result;
    else if(sel_m4==2'b01)
        aluinput_B = fw_exec.wb_fw_result;
    else 
        aluinput_B = aluinput_B_temp;

end



assign branchPC = ctrl_sig_reg.isRet ? aluinput_A : branchTarget; //NOTE aluinputA = op1, so replaced op1 with aluinputA - this change will be useful in fwing
assign isBranchTaken = ctrl_sig_reg.isBeq & flags.E || ctrl_sig_reg.isBgt & flags.GT || ctrl_sig_reg.isUBranch;
//AM assign aluinput_A = op1;

//M' mux
assign aluinput_B_temp = ctrl_sig_reg.isImmediate ? ctrl_sig_reg.isSt || ctrl_sig_reg.isLd ? imm_in : immx : op2;

assign adder_en = ctrl_sig_reg.isAdd || ctrl_sig_reg.isSub || ctrl_sig_reg.isCmp || ctrl_sig_reg.isSt || ctrl_sig_reg.isLd ? 1'b1: 1'b0; //TODO
assign mul_en = ctrl_sig_reg.isMul ? 1'b1: 1'b0;
assign div_en = ctrl_sig_reg.isDiv || ctrl_sig_reg.isMod ? 1'b1: 1'b0;
assign shift_unit_en = ctrl_sig_reg.isLsl || ctrl_sig_reg.isLsr || ctrl_sig_reg.isAsr ? 1'b1: 1'b0;
assign logical_unit_en = ctrl_sig_reg.isOr || ctrl_sig_reg.isNot || ctrl_sig_reg.isAnd ? 1'b1: 1'b0;
assign mov_en = ctrl_sig_reg.isMov ? 1'b1: 1'b0;


always @(posedge clk)
begin
    if(rst)
    begin
        aluResult <= 'b0;
        op2_out <= 'b0;
        ctrl_sig_reg_exec_out <= 'b0; 
        rd_out_ex <= 'b0; 
        pc_out_out_ex <= 'b0;
        address_reg_out_ex <='b0;
    end
    else
    begin
        if(execute_en)
        begin
            op2_out <= op2;
            ctrl_sig_reg_exec_out <= ctrl_sig_reg;
            rd_out_ex <= rd_in_ex;
            pc_out_out_ex <= pc_out_in_ex; 
            address_reg_out_ex <= address_reg_in_ex;

            if(adder_en)
            begin
                if(ctrl_sig_reg.isAdd || ctrl_sig_reg.isSt || ctrl_sig_reg.isLd) // for store and load instr, [rs1+imm]
                    aluResult <= aluinput_A + aluinput_B;
                else if(ctrl_sig_reg.isSub)
                    begin
                        if(aluinput_B >aluinput_A)
                            aluResult <= aluinput_B- aluinput_A;
                        else
                            aluResult <= aluinput_A - aluinput_B;
                    end
                else if(ctrl_sig_reg.isCmp) // ctrl_sig_reg.isCmp
                begin
                        $display($time,"cmp block0");
                    //if(aluinput_A- aluinput_B > 'b0)
                    if(aluinput_A> aluinput_B)
                    begin
                        $display($time,"cmp block1");
                        aluResult <= 1'b1;
                        flags.E <= 1'b0;
                        flags.GT <= 1'b1;
                    end
                    else if(aluinput_A == aluinput_B) // B ==A
                    begin
                        $display($time,"cmp block2");
                        aluResult <= 1'b0;
                        flags.E <= 1'b1;
                        flags.GT <= 1'b0;
                    end
                    //else if (aluinput_A - aluinput_B < 'b0)
                    else if (aluinput_A < aluinput_B )
                    begin
                        $display($time,"cmp block3");
                        aluResult <= 1'b0;
                        flags.E <= 1'b0;
                        flags.GT <= 1'b0;
                    end
                end
            end
            else if(mul_en)
                aluResult <= aluinput_A * aluinput_B;
            else if(div_en)
                if(ctrl_sig_reg.isDiv)
                begin
                    if(aluinput_B!='b0)
                        aluResult <= aluinput_A / aluinput_B;
                    else
                        $display($time,"execute unit: ERROR: Trying to divide by zero, previous value will be retained\n");
                end
                else
                    aluResult <= aluinput_A % aluinput_B;
            else if(shift_unit_en)
            begin
                if(ctrl_sig_reg.isLsl)
                    aluResult <= aluinput_A << aluinput_B;
                else if(ctrl_sig_reg.isLsr)
                    aluResult <= aluinput_A >> aluinput_B;
                else if(ctrl_sig_reg.isAsr)
                    aluResult <= aluinput_A >>> aluinput_B;
            end
            else if(logical_unit_en)
            begin
                if(ctrl_sig_reg.isAnd)
                    aluResult <= aluinput_A & aluinput_B;
                else if(ctrl_sig_reg.isOr)
                    aluResult <= aluinput_A | aluinput_B;
                else if(ctrl_sig_reg.isNot)
                    aluResult <= ~aluinput_A; 
            end
            else if (mov_en)
                aluResult <= aluinput_B;
        end
        else
        begin
            aluResult <= aluResult;
            op2_out <= op2;
            ctrl_sig_reg_exec_out <=ctrl_sig_reg_exec_out ;
            rd_out_ex <= rd_out_ex;
            pc_out_out_ex <= pc_out_out_ex; 
            address_reg_out_ex <= address_reg_out_ex;
        end
    end
end

endmodule
