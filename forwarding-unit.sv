module forwardingUnit #(parameter N = 5)
				(input logic [N-1:0] exR, wbR, rn, rm,
				input logic exS, wbS,
				output logic [1:0] rnY, rmY);
	/*
	Y:
	00: Register
	01: Execute Register
	10: Writeback Register
	*/
	
	always_comb begin

		if (rn === 31'd31) rnY <= 2'b0;
		else if (exS && exR === rn) rnY <= 2'b01;
		else if (wbS && wbR === rn) rnY <= 2'b10;
		else rnY <= 2'b0;
		
		if (rm === 31'd31) rmY <= 2'b0;
		else if (exS && exR === rm) rmY <= 2'b01;
		else if (wbS && wbR === rm) rmY <= 2'b10;
		else rmY <= 2'b0;

	end

endmodule
