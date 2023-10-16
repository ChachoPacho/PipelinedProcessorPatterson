`define N 64

module flopr_tb();
	logic        clk, reset;	
	
	logic [`N-1:0] d, q, qexpected;
	
	logic [31:0] vectornum, errors;    // bookkeeping variables 
	logic [`N - 1:0] testvectors [0:9] = '{ // array of testvectors
		`N'd1,
		`N'd51,
		`N'd578,
		`N'd781,
		`N'd457,
		
		`N'd5781,
		`N'd15,
		`N'd0,
		`N'd480,
		`N'd484188
	};

	// instantiate device under test
	flopr #(`N) dut(clk, reset, d, q);
  
	// generate clock
	always     // no sensitivity list, so it always executes
		begin
			clk = 1; #5; clk = 0; #5;
		end
 

	// at start of test pulse reset
	initial
		begin
			vectornum = 0; errors = 0;
			d = testvectors[0];
			qexpected = `N'b0;
			reset = 1; #47; reset = 0;
		end
	 
	
	// check results on falling edge of clk
	always @(negedge clk)
		begin
			d = testvectors[vectornum];
			
			if (reset) qexpected = `N'b0;
			else qexpected = d;
		end
		
	// apply test vectors on rising edge of clk
   always @(posedge clk) begin
		#4;

		if (q !== qexpected) begin  
			$display("%d Error: inputs = %d", vectornum, d);
			$display("  outputs = %d (%d expected)", q, qexpected);
			errors += 1;
		end
		
		// increment array index and read next testvector
		vectornum += 1;
		if (testvectors[vectornum] === 'bx) begin 
			$display("%d tests completed with %d errors", 
				 vectornum, errors);
			$stop;
		end
	end
		
endmodule