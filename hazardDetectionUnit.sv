module hazardDetectionUnit #(parameter N = 5)
				(input logic [N-1:0] rd,
				input logic [31:0] intr,
				input logic MemRead,
				output logic controlSrc, DWrite, PCWrite);
				
	logic [2:0] bus;
		
	always_comb begin
	
		casez({ MemRead, intr[31:21], rd })
			// R Format
			{ 1'b1, 11'b110_1011_0000, intr[20:16] }: bus <= 3'b100;
			{ 1'b1, 11'b110_1011_0000, intr[9:5] }: bus <= 3'b100;
			
			{ 1'b1, 11'b1?0_0101_1000, intr[20:16] }: bus <= 3'b100;
			{ 1'b1, 11'b1?0_0101_1000, intr[9:5] }: bus <= 3'b100;
			
			{ 1'b1, 11'b10?_0101_0000, intr[20:16] }: bus <= 3'b100;
			{ 1'b1, 11'b10?_0101_0000, intr[9:5] }: bus <= 3'b100;
			// CBZ Format
			{ 1'b1, 11'b101_1010_0???, intr[4:0] } : bus <= 3'b100;
			// LDUR Format
			{ 1'b1, 11'b111_1100_0010, intr[9:5] } : bus <= 3'b100;
			// STUR Format
			{ 1'b1, 11'b111_1100_0010, intr[9:5] } : bus <= 3'b100;
			{ 1'b1, 11'b111_1100_0010, intr[4:0] } : bus <= 3'b100;
			default: bus <= 3'b011;
		endcase

	end
	
	assign {controlSrc, DWrite, PCWrite} = bus;

endmodule
