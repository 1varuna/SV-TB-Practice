`include "pkt_tb_env_pkg.sv"
`include "eth_sw_if.sv"

import pkt_tb_env_pkg::*;

module pkt_tb_top;

	reg clk;
	reg rstN;
	wire [31:0] inDataA;
	wire sopAi;
	wire eopAi;
	wire [31:0] inDataB;
	wire sopBi;
	wire eopBi;
	wire [31:0] outDataA;
	wire sopAo;
	wire eopAo;
	wire [31:0] outDataB;
	wire sopBo;
	wire eopBo;
	wire portAStall;
	wire portBStall;

	// Instantiate DUT
	switch2x2 eth_sw1(
	.clk(clk),
	.rstN(rstN),
	.inDataA(inDataA),
	.sopAi(sopAi),
	.eopAi(eopAi),
	.inDataB(inDataB),
	.sopBi(sopBi),
	.eopBi(eopBi),
	.outDataA(outDataA),
	.sopAo(sopAo),
	.eopAo(eopAo),
	.outDataB(outDataB),
	.sopBo(sopBo),
	.eopBo(eopBo),
	.portAStall(portAStall),
	.portBStall(portBStall)	
	);

	// instantiate the interface
	eth_sw_if eth_sw_if1(
		.clk(clk),
		.rstN(rstN),
		.inDataA(inDataA),
		.sopAi(sopAi),
		.eopAi(eopAi),
		.inDataB(inDataB),
		.sopBi(sopBi),
		.eopBi(eopBi),
		.outDataA(outDataA),
		.sopAo(sopAo),
		.eopAo(eopAo),
		.outDataB(outDataB),
		.sopBo(sopBo),
		.eopBo(eopBo),
		.portAStall(portAStall),
		.portBStall(portBStall)
	);

	// instantiate top level env class
	pkt_tb_env pkt_tb_env;

	always begin
		#5 clk = ~clk;
	end

	initial begin
		rstN=0;
		clk=0;
		$dumpvars(0,pkt_tb_top);
		repeat (5) @(posedge clk);
		rstN = 1;
		// create env object
		pkt_tb_env = new("sample_env",eth_sw_if1);
		$display("Created packet TB Env");

		fork
			begin
				pkt_tb_env.run();
			end
		join_none
	
			
		#10000;
		$finish();
		end
endmodule
