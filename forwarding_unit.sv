module forwarding_unit
import riscv_params_pkg::*;
(
    input address_reg address_reg_dd,
    input address_reg address_reg_exec,
    input address_reg address_reg_mem,
    input address_reg address_reg_wb,
    input bit [INSTR_WIDTH-1:0] wb_fw_result,
    input bit [INSTR_WIDTH-1:0] mem_fw_result,

    output fw_sig fw

   // // WB-decode forwarding path signals
   // output bit wb_dd_rs1_conflict,
   // output bit wb_dd_rs2_conflict,

   // // mem - exec forwarding path signals
   // output bit mem_exec_rs1_conflict,
   // output bit mem_exec_rs2_conflict,

   // // wb - mem forwarding path signals
   // output bit wb_mem_rs1_conflict,
   // output bit wb_mem_rs2_conflict,


   // // wb - exec forwarding path signals
   // output bit wb_exec_rs1_conflict,
   // output bit wb_exec_rs2_conflict,

   // //load use stall signal
   // output bit ld_use_conflict

);

address_reg dd;
address_reg exec;
address_reg mem;
address_reg wb;


// WB-decode forwarding path signals
bit [ADDR_WIDTH-1:0] wb_dd_src_reg1;
bit [ADDR_WIDTH-1:0] wb_dd_src_reg2;
bit [ADDR_WIDTH-1:0] wb_dd_dest_reg;

// mem - exec forwarding path signals
bit [ADDR_WIDTH-1:0] mem_exec_src_reg1;
bit [ADDR_WIDTH-1:0] mem_exec_src_reg2;
bit [ADDR_WIDTH-1:0] mem_exec_dest_reg;

// wb - exec forwarding path signals
bit [ADDR_WIDTH-1:0] wb_exec_src_reg1;
bit [ADDR_WIDTH-1:0] wb_exec_src_reg2;
bit [ADDR_WIDTH-1:0] wb_exec_dest_reg;

// wb - mem forwarding path signals
bit [ADDR_WIDTH-1:0] wb_mem_src_reg1;
bit [ADDR_WIDTH-1:0] wb_mem_src_reg2;
bit [ADDR_WIDTH-1:0] wb_mem_dest_reg;

// load -use stall path signals
//
//
bit [ADDR_WIDTH-1:0] ld_use_src_reg1; // check at decode 
bit [ADDR_WIDTH-1:0] ld_use_src_reg2; // check at decode 
bit [ADDR_WIDTH-1:0] ld_use_dest_reg; // check at execute





// Address registers at the input side of each of each block
assign dd = address_reg_dd;
assign exec =  address_reg_exec;
assign mem =  address_reg_mem;
assign wb =  address_reg_wb;

//assigning fw data signals to struct
assign fw.wb_fw_result = wb_fw_result;
assign fw.mem_fw_result = mem_fw_result;



// Case 1 WB -> Decode forwarding 
// B = MA, A = Decode (with reference to pseudo code in book)
//
always_comb
begin

    if(wb.valid && dd.valid)
    begin
//AM         // for rs1 and rd
//AM         if((dd.opcode != NOP && dd.opcode != B && dd.opcode != BEQ && dd.opcode != BGT && dd.opcode != CALL && dd.opcode != NOT && dd.opcode != MOV) && (wb.opcode != NOP && wb.opcode != CMP && wb.opcode != ST && wb.opcode != B && wb.opcode != BEQ && wb.opcode != BGT && wb.opcode != RET) )
//AM         begin
//AM             $display($time, "block1 here");
//AM             if(dd.opcode == RET)
//AM                 wb_dd_src_reg1 = RA;
//AM             else
//AM                 wb_dd_src_reg1 = dd.rs1;
//AM 
//AM             // for rd
//AM             if(wb.opcode == CALL)
//AM                 wb_dd_dest_reg = RA;
//AM             else
//AM                 wb_dd_dest_reg = wb.rd;
//AM 
//AM             //conflict check for rs1
//AM             //AM fw.wb_dd_rs1_conflict = (wb_dd_src_reg1!='b0 && wb_dd_dest_reg!='b0 ) &&(wb_dd_src_reg1 == wb_dd_dest_reg) ? 1'b1: 1'b0; 
//AM             //AM fw.wb_dd_rs1_conflict = (wb_dd_src_reg1 == wb_dd_dest_reg) ? 1'b1: 1'b0; 
//AM             
//AM             if(wb_dd_src_reg1 == wb_dd_dest_reg)
//AM             begin
//AM             $display($time, "AM raising con wb_dd_src_reg1=%h,  wb_dd_dest_reg=%h ", wb_dd_src_reg1, wb_dd_dest_reg  );
//AM 
//AM                 fw.wb_dd_rs1_conflict = 'b1;
//AM             end
//AM             else
//AM             begin
//AM                 fw.wb_dd_rs1_conflict = 'b0;
//AM                 $display($time, "AM fail wb_dd_src_reg1=%h,  wb_dd_dest_reg=%h ", wb_dd_src_reg1, wb_dd_dest_reg  );
//AM             end
//AM 
//AM 
//AM 
//AM             if(fw.wb_dd_rs1_conflict)
//AM             begin
//AM                 $display($time,"forwarding unit: Raising rs1 conflict WB-Decode\n");
//AM                 $display($time,"forwarding unit: wb.opcode=%b, dd.opcode=%b\n",wb.opcode, dd.opcode);
//AM                 $display($time, "wb_dd_src_reg1 =%b,wb_dd_dest_reg=%b",wb_dd_src_reg1,wb_dd_dest_reg);
//AM             end
//AM         end
//AM         else
//AM             fw.wb_dd_rs1_conflict = 'b0;

        // for rs1
        if(dd.opcode != NOP && dd.opcode != B && dd.opcode != BEQ && dd.opcode != BGT && dd.opcode != CALL && dd.opcode != NOT && dd.opcode != MOV)
        begin
            $display($time, "block1 here");
            if(dd.opcode == RET)
                wb_dd_src_reg1 = RA;
            else
                wb_dd_src_reg1 = dd.rs1;
        end

        // for rd
        if(wb.opcode != NOP && wb.opcode != CMP && wb.opcode != ST && wb.opcode != B && wb.opcode != BEQ && wb.opcode != BGT && wb.opcode != RET)
        begin
            if(wb.opcode == CALL)
                wb_dd_dest_reg = RA;
            else
                wb_dd_dest_reg = wb.rd;
        end


        //check rs1 vs rd
        if((dd.opcode != NOP && dd.opcode != B && dd.opcode != BEQ && dd.opcode != BGT && dd.opcode != CALL && dd.opcode != NOT && dd.opcode != MOV) && (wb.opcode != NOP && wb.opcode != CMP && wb.opcode != ST && wb.opcode != B && wb.opcode != BEQ && wb.opcode != BGT && wb.opcode != RET) )
        begin
            if(wb_dd_src_reg1 == wb_dd_dest_reg)
            begin
                $display($time, "AM raising con wb_dd_src_reg1=%h,  wb_dd_dest_reg=%h ", wb_dd_src_reg1, wb_dd_dest_reg  );

                fw.wb_dd_rs1_conflict = 'b1;
            end
            else
            begin
                fw.wb_dd_rs1_conflict = 'b0;
                $display($time, "AM fail wb_dd_src_reg1=%h,  wb_dd_dest_reg=%h ", wb_dd_src_reg1, wb_dd_dest_reg  );
            end



            if(fw.wb_dd_rs1_conflict)
            begin
                $display($time,"forwarding unit: Raising rs1 conflict WB-Decode\n");
                $display($time,"forwarding unit: wb.opcode=%b, dd.opcode=%b\n",wb.opcode, dd.opcode);
                $display($time, "wb_dd_src_reg1 =%b,wb_dd_dest_reg=%b",wb_dd_src_reg1,wb_dd_dest_reg);
            end
        end
        else
        begin
            fw.wb_dd_rs1_conflict = 'b0;
        end



//AM        //for src2 
//AM        if(dd.opcode != NOP && dd.opcode != B && dd.opcode != BEQ && dd.opcode != BGT && dd.opcode != CALL)
//AM        begin
//AM            $display($time, "block2 here");
//AM            if(dd.opcode == ST)
//AM                wb_dd_src_reg2 = dd.rd;
//AM            else
//AM                wb_dd_src_reg2 = dd.rs2;
//AM
//AM            // Destinaion condition is same for both
//AM
//AM            //AM fw.wb_dd_rs2_conflict = wb.I_bit ==1'b1 ? 1'b0:(wb_dd_src_reg2!='b0 && wb_dd_dest_reg!='b0 ) && ((wb_dd_src_reg2 == wb_dd_dest_reg) ? 1'b1: 1'b0);
//AM            fw.wb_dd_rs2_conflict = dd.I_bit ? 1'b0:((wb_dd_src_reg2 == wb_dd_dest_reg) ? 1'b1: 1'b0);
//AM            if(fw.wb_dd_rs2_conflict)
//AM            begin
//AM                $display($time,"forwarding unit: Raising rs2 conflict WB-Decode\n");
//AM                $display($time,"forwarding unit: wb.opcode=%b, dd.opcode=%b\n",wb.opcode, dd.opcode);
//AM                $display($time, "wb_dd_src_reg2 =%b,wb_dd_dest_reg=%b",wb_dd_src_reg2,wb_dd_dest_reg);
//AM            end
//AM        end
//AM        else
//AM            fw.wb_dd_rs2_conflict = 'b0;
//AM    end
//AM    else
//AM        fw.wb_dd_rs2_conflict = 'b0;

        //for src2 
        if(dd.opcode != NOP && dd.opcode != B && dd.opcode != BEQ && dd.opcode != BGT && dd.opcode != CALL)
        begin
            $display($time, "block2 here");
            if(dd.opcode == ST)
                wb_dd_src_reg2 = dd.rd;
            else
                wb_dd_src_reg2 = dd.rs2;
        end

            // Destinaion condition is same for both


        //comapring rs2 and rd    
        if(dd.opcode != NOP && dd.opcode != B && dd.opcode != BEQ && dd.opcode != BGT && dd.opcode != CALL && wb.opcode != NOP && wb.opcode != CMP && wb.opcode != ST && wb.opcode != B && wb.opcode != BEQ && wb.opcode != BGT && wb.opcode != RET)
        begin

            fw.wb_dd_rs2_conflict = dd.I_bit ? 1'b0:((wb_dd_src_reg2 == wb_dd_dest_reg) ? 1'b1: 1'b0);
            if(fw.wb_dd_rs2_conflict)
            begin
                $display($time,"forwarding unit: Raising rs2 conflict WB-Decode\n");
                $display($time,"forwarding unit: wb.opcode=%b, dd.opcode=%b\n",wb.opcode, dd.opcode);
                $display($time, "wb_dd_src_reg2 =%b,wb_dd_dest_reg=%b",wb_dd_src_reg2,wb_dd_dest_reg);
            end
        end
        else
            fw.wb_dd_rs2_conflict = 'b0;
    end
    else
        fw.wb_dd_rs2_conflict = 'b0;



end


// Case 2 MA -> execute forwarding 
// B = MA, A = execute (with reference to pseudo code in book)
//
always_comb
begin
    if(mem.valid && exec.valid)
    begin

        // for rs1
        //AM if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL && exec.opcode != NOT && exec.opcode != MOV && mem.opcode != LD && mem.opcode != NOP && mem.opcode !=CMP && mem.opcode !=ST && mem.opcode !=B && mem.opcode !=BEQ && mem.opcode !=BGT && mem.opcode !=RET)

        //AM begin
        //AM     $display($time," aa1");
        //AM     if(exec.opcode == RET)
        //AM         mem_exec_src_reg1 = RA;
        //AM     else
        //AM         mem_exec_src_reg1 = exec.rs1;

        //AM     // for rd
        //AM     if(mem.opcode == CALL)
        //AM         mem_exec_dest_reg = RA;
        //AM     else
        //AM     begin
        //AM         $display($time," aa2");
        //AM         mem_exec_dest_reg = mem.rd;
        //AM     end

        //AM     //conflict check for mem1
        //AM     //AM fw.mem_exec_rs1_conflict = (mem_exec_src_reg1!='b0 && mem_exec_dest_reg!='b0) && (mem_exec_src_reg1 == mem_exec_dest_reg) ? 1'b1: 1'b0; 
        //AM     fw.mem_exec_rs1_conflict =  (mem_exec_src_reg1 == mem_exec_dest_reg) ? 1'b1: 1'b0; 

        //AM     if(fw.mem_exec_rs1_conflict)
        //AM     begin
        //AM         $display($time,"forwarding unit: Raising rs1 conflict MA-execute\n");
        //AM         $display($time,"forwarding unit: mem.opcode=%b, exec.opcode=%b\n",mem.opcode, dd.opcode);
        //AM         $display($time, "mem_exec_src_reg1 =%b,mem_exec_dest_reg=%b",mem_exec_src_reg1,mem_exec_dest_reg);
        //AM     end
        //AM end
        //AM else
        //AM begin
        //AM         $display($time," aa3");
        //AM     fw.mem_exec_rs1_conflict = 'b0;
        //AM end

        if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL && exec.opcode != NOT && exec.opcode != MOV)
        begin
            $display($time," aa1");
            if(exec.opcode == RET)
                mem_exec_src_reg1 = RA;
            else
                mem_exec_src_reg1 = exec.rs1;
        end
        if(mem.opcode != LD && mem.opcode != NOP && mem.opcode !=CMP && mem.opcode !=ST && mem.opcode !=B && mem.opcode !=BEQ && mem.opcode !=BGT && mem.opcode !=RET)
        begin
            if(mem.opcode == CALL)
                mem_exec_dest_reg = RA;
            else
            begin
                $display($time," aa2");
                mem_exec_dest_reg = mem.rd;
            end
        end
        
        if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL && exec.opcode != NOT && exec.opcode != MOV && mem.opcode != LD && mem.opcode != NOP && mem.opcode !=CMP && mem.opcode !=ST && mem.opcode !=B && mem.opcode !=BEQ && mem.opcode !=BGT && mem.opcode !=RET)
        begin
            
            fw.mem_exec_rs1_conflict =  (mem_exec_src_reg1 == mem_exec_dest_reg) ? 1'b1: 1'b0; 

            if(fw.mem_exec_rs1_conflict)
            begin
                $display($time,"forwarding unit: Raising rs1 conflict MA-execute\n");
                $display($time,"forwarding unit: mem.opcode=%b, exec.opcode=%b\n",mem.opcode, dd.opcode);
                $display($time, "mem_exec_src_reg1 =%b,mem_exec_dest_reg=%b",mem_exec_src_reg1,mem_exec_dest_reg);
            end
        end
        else
        begin
            $display($time," aa3");
            fw.mem_exec_rs1_conflict = 'b0;
        end







        //for src2 
//AM        if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL)
//AM        begin
//AM            if(exec.opcode == ST)
//AM                mem_exec_src_reg2 = exec.rd;
//AM            else
//AM                mem_exec_src_reg2 = exec.rs2;
//AM
//AM            // Destinaion condition is same for both
//AM
//AM            //AM fw.mem_exec_rs2_conflict = mem.I_bit ==1'b1 ? 1'b0: ((mem_exec_src_reg2!='b0 && mem_exec_dest_reg!='b0) && (mem_exec_src_reg2 == mem_exec_dest_reg) ? 1'b1: 1'b0);
//AM            fw.mem_exec_rs2_conflict = exec.I_bit ==1'b1 ? 1'b0: ((mem_exec_src_reg2 == mem_exec_dest_reg) ? 1'b1: 1'b0);
//AM
//AM            if(fw.mem_exec_rs2_conflict)
//AM            begin
//AM                $display($time,"forwarding unit: Raising rs2 conflict MA-execute\n");
//AM                $display($time,"forwarding unit: mem.opcode=%b, exec.opcode=%b\n",mem.opcode, dd.opcode);
//AM                $display($time, "mem_exec_src_reg2 =%b,mem_exec_dest_reg=%b",mem_exec_src_reg2,mem_exec_dest_reg);
//AM            end
//AM        end
//AM        else
//AM            fw.mem_exec_rs2_conflict = 'b0;
//AM    end
//AM    else
//AM        fw.mem_exec_rs2_conflict = 'b0;

        //for src2 
        if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL)
        begin
            if(exec.opcode == ST)
                mem_exec_src_reg2 = exec.rd;
            else
                mem_exec_src_reg2 = exec.rs2;
        end

            // Destinaion condition is same for both
        //comparing rs2 and rd
            if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL && mem.opcode != LD && mem.opcode != NOP && mem.opcode !=CMP && mem.opcode !=ST && mem.opcode !=B && mem.opcode !=BEQ && mem.opcode !=BGT && mem.opcode !=RET )
            begin
                fw.mem_exec_rs2_conflict = exec.I_bit ==1'b1 ? 1'b0: ((mem_exec_src_reg2 == mem_exec_dest_reg) ? 1'b1: 1'b0);

                if(fw.mem_exec_rs2_conflict)
                begin
                    $display($time,"forwarding unit: Raising rs2 conflict MA-execute\n");
                    $display($time,"forwarding unit: mem.opcode=%b, exec.opcode=%b\n",mem.opcode, dd.opcode);
                    $display($time, "mem_exec_src_reg2 =%b,mem_exec_dest_reg=%b",mem_exec_src_reg2,mem_exec_dest_reg);
                end
            end
            else
                fw.mem_exec_rs2_conflict = 'b0;
     end
     else
         fw.mem_exec_rs2_conflict = 'b0;



end


// Case 3 WB -> execute forwarding 
// B = WB, A = execute (with reference to pseudo code in book)
//
always_comb
begin

    if(wb.valid && exec.valid)
    begin

        // for rs1
//AM         if((exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL && exec.opcode != NOT && exec.opcode != MOV) && (wb.opcode != NOP && wb.opcode !=CMP && wb.opcode !=ST && wb.opcode !=B && wb.opcode !=BEQ && wb.opcode !=BGT && wb.opcode !=RET) )
//AM         begin
//AM             if(exec.opcode == RET)
//AM                 wb_exec_src_reg1 = RA;
//AM             else
//AM                 wb_exec_src_reg1 = exec.rs1;
//AM 
//AM             // for rd
//AM             if(wb.opcode == CALL)
//AM                 wb_exec_dest_reg = RA;
//AM             else
//AM                 wb_exec_dest_reg = wb.rd;
//AM 
//AM             //conflict check for rs1
//AM             //AM fw.wb_exec_rs1_conflict = (wb_exec_src_reg1!='b0 && wb_exec_dest_reg!='b0) && (wb_exec_src_reg1 == wb_exec_dest_reg) ? 1'b1: 1'b0; 
//AM             fw.wb_exec_rs1_conflict = (wb_exec_src_reg1 == wb_exec_dest_reg) ? 1'b1: 1'b0; 
//AM 
//AM             if(fw.wb_exec_rs1_conflict)
//AM             begin
//AM                 $display($time,"forwarding unit: Raising rs1 conflict wb-execute\n");
//AM                 $display($time,"forwarding unit: wb.opcode=%b, exec.opcode=%b\n", wb.opcode, dd.opcode);
//AM                 $display($time, "wb_exec_src_reg1 =%b,wb_exec_dest_reg=%b",wb_exec_src_reg1,wb_exec_dest_reg);
//AM             end
//AM         end
//AM         else
//AM             fw.wb_exec_rs1_conflict ='b0;


        // for rs1
        if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL && exec.opcode != NOT && exec.opcode != MOV)
        begin
            if(exec.opcode == RET)
                wb_exec_src_reg1 = RA;
            else
                wb_exec_src_reg1 = exec.rs1;
        end

        // for rd
        if(wb.opcode != NOP && wb.opcode !=CMP && wb.opcode !=ST && wb.opcode !=B && wb.opcode !=BEQ && wb.opcode !=BGT && wb.opcode !=RET)
        begin
            // for rd
            if(wb.opcode == CALL)
                wb_exec_dest_reg = RA;
            else
                wb_exec_dest_reg = wb.rd;

        end

        //comparing rs1 and rd
        if((exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL && exec.opcode != NOT && exec.opcode != MOV) && (wb.opcode != NOP && wb.opcode !=CMP && wb.opcode !=ST && wb.opcode !=B && wb.opcode !=BEQ && wb.opcode !=BGT && wb.opcode !=RET) )
        begin

            fw.wb_exec_rs1_conflict = (wb_exec_src_reg1 == wb_exec_dest_reg) ? 1'b1: 1'b0; 

            if(fw.wb_exec_rs1_conflict)
            begin
                $display($time,"forwarding unit: Raising rs1 conflict wb-execute\n");
                $display($time,"forwarding unit: wb.opcode=%b, exec.opcode=%b\n", wb.opcode, dd.opcode);
                $display($time, "wb_exec_src_reg1 =%b,wb_exec_dest_reg=%b",wb_exec_src_reg1,wb_exec_dest_reg);
            end

        end
        else
            fw.wb_exec_rs1_conflict ='b0;





//AM        //for src2 
//AM        if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL)
//AM        begin
//AM            if(exec.opcode == ST)
//AM                wb_exec_src_reg2 = exec.rd;
//AM            else
//AM                wb_exec_src_reg2 = exec.rs2;
//AM
//AM            // Destinaion condition is same for both
//AM
//AM            //AM fw.wb_exec_rs2_conflict = wb.I_bit ==1'b1 ? 1'b0: ((wb_exec_src_reg2!='b0 && wb_exec_dest_reg!='b0) &&   (wb_exec_src_reg2 == wb_exec_dest_reg) ? 1'b1: 1'b0);
//AM            fw.wb_exec_rs2_conflict = exec.I_bit ==1'b1 ? 1'b0: ((wb_exec_src_reg2 == wb_exec_dest_reg) ? 1'b1: 1'b0);
//AM
//AM            if(fw.wb_exec_rs2_conflict)
//AM            begin
//AM                $display($time,"forwarding unit: Raising rs2 conflict wb-execute\n");
//AM                $display($time,"forwarding unit: wb.opcode=%b, exec.opcode=%b\n", wb.opcode, dd.opcode);
//AM                $display($time, "wb_exec_src_reg2 =%b,wb_exec_dest_reg=%b",wb_exec_src_reg2,wb_exec_dest_reg);
//AM            end
//AM        end
//AM        else
//AM            fw.wb_exec_rs2_conflict = 'b0;
//AM    end
//AM    else
//AM        fw.wb_exec_rs2_conflict = 'b0;

        //for src2 
        if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL)
        begin
            if(exec.opcode == ST)
                wb_exec_src_reg2 = exec.rd;
            else
                wb_exec_src_reg2 = exec.rs2;
        end

        //comparing rs2 and rd
        if(exec.opcode != NOP && exec.opcode != B && exec.opcode != BEQ && exec.opcode != BGT && exec.opcode != CALL && wb.opcode != NOP && wb.opcode !=CMP && wb.opcode !=ST && wb.opcode !=B && wb.opcode !=BEQ && wb.opcode !=BGT && wb.opcode !=RET)
        begin
            // Destinaion condition is same for both

            fw.wb_exec_rs2_conflict = exec.I_bit ==1'b1 ? 1'b0: ((wb_exec_src_reg2 == wb_exec_dest_reg) ? 1'b1: 1'b0);

            if(fw.wb_exec_rs2_conflict)
            begin
                $display($time,"forwarding unit: Raising rs2 conflict wb-execute\n");
                $display($time,"forwarding unit: wb.opcode=%b, exec.opcode=%b\n", wb.opcode, dd.opcode);
                $display($time, "wb_exec_src_reg2 =%b,wb_exec_dest_reg=%b",wb_exec_src_reg2,wb_exec_dest_reg);
            end
        end
        else
            fw.wb_exec_rs2_conflict = 'b0;
    end
    else
        fw.wb_exec_rs2_conflict = 'b0;


end

// Case 4 WB -> mem forwarding 
// B = WB, A = mem (with reference to pseudo code in book)
//
always_comb
begin

    if(wb.valid && mem.valid)
    begin
        // for rs1
//AM        if((mem.opcode != NOP &&mem.opcode !=  B && mem.opcode != BEQ && mem.opcode != BGT && mem.opcode != CALL && mem.opcode != NOT && mem.opcode != MOV) && (wb.opcode != NOP && wb.opcode != CMP && wb.opcode != ST && wb.opcode != B && wb.opcode != BEQ && wb.opcode != BGT && wb.opcode != RET))
//AM        begin
//AM            if(mem.opcode == RET)
//AM                wb_mem_src_reg1 = RA;
//AM            else
//AM                wb_mem_src_reg1 = mem.rs1;
//AM
//AM            // for rd
//AM
//AM            if(wb.opcode == CALL)
//AM                wb_mem_dest_reg = RA;
//AM            else
//AM                wb_mem_dest_reg = wb.rd;
//AM
//AM            //conflict check for rs1
//AM            fw.wb_mem_rs1_conflict =  (wb_mem_src_reg1 == wb_mem_dest_reg) ? 1'b1: 1'b0; 
//AM
//AM            if(fw.wb_mem_rs1_conflict)
//AM            begin
//AM                $display($time,"forwarding unit: Raising rs1 conflict wb-mem\n");
//AM                $display($time,"forwarding unit: wb.opcode=%b, mem.opcode=%b\n", wb.opcode, exec.opcode);
//AM                $display($time, "wb_mem_src_reg1 =%b,wb_mem_dest_reg=%b",wb_mem_src_reg1,wb_mem_dest_reg);
//AM            end
//AM        end
//AM        else
//AM            fw.wb_mem_rs1_conflict = 'b0;
//


        // for rs1
        if(mem.opcode != NOP &&mem.opcode !=  B && mem.opcode != BEQ && mem.opcode != BGT && mem.opcode != CALL && mem.opcode != NOT && mem.opcode != MOV)
        begin
            if(mem.opcode == RET)
                wb_mem_src_reg1 = RA;
            else
                wb_mem_src_reg1 = mem.rs1;
        end

        //rd
        if(wb.opcode != NOP && wb.opcode != CMP && wb.opcode != ST && wb.opcode != B && wb.opcode != BEQ && wb.opcode != BGT && wb.opcode != RET)
        begin
            // for rd

            if(wb.opcode == CALL)
                wb_mem_dest_reg = RA;
            else
                wb_mem_dest_reg = wb.rd;

        end

        //comapring rs1 and rd
        if((mem.opcode != NOP &&mem.opcode !=  B && mem.opcode != BEQ && mem.opcode != BGT && mem.opcode != CALL && mem.opcode != NOT && mem.opcode != MOV) && (wb.opcode != NOP && wb.opcode != CMP && wb.opcode != ST && wb.opcode != B && wb.opcode != BEQ && wb.opcode != BGT && wb.opcode != RET))
        begin
            
            fw.wb_mem_rs1_conflict =  (wb_mem_src_reg1 == wb_mem_dest_reg) ? 1'b1: 1'b0; 

            if(fw.wb_mem_rs1_conflict)
            begin
                $display($time,"forwarding unit: Raising rs1 conflict wb-mem\n");
                $display($time,"forwarding unit: wb.opcode=%b, mem.opcode=%b\n", wb.opcode, exec.opcode);
                $display($time, "wb_mem_src_reg1 =%b,wb_mem_dest_reg=%b",wb_mem_src_reg1,wb_mem_dest_reg);
            end
        end
        else
            fw.wb_mem_rs1_conflict = 'b0;





//AM        //for src2 // TODO check might not be reqd 
//AM        if(mem.opcode != NOP && mem.opcode != B && mem.opcode != BEQ && mem.opcode != BGT && mem.opcode != CALL)
//AM        begin
//AM            if(mem.opcode == ST)
//AM                wb_mem_src_reg2 = mem.rd;
//AM            else
//AM                wb_mem_src_reg2 = mem.rs2;
//AM
//AM            // Destinaion condition is same for both
//AM
//AM            //AM fw.wb_mem_rs2_conflict = (mem.opcode != ST  && mem.I_bit ==1'b1) ? 1'b0: ((wb_mem_src_reg2!='b0 && wb_mem_dest_reg!='b0) && (wb_mem_src_reg2 == wb_mem_dest_reg) ? 1'b1: 1'b0);
//AM            fw.wb_mem_rs2_conflict = (mem.opcode != ST  && mem.I_bit ==1'b1) ? 1'b0: ( (wb_mem_src_reg2 == wb_mem_dest_reg) ? 1'b1: 1'b0);
//AM
//AM
//AM            if(fw.wb_mem_rs2_conflict)
//AM            begin
//AM                $display($time,"forwarding unit: Raising rs2 conflict wb-mem \n");
//AM                $display($time,"forwarding unit: wb.opcode=%b, mem.opcode=%b\n", wb.opcode, exec.opcode);
//AM                $display($time, "frowarding unit: wb_mem_src_reg2 =%b,wb_mem_dest_reg=%b",wb_mem_src_reg2,wb_mem_dest_reg);
//AM            end
//AM        end
//AM        else
//AM            fw.wb_mem_rs2_conflict = 'b0;
//AM
//AM    end
//AM    else
//AM        fw.wb_mem_rs2_conflict = 'b0;

       
        //for src2 
        if(mem.opcode != NOP && mem.opcode != B && mem.opcode != BEQ && mem.opcode != BGT && mem.opcode != CALL)
        begin
            if(mem.opcode == ST)
                wb_mem_src_reg2 = mem.rd;
            else
                wb_mem_src_reg2 = mem.rs2;
        end

            // Destinaion condition is same for both

            //comapring rs2 and rd
        if(mem.opcode != NOP && mem.opcode != B && mem.opcode != BEQ && mem.opcode != BGT && mem.opcode != CALL && wb.opcode != NOP && wb.opcode != CMP && wb.opcode != ST && wb.opcode != B && wb.opcode != BEQ && wb.opcode != BGT && wb.opcode != RET )
        begin
            
            fw.wb_mem_rs2_conflict = (mem.opcode != ST  && mem.I_bit ==1'b1) ? 1'b0: ( (wb_mem_src_reg2 == wb_mem_dest_reg) ? 1'b1: 1'b0);

            if(fw.wb_mem_rs2_conflict)
            begin
                $display($time,"forwarding unit: Raising rs2 conflict wb-mem \n");
                $display($time,"forwarding unit: wb.opcode=%b, mem.opcode=%b\n", wb.opcode, exec.opcode);
                $display($time, "frowarding unit: wb_mem_src_reg2 =%b,wb_mem_dest_reg=%b",wb_mem_src_reg2,wb_mem_dest_reg);
            end
        end
        else
            fw.wb_mem_rs2_conflict = 'b0;

    end
    else
        fw.wb_mem_rs2_conflict = 'b0;

end


// Case 5 load -use 

always_comb
begin
    if(exec.valid && dd.valid)
    begin
        if(exec.opcode == LD && dd.opcode!=ST) // no need to take care of lad -store depeendence pg 450 been taken care in wb-mem fw
        begin
            ld_use_dest_reg = exec.rd;
            ld_use_src_reg1 = dd.rs1;
            ld_use_src_reg2 = dd.rs2;

            //fw.ld_use_conflict = (ld_use_src_reg1!='b0  && ld_use_src_reg1!='b0  && ld_use_dest_reg!='b0) && (ld_use_src_reg1 == ld_use_dest_reg || ld_use_src_reg2 == ld_use_dest_reg) ? 1'b1: 1'b0;


            if(ld_use_src_reg1!='b0  && ld_use_src_reg1!='b0  && ld_use_dest_reg!='b0)
            begin
                $display($time,"i am here");
                if((ld_use_src_reg1 == ld_use_dest_reg )|| (ld_use_src_reg2 == ld_use_dest_reg))
                begin
                    $display($time,"i am here1");
                    fw.ld_use_conflict = 1'b1;
                end
                else
                    fw.ld_use_conflict = 1'b0;
            end
            else 
            begin
                $display($time,"i am here2");
                fw.ld_use_conflict = 'b0;
            end



            if(fw.ld_use_conflict)
            begin
                $display($time,"forwarding unit: Raising load use conflict \n");
                $display($time, "ld_use_src_reg1=%b,ld_use_dest_reg=%b",ld_use_src_reg1,ld_use_dest_reg);
            end
        end
        else
            fw.ld_use_conflict = 'b0;
    end
    else
        fw.ld_use_conflict = 'b0;
end







endmodule
