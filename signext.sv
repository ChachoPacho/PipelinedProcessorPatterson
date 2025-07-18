module signext (input logic [31:0] a,
					output logic [63:0] y);
	
	always_comb
		begin
			casez(a[31:21])
				11'b111_1100_00?0: y =  64'(signed'(a[20:12])); 
				11'b101_1010_0???: y = 64'(signed'(a[23:5]));
				11'b11?_1001_01??: y = 64'(a[20:5] << (a[22:21] * 16));
				default: y = 64'b0;
			endcase
	end
					
endmodule