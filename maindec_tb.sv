module maindec_tb();	
	logic reg2loc, ALUSrc, MemtoReg,
			RegWrite, MemRead, MemWrite, Branch;
	logic [1:0] ALUOp;
	logic [10:0] op;

	logic [31:0] errors = 0;
	logic flag;

	// instantiate device under test
	maindec dut(op, reg2loc, ALUSrc, MemtoReg,
			RegWrite, MemRead, MemWrite, Branch, ALUOp);
	
	function void debug(input logic [0:8] r);
		flag = 0;
		
		$display("-- Op = %b", op);
		if (reg2loc !== r[0]) begin  
			$display("Error: reg2loc");
			$display("  outputs = %b (%b expected)", reg2loc, r[0]);
			flag = 1;
		end
		
		if (ALUSrc !== r[1]) begin  
			$display("Error: ALUSrc");
			$display("  outputs = %b (%b expected)", ALUSrc, r[1]);
			flag = 1;
		end
		
		if (MemtoReg !== r[2]) begin  
			$display("Error: MemtoReg");
			$display("  outputs = %b (%b expected)", MemtoReg, r[2]);
			flag = 1;
		end
		
		if (RegWrite !== r[3]) begin  
			$display("Error: RegWrite");
			$display("  outputs = %b (%b expected)", RegWrite, r[3]);
			flag = 1;
		end
		
		if (MemRead !== r[4]) begin  
			$display("Error: MemRead");
			$display("  outputs = %b (%b expected)", MemRead, r[4]);
			flag = 1;
		end
		
		if (MemWrite !== r[5]) begin  
			$display("Error: MemWrite");
			$display("  outputs = %b (%b expected)", MemWrite, r[5]);
			flag = 1;
		end
		
		if (Branch !== r[6]) begin  
			$display("Error: Branch");
			$display("  outputs = %b (%b expected)", Branch, r[6]);
			flag = 1;
		end
		
		if (ALUOp !== r[7:8]) begin  
			$display("Error: ALUOp");
			$display("  outputs = %b (%b expected)", ALUOp, r[7:8]);
			flag = 1;
		end
		
		if (flag) errors += 1;
	endfunction
	
	initial 
		begin
			op <= 11'b100_0101_1000; // ADD
			#5; debug(9'b0_0_0_1_0_0_0_10);
			
			op <= 11'b110_0101_1000; // SUB
			#5; debug(9'b0_0_0_1_0_0_0_10);
			
			op <= 11'b100_0101_0000; // AND
			#5; debug(9'b0_0_0_1_0_0_0_10);
			
			op <= 11'b101_0101_0000; // ORR
			#5; debug(9'b0_0_0_1_0_0_0_10);
			
			op <= 11'b101_1010_0111; // CBZ
			#5; debug(9'b1_0_0_0_0_0_1_01);
			
			op <= 11'b111_1100_0010; // LDUR
			#5; debug(9'b0_1_1_1_1_0_0_00);
			
			op <= 11'b111_1100_0000; // STUR
			#5; debug(9'b1_1_0_0_0_1_0_00);
			
			op <= {11{1'b1}}; // DEFAULT
			#5; debug(9'b0);
			
			#5; $display("----- Ended tests with %d errors", errors);
			
			$stop;
		end
		
endmodule