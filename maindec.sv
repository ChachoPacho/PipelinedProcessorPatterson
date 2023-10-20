module maindec (input logic [10:0] Op,
					output logic Reg2Loc, MemtoReg,
					RegWrite, MemRead, MemWrite, Branch, ALUSrc,
					output logic [1:0] ALUOp);
	
	logic [8:0] bus = 12'b0;
	assign {/* 1 */
				Reg2Loc, MemtoReg, RegWrite, MemRead, MemWrite, Branch, ALUSrc, // 7
				/* 2 */
				ALUOp // 1
			} = bus;
		
	always_comb
		begin
			casez(Op)
				// R-Format
				11'b110_1011_0000: bus <= 9'b0010_000_10;
				11'b1?0_0101_1000: bus <= 9'b0010_000_10;
				11'b10?_0101_0000: bus <= 9'b0010_000_10;
				// CBZ Format
				11'b101_1010_0???: bus <= 9'b1x00_010_01;
				// LDUR Format
				11'b111_1100_0010: bus <= 9'bx111_001_00;
				// STUR Format
				11'b111_1100_0000: bus <= 9'b1x00_101_00;
				// Set Default
				11'b11?_1001_01??: bus <= 9'b1010_001_01;
				default: bus <= 9'b0;
			endcase
	end
		
endmodule