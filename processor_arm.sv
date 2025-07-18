// PIPELINED PROCESSOR

module processor_arm #(parameter N = 64)
							(input logic CLOCK_50, reset,
							output logic [N-1:0] DM_writeData, DM_addr,
							output logic DM_writeEnable,
							input	logic dump);
							
	logic [31:0] q;		
	logic [3:0] AluControl;
	logic reg2loc, regWrite, AluSrc, Branch, memtoReg, memRead, memWrite;
	logic [N-1:0] DM_readData, IM_address;  //DM_addr, DM_writeData
	logic DM_readEnable; //DM_writeEnable
	logic DWrite_HDU;		// Stall
	logic controlHazard;
	logic [10:0] instr;
	
	controller 		c 			(.instr(instr), 
									.AluControl(AluControl), 
									.reg2loc(reg2loc), 
									.regWrite(regWrite), 
									.AluSrc(AluSrc), 
									.Branch(Branch),
									.memtoReg(memtoReg), 
									.memRead(memRead), 
									.memWrite(memWrite));
														
					
	datapath #(64) dp 		(.reset(reset), 
									.clk(CLOCK_50), 
									.reg2loc(reg2loc), 
									.AluSrc(AluSrc), 
									.AluControl(AluControl), 
									.Branch(Branch), 
									.memRead(memRead),
									.memWrite(memWrite), 
									.regWrite(regWrite), 
									.memtoReg(memtoReg), 
									.IM_readData(q), 
									.DM_readData(DM_readData), 
									.IM_addr(IM_address), 
									.DM_addr(DM_addr), 
									.DM_writeData(DM_writeData), 
									.DM_writeEnable(DM_writeEnable), 
									.DM_readEnable(DM_readEnable),
									.DWrite_HDU(DWrite_HDU),
									.controlHazard(controlHazard));				
					
					
	imem 				instrMem (.addr(IM_address[8:2]),
									 .enable(~controlHazard),
									.q(q));
									
	
	dmem 				dataMem 	(.clk(CLOCK_50), 
									.memWrite(DM_writeEnable), 
									.memRead(DM_readEnable), 
									.address(DM_addr[8:3]), 
									.writeData(DM_writeData), 
									.readData(DM_readData), 
									.dump(dump)); 							
		 
							
	logic [10:0] dIF_ID;
	mux2 #(11) IF_FLOP (.d0(q[31:21]), 
								.d1(11'b0),
								.s(controlHazard),
								.y(dIF_ID));
							
	flopre #(11)		IF_ID_TOP(.clk(CLOCK_50),
									.reset(reset), 
									.enable(DWrite_HDU),
									.d(dIF_ID), 
									.q(instr));
 	
endmodule
