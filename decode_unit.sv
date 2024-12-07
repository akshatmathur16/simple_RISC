module decode_unit
import riscv_params_pkg::*;
(
    input clk,
    input rst,
    input bit [INSTR_WIDTH-1:0]pc_out, // input from fetch unit
    input bit [INSTR_WIDTH-1:0]instr_in, // input from fetch unit
    input bit [INSTR_WIDTH-1:0] operand1, operand2, //operands 1 ,2 input from register_access
    input bit decode_en,// input from top , for now
    // WB-decode forwarding path signals
    //AM input fw_sig fw_dd, // input from forwarding unit
    input isBranchTaken, // input from execute unit
    
    output address_reg address_reg_decode_in, // for comparision for decode block forwarding
    output address_reg address_reg_decode, // for comparison for execute block forwarding
    output bit decode_en_reg_access, // output to register access
    output control_signal ctrl_sig_reg,
    output bit [INSTR_WIDTH-1:0] immx, // output to fetch unit
    output bit [17:0] imm_out, // output to execute unit  //TODO
    output bit [INSTR_WIDTH-1:0] branchTarget, //output to execute unit
    output bit [ADDR_WIDTH-1:0] rd_out_decode, // connect with register wb
    output bit [INSTR_WIDTH-1:0]pc_out_decode, // output to execute unit
    output bit [INSTR_WIDTH-1:0] op1, op2, //operands 1 ,2 output to execute unit
    //Register Read signals
    output control_signal ctrl_sig_out, // output to register access
    output bit [ADDR_WIDTH-1:0] rd_addr_1, // output to register access
    output bit [ADDR_WIDTH-1:0] rd_addr_2 // output to register access

);

bit [4:0] opcode;
bit I_bit;
bit [ADDR_WIDTH-1:0] rs1;
bit [ADDR_WIDTH-1:0] rs2;
bit [15:0] imm;
control_signal ctrl_sig;
bit [17:0] imm_out_temp; // non registered 
bit [ADDR_WIDTH-1:0] rd; 
    
bit [INSTR_WIDTH-1:0]instr; // input from fetch unit
bit [INSTR_WIDTH-1:0] offset;


//providing unregistered ctrl_sig to register access unit
assign ctrl_sig_out = ctrl_sig;

assign instr = isBranchTaken ? {NOP, 27'd0}: instr_in;
assign offset = {{3{instr[26]}}, instr[26:0], 2'b00};





// Decoding instruction into fields, taking care of NOP

assign opcode = instr[31:27];
assign I_bit  = opcode== NOP ? 'b0 : instr[26];
assign rd =  opcode== NOP ? 'b0 : instr[25:22];
assign rs1 =  (opcode==NOP || opcode==MOV || opcode==NOT) ? 'b0 :   instr[21:18];


// for not and mov, imm is updated, rs2 is not updated in this implementation
assign imm_out_temp = I_bit ? ctrl_sig.isLd || ctrl_sig.isSt ? instr[17:0]: instr[15:0]: 'b0;
assign imm = opcode== NOP ? 'b0 :  I_bit ? imm_out_temp[15:0]: 'b0;
assign rs2 = opcode== NOP ? 'b0 :  I_bit ? 'b0: instr[17:14];
assign valid = opcode== NOP ? 'b0 : 1'b1; 

assign rd_addr_1 = ctrl_sig.isRet ? RA: rs1;
assign rd_addr_2 = ctrl_sig.isSt ? rd: rs2;

//adding wb - decode forwarding condition also
//AM assign op1 = fw_dd.wb_dd_rs1_conflict ? fw_dd.wb_fw_result: operand1;
//AM assign op2 = fw_dd.wb_dd_rs2_conflict ? fw_dd.wb_fw_result: operand2;
assign op1 = operand1;
assign op2 = operand2;

assign decode_en_reg_access = decode_en;


assign address_reg_decode_in.rs1 = rs1; 
assign address_reg_decode_in.rs2 = rs2; 
assign address_reg_decode_in.rd = rd; 
assign address_reg_decode_in.opcode = opcode; 
assign address_reg_decode_in.I_bit = I_bit; 
assign address_reg_decode_in.valid = valid;


//control unit 

control_unit inst_constrol_unit
(
    .opcode(opcode),
    .I_bit(I_bit),
    .ctrl_sig(ctrl_sig)
);

always @(posedge clk)
begin
    if(rst)
    begin
        ctrl_sig_reg <= 'b0;
        rd_out_decode <= 'b0;
        pc_out_decode <= 'b0;
        address_reg_decode.rs1 <= 'b0; 
        address_reg_decode.rs2 <= 'b0; 
        address_reg_decode.rd <= 'b0; 
        address_reg_decode.opcode <= 'b0; 
        address_reg_decode.I_bit<= 'b0; 
        address_reg_decode.valid<= 'b0; 
    end
    else
    begin
        if(decode_en)
        begin
                ctrl_sig_reg <= ctrl_sig;
                rd_out_decode <= rd;
                pc_out_decode <= pc_out;

                //driving registered output to struct address_reg so as to compare address_reg_decode
                //values of other stages and pass along to all units
                address_reg_decode.rs1 <= rs1; 
                address_reg_decode.rs2 <= rs2; 
                address_reg_decode.rd <= rd; 
                address_reg_decode.opcode <= opcode; 
                address_reg_decode.I_bit<= I_bit; 
                address_reg_decode.valid<=valid; 

        end
        else
        begin
            ctrl_sig_reg <= ctrl_sig_reg;
            rd_out_decode <= rd_out_decode;
            pc_out_decode <= pc_out_decode;
            address_reg_decode.rs1 <= address_reg_decode.rs1 ; 
            address_reg_decode.rs2 <= address_reg_decode.rs2; 
            address_reg_decode.rd <= address_reg_decode.rd; 
            address_reg_decode.opcode <= address_reg_decode.opcode; 
            address_reg_decode.I_bit<= address_reg_decode.I_bit; 
            address_reg_decode.valid<= address_reg_decode.valid; 
        end
    end
end






// immx and branchTarget Logic


always @(posedge clk)
begin
    if(rst)
    begin
        immx <= 'b0;
        branchTarget <= 'b0;
    end
    else
    begin
        if(decode_en)
        begin
            // modifier bit == 00 -> simply sign extend
            // modifier bits == 01 -> unsigned -> pad with 0
            // modifier bits ==10 -> load upperhalf and pad the lower half with
            // 0
            immx <= I_bit ? (instr[17:16]==2'b00 ? {imm[15], imm} :
                (instr[17:16]==2'b01 ? {{16{1'b0}}, imm} :
                (instr[17:16]==2'b10 ? {imm,{16{1'b0}}}  : 'b0))) : 'b0 ;

            //AM branchTarget <= ctrl_sig.isRet ? operand1: pc_out + offset; 
            //AM branchTarget <= pc_out + offset; // isRet muxing is taken care in execute unit
            branchTarget <= pc_out_decode + offset; // isRet muxing is taken care in execute unit
            imm_out <= imm_out_temp;

        end
        else
        begin
            immx <= immx;
            branchTarget <= branchTarget;
            imm_out <= imm_out; // TODO
        end
    end
end

//Register Read done on top


endmodule
