compile:
	vlog riscv_params_pkg.sv fetch_unit.sv forwarding_unit.sv control_unit.sv decode_unit.sv register_access.sv execute_unit.sv memory_access_unit.sv register_wb.sv tb_fdem_wb_unit.sv

sim: 
	vsim work.tb_fd_execute_unit -novopt; do wave.do; run -a
