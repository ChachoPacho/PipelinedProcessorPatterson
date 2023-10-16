module fetch_tb();
	logic        clk, reset, PCSrc_F;	
	logic [63:0] PCbrach_F, pc, imem_addr_F;
	
	logic [31:0] errors, testi;    // bookkeeping variables 

	// instantiate device under test
	fetch dut(PCSrc_F, clk, reset, PCbrach_F, imem_addr_F);
  
	// generate clock
	always     // no sensitivity list, so it always executes
		begin
			clk = 1; #5; clk = 0; #5;
		end
		
	function void debug(input logic [63:0] r);
		if (imem_addr_F !== r) begin  
			$display("%d Error: INIT = %b", testi, PCbrach_F);
			$display("  PC = %b (%b expected)", r, imem_addr_F);
			errors += 1;
		end
		
		testi += 1;
	endfunction
 

	// at start of test pulse reset
	initial
		begin
			errors = 0;
			testi = 0;
			PCSrc_F = 0;
			PCbrach_F = 64'd457515;
			pc = 64'b0;
			reset = 1; #50; reset = 0;
		end
	 
	
	// check results on falling edge of clk
	always @(posedge clk) begin
		if (~reset) begin
			debug(pc);
			
			PCSrc_F = 0;
			pc += 4;

			if (testi === 2) PCSrc_F = 1;
			if (testi === 3) pc = PCbrach_F;
		end
		
		if (testi === 6) begin
			$display("----- Ended tests with %d errors", errors);
			$stop;
		end
	end
		
endmodule