module alu_tb();	
	logic [63:0] a, b, result;
	logic zero;
	
	logic [3:0] op, 
		op_and = 4'b0, 
		op_or = 4'b1, 
		op_add = 4'b10, 
		op_sub = 4'b110, 
		op_pass = 4'b111;	
	
	logic [63:0] pos1 = 15, 
		pos2 = 30,
		neg1 = -10,
		neg2 = -5678,
		bigpos1 = {0, {63{1'b1}}};

	logic [31:0] errors = 0, testi = 0;

	// instantiate device under test
	alu dut(a, b, op, zero, result);
	
	function void debug(input logic [63:0] r);
		if (result !== r) begin  
			$display("%d Error: a = %b, b = %b, op = %b", testi, a, b, op);
			$display("  outputs = %b (%b expected)", result, r);
			errors += 1;
		end

		testi += 1;
	endfunction
	
	initial 
		begin
			$display("--- ADD ---");
			op <= op_add;
			a <= pos1;
			b <= pos2;
	
			#5; debug(45);
			
			b <= neg2;
			#5; debug(-5663);
			
			a <= neg1;
			#5; debug(-5688);
			
			a <= bigpos1;
			b <= bigpos1;
			#5;
			$display("OverFlow: a = %b, b = %b", a, b);
			$display("  outputs = %b (%d)", result, $signed(result));
			
			$display("--- ADD completed with %d errors", errors);
			
			$display("--- SUB ---");
			testi <= 0;
			errors <= 0;
			
			op <= op_sub;
			a <= pos1;
			b <= pos2;
			#5; debug(-15);
			
			b <= neg2;
			#5; debug(5693);
			
			a <= neg1;
			#5; debug(5668);
			
			$display("--- SUB completed with %d errors", errors);
			
			$display("--- AND ---");
			testi <= 0;
			errors <= 0;
			
			op <= op_and;
			a <= pos1;
			b <= pos2;
			#5; debug(64'b1110);
			
			b <= neg2;
			#5; debug(64'b10);
			
			a <= neg1;
			#5; debug({{51{1'b1}}, 13'b0_1001_1101_0010});
			
			$display("--- AND completed with %d errors", errors);
						
			$display("--- OR ---");
			testi <= 0;
			errors <= 0;
			
			op <= op_or;
			a <= pos1;
			b <= pos2;
			#5; debug(64'b11111);
			
			b <= neg2;
			#5; debug({{51{1'b1}}, 13'b0_1001_1101_1111});

			a <= neg1;
			#5; debug({{60{1'b1}}, 4'b0110});
			
			$display("--- OR completed with %d errors", errors);
			
			$stop;
		end
		
endmodule