module signext_tb();	
	logic [31:0] a;
	logic [63:0] y, q;
	
	logic [7:0] b1 = 8'b0111_0111;
	logic [17:0] b2 = 18'b11_0111_0111_0111_0111;
	logic [4:0] rx = 5'b0;

	logic [10:0] ldur = 11'b111_1100_0010, stur = 11'b111_1100_0000;
	logic [7:0] cbz = 8'b101_1010_0;
	
	logic [31:0] errors = 0, testi = 0;

	// instantiate device under test
	signext dut(a, y);
	
	function void debug;
		if (y !== q) begin  
			$display("%d Error: inputs = %b", testi, a);
			$display("  outputs = %b (%b expected)", y, q);
			errors += 1;
		end

		testi += 1;
	endfunction
	
	initial 
		begin
			assign a = { ldur, 1'b0, b1, 2'b0, rx, rx };
			assign q = { {56{1'b0}}, b1 };
	
			#5; debug();
			
			assign a = { ldur, 1'b1, b1, 2'b0, rx, rx };
			assign q = { {56{1'b1}}, b1 };
			#5; debug();
			
			assign a = { stur, 1'b0, b1, 2'b0, rx, rx };
			assign q = { {56{1'b0}}, b1 };
			#5; debug();
			
			assign a = { stur, 1'b1, b1, 2'b0, rx, rx };
			assign q = { {56{1'b1}}, b1 };
			#5; debug();
			
			assign a = { cbz, 1'b0, b2, rx };
			assign q = { {46{1'b0}}, b2 };
			#5; debug();
			
			assign a = { cbz, 1'b1, b2, rx };
			assign q = { {46{1'b1}}, b2 };
			#5; debug();
			
			assign a = {64{1'b1}};
			assign q = 64'b0;
			#5; debug();
			
			$display("%d tests completed with %d errors", testi, errors);
			$stop;
		end
		
endmodule