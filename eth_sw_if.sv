interface eth_sw_if(
input clk,		// input clock
input rstN,		// active low reset
input [31:0] inDataA,	// input data at port A
input sopAi,		// port A input pulse indicating start of packet
input eopAi,		// port A input pulse indicating end of packet
input [31:0] inDataB,	// input data at port B
input sopBi,		// port B pulse indicating start of packet
input eopBi,		// port B pulse indicating end of packet
input[31:0] outDataA,	// port A output data
input sopAo,		// port A output pulse indicating start of packet
input eopAo, 		// port A output pulse indicating end of packet
input [31:0] outDataB,	// port B output data
input sopBo,		// port B output pulse indicating start of packet
input eopBo,		// port B output pulse indicating end of packet
input portAStall,	// port A stall indication when it cannot accept packets
input portBStall	// port B stall indication when it cannot accept packets
);

/* Default Clocking block */

default clocking eth_mon_cb @(posedge clk);
/* Define default input and output clock skews */
default input #2ns output #2ns;
input clk;		// input clock
input rstN;		// active low reset
input inDataA;	// input data at port A
input sopAi;		// port A input pulse indicating start of packet
input eopAi;		// port A input pulse indicating end of packet
input inDataB;	// input data at port B
input sopBi;		// port B pulse indicating start of packet
input eopBi;		// port B pulse indicating end of packet
input outDataA;	// port A output data
input sopAo;		// port A output pulse indicating start of packet
input eopAo; 		// port A output pulse indicating end of packet
input outDataB;	// port B output data
input sopBo;		// port B output pulse indicating start of packet
input eopBo;		// port B output pulse indicating end of packet
input portAStall;	// port A stall indication when it cannot accept packets
input portBStall;	// port B stall indication when it cannot accept packets
endclocking

// Modport for Monitor
modport mon_mp (clocking eth_mon_cb);

// Clocking block for Driver signals
clocking eth_drv_cb @(posedge clk);
default input #2ns output #2ns;
input clk;
input rstN;
output inDataA;
output sopAi;
output eopAi;
output inDataB;
output sopBi;
output eopBi;

endclocking

modport drv_mp(clocking eth_drv_cb);

endinterface:eth_sw_if