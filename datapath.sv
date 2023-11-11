// DATAPATH

module datapath #(parameter N = 64)
					(input logic reset, clk,
					input logic reg2loc,									
					input logic AluSrc,
					input logic [3:0] AluControl,
					input logic	Branch,
					input logic memRead,
					input logic memWrite,
					input logic regWrite,	
					input logic memtoReg,									
					input logic [31:0] IM_readData,
					input logic [N-1:0] DM_readData,
					output logic [N-1:0] IM_addr, DM_addr, DM_writeData,
					output logic DM_writeEnable, DM_readEnable, DWrite_HDU);					
					
	logic PCSrc;
	logic [N-1:0] PCBranch_E, aluResult_E, writeData_E, writeData3; 
	logic [N-1:0] signImm_D, readData1_D, readData2_D;
	logic zero_E;
	logic [95:0] qIF_ID;
	logic [280:0] qID_EX;
	logic [202:0] qEX_MEM;
	logic [134:0] qMEM_WB;
	
	// Hazard Detection Unit Vars
	logic controlSRC_HDU, PCWrite_HDU;
	
	fetch 	#(64) 	FETCH 	(.PCSrc_F(PCSrc),
										.clk(clk),
										.reset(reset),
										.enable(PCWrite_HDU),
										.PCBranch_F(qEX_MEM[197:134]),
										.imem_addr_F(IM_addr));
					
	
	flopre 	#(96)		IF_ID 	(.clk(clk),
										.reset(reset),
										.enable(DWrite_HDU),
										.d({IM_addr, IM_readData}),
										.q(qIF_ID));
										
										
	logic [4:0] ra1_DECODE, ra2_DECODE;

	hazardDetectionUnit HD_UNIT (.rd(qID_EX[4:0]),
											.intr(qIF_ID[31:0]),
											.MemRead(qID_EX[264]),
											.controlSrc(controlSRC_HDU), 
											.DWrite(DWrite_HDU), 
											.PCWrite(PCWrite_HDU));


	decode 	#(64) 	DECODE 	(.regWrite_D(qMEM_WB[134]),
										.reg2loc_D(reg2loc), 
										.clk(clk),
										.writeData3_D(writeData3),
										.instr_D(qIF_ID[31:0]), 
										.signImm_D(signImm_D), 
										.readData1_D(readData1_D),
										.readData2_D(readData2_D),
										.ra1(ra1_DECODE),
										.ra2(ra2_DECODE),
										.wa3_D(qMEM_WB[4:0]));	
							
				
	logic [9:0] DECODE_E_M;

	mux2 #(10) DECODE_FLOP (.d0({
											/*9*/AluSrc, /*8-5*/AluControl, 
											/*4*/Branch, /*3*/memRead, /*2*/memWrite, /*1*/regWrite, /*0*/memtoReg
										}), 
									.d1(5'b0),
									.s(controlSRC_HDU),
									.y(DECODE_E_M));
									
	flopr 	#(281)	ID_EX 	(.clk(clk),
										.reset(reset), 
										.d({/*rm:280-276*/ra2_DECODE, /*rn:275-271*/ra1_DECODE, /*270-261*/DECODE_E_M,
											/*260-197*/qIF_ID[95:32], /*196-133*/signImm_D, /*132-69*/readData1_D, 
											/*68-5*/readData2_D, /*4-0*/qIF_ID[4:0]}),
										.q(qID_EX));

	logic [N-1:0] readData1_E, readData2_E;
	logic [1:0] rnS_FUNIT, rmS_FUNIT;

	forwardingUnit 	F_UNIT 	(.exR(qEX_MEM[4:0]), 
										.wbR(qMEM_WB[4:0]), 
										.rn(qID_EX[275:271]), 
										.rm(qID_EX[280:276]),
										.exS(qEX_MEM[199]), 
										.wbS(qMEM_WB[134]),
										.rnY(rnS_FUNIT), 
										.rmY(rmS_FUNIT));


	forwardingMux #(N)	F_MUX	(.rnSRC(rnS_FUNIT), 
										.rmSRC(rmS_FUNIT),
										.exR(qEX_MEM[132:69]), 
										.wbR(writeData3), 
										.rnD(qID_EX[132:69]), 
										.rmD(qID_EX[68:5]), 
										.rnY(readData1_E), 
										.rmY(readData2_E));


	execute 	#(64) 	EXECUTE 	(.AluSrc(qID_EX[270]),
										.AluControl(qID_EX[269:266]),
										.PC_E(qID_EX[260:197]), 
										.signImm_E(qID_EX[196:133]), 
										.readData1_E(readData1_E), 
										.readData2_E(readData2_E), 
										.PCBranch_E(PCBranch_E), 
										.aluResult_E(aluResult_E), 
										.writeData_E(writeData_E), 
										.zero_E(zero_E));											
										
									
	flopr 	#(203)	EX_MEM 	(.clk(clk),
										.reset(reset), 
										.d({/*202-198*/qID_EX[265:261], PCBranch_E, zero_E, aluResult_E, writeData_E, qID_EX[4:0]}),
										.q(qEX_MEM));
											
										
	memory				MEMORY	(.Branch_M(qEX_MEM[202]), 
										.zero_M(qEX_MEM[133]), 
										.PCSrc_M(PCSrc));
			
	
	// Salida de señales a Data Memory
	assign DM_writeData = qEX_MEM[68:5];
	assign DM_addr = qEX_MEM[132:69];
	
	// Salida de señales de control:
	assign DM_writeEnable = qEX_MEM[200];
	assign DM_readEnable = qEX_MEM[201];
	
	flopr 	#(135)	MEM_WB 	(.clk(clk),
										.reset(reset), 
										.d({/*134-133*/qEX_MEM[199:198], qEX_MEM[132:69],	DM_readData, qEX_MEM[4:0]}),
										.q(qMEM_WB));
		
	
	writeback #(64) 	WRITEBACK (.aluResult_W(qMEM_WB[132:69]), 
										.DM_readData_W(qMEM_WB[68:5]), 
										.memtoReg(qMEM_WB[133]), 
										.writeData3_W(writeData3));		
		
endmodule
