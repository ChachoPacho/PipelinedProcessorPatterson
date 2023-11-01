module forwardingMux #(parameter N = 64)
					(input logic [1:0] rnSRC, rmSRC,
					input logic [N-1:0] exR, wbR, rnD, rmD, 
					output logic [N-1:0] rnY, rmY);
	
	always_comb begin
	
		casez(rnSRC)
			2'b0: rnY <= rnD;
			2'b01: rnY <= exR;
			2'b10: rnY <= wbR;
			default: rnY <= rnD;
		endcase
		
		casez(rmSRC)
			2'b0: rmY <= rmD;
			2'b01: rmY <= exR;
			2'b10: rmY <= wbR;
			default: rmY <= rmD;
		endcase
	
	end
	
endmodule
