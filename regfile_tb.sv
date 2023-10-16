module regfile_tb();
	logic clk, we3;
	logic [4:0] ra1, ra2, wa3;
	logic [63:0] wd3, rd1, rd2;
	
	logic [63:0] rexpected = 64'b0;
	
	logic [31:0] testi = 0, errors;    // bookkeeping variables 

	// instantiate device under test
	regfile dut(clk, we3, ra1, ra2, wa3, wd3, rd1, rd2);
  
	// generate clock
	always     // no sensitivity list, so it always executes
		begin
			clk = 1; #5; clk = 0; #5;
		end
 

	// at start of test pulse reset
	initial
		begin
			ra1 = 0;
			ra2 = 1;
			errors = 0;
		end
		
	function void debug(logic [63:0] r1, r2);
		if (rd1 !== r1) begin  
			$display("Error: ra1 = x%d", ra1);
			$display("  outputs = %b (%b expected)", rd1, r1);
			errors += 1;
		end
		else $display("Correct ra1 = x%d with rd1 = %b", ra1, rd1);
		
		if (rd2 !== r2) begin  
			$display("Error: ra2 = x%d", ra2);
			$display("  outputs = %b (%b expected)", rd2, r2);
			errors += 1;
		end
		else $display("Correct ra2 = x%d with rd2 = %b", ra2, rd2);
	endfunction
	 
	
	// check results on falling edge of clk
	always @(negedge clk) begin
		if (testi < 15) begin
			debug(ra1, ra2);
			ra1 += 2;
			ra2 += 2;
		end
		
		else if (testi === 15) begin
			debug(ra1, 64'b0);
		
			if (rd1 !== rexpected) begin
				$display("Error: Should not overwrite ra1 = x%d", ra1);
				$display("  outputs = %b (%b expected)", rd1, rexpected);
				errors += 1;
			end
			else $display("--- Correct NW x%d with %b", ra1, rd1);
		end
		
		else if (testi === 16) begin
			if (rd1 !== wd3) begin
				$display("Error: Should overwirte ra1 = x%d", ra1);
				$display("  outputs = %b (%b expected)", rd1, wd3);
				errors += 1;
			end
			else $display("--- Correct W x%d with %b", ra1, rd1);
		end
		
		else if (testi === 17) begin
			if (rd1 !== 64'b0) begin
				$display("Error: Should not overwirte ra1 = x%d", ra1);
				$display("  outputs = %b (%b expected)", rd1, 64'b0);
				errors += 1;
			end
			else $display("--- Correct NWZ x%d with %b", ra1, rd1);
		end
		
		else begin
			$display("--------- Ended tests with %d errors;", errors);
			$finish;
		end
		
		testi += 1;
	end
		
	// apply test vectors on rising edge of clk
   always @(posedge clk) begin
		if (testi === 15) begin
			rexpected = rd1;
			wa3 = ra1;
			wd3 = 64'd507;
			
			#7; we3 = 1; // testi === 16
		end
		else if (testi === 17) begin
			wa3 = 5'b11111;
			ra1 = 5'b11111;
		end
	end
		
endmodule