module fetch #(parameter N = 64)
				(input logic PCSrc_F, clk, reset, enable,
				  input logic [N-1:0] PCBranch_F,
					output logic [N-1:0] imem_addr_F);
	
	logic [N-1:0] next_addr, yAdder, dMux;
	
	assign dMux = (enable) ? yAdder : imem_addr_F;

	mux2 #(N) f_mux (.d0(dMux), .d1(PCBranch_F), .s(PCSrc_F), .y(next_addr));
	flopr #(N) f_flopr (.clk(clk), .reset(reset), .d(next_addr), .q(imem_addr_F));
	adder #(N) f_adder (.a(imem_addr_F), .b({{(N-3){1'b0}}, 3'b100}), .y(yAdder));
	
endmodule