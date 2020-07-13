parameter PORTA_ADDR = 32'hABCD;
parameter PORTB_ADDR = 32'h1234;

module switch2x2(
input clk,		// input clock
input rstN,		// active low reset
input [31:0] inDataA,	// input data at port A
input sopAi,		// port A input pulse indicating start of packet
input eopAi,		// port A input pulse indicating end of packet
input [31:0] inDataB,	// input data at port B
input sopBi,		// port B pulse indicating start of packet
input eopBi,		// port B pulse indicating end of packet
output reg[31:0] outDataA,	// port A output data
output reg sopAo,		// port A output pulse indicating start of packet
output reg eopAo, 		// port A output pulse indicating end of packet
output reg[31:0] outDataB,	// port B output data
output reg sopBo,		// port B output pulse indicating start of packet
output reg eopBo,		// port B output pulse indicating end of packet
output reg portAStall,	// port A stall indication when it cannot accept packets
output reg portBStall	// port B stall indication when it cannot accept packets
);

wire fifo_wr_en[2];		// write enable for ports A and B
wire [33:0] fifo_wr_data[2];	// Write data for ports A and B
wire [33:0] fifo_rddata[2];	// Read Data for ports A and B
wire fifo_empty[2];		// Fifo empty for ports A and B
wire fifo_full[2];		// Fifo Full for ports A and B
reg fifo_rd_en[2];		// Read Enable for ports A and B

fifo #(.FIFO_DEPTH(32),.FIFO_WIDTH(34)) 
	portA_in (			// Port A
	.clk(clk),
	.rstN(rstN),
	.write_en(fifo_wr_en[0]),
	.read_en(fifo_rd_en[0]),
	.data_in(fifo_wr_data[0]),
	.data_out(fifo_rddata[0]),
	.empty(fifo_empty[0]),
	.full(fifo_full[0])
	);

fifo #(.FIFO_DEPTH(32),.FIFO_WIDTH(34)) 
	portB_in (			// Port B
	.clk(clk),
	.rstN(rstN),
	.write_en(fifo_wr_en[1]),
	.read_en(fifo_rd_en[1]),
	.data_in(fifo_wr_data[1]),
	.data_out(fifo_rddata[1]),
	.empty(fifo_empty[1]),
	.full(fifo_full[1])
	);

eth_fsm portA_fsm(
	.clk(clk),
	.rstN(rstN),
	.data_in(inDataA),
	.iSop(sopAi),
	.iEop(eopAi),
	.wr_en(fifo_wr_en[0]),
	.data_out(fifo_wr_data[0])
);

eth_fsm portB_fsm(
	.clk(clk),
	.rstN(rstN),
	.data_in(inDataB),
	.iSop(sopBi),
	.iEop(eopBi),
	.wr_en(fifo_wr_en[1]),
	.data_out(fifo_wr_data[1])
);

reg read_fifo_head[2];	// Flag to indicate the head of next incoming packet
reg read_fifo_data[2];	// Flag to indicate if valid data is available in Fifo
reg port_busy[2];	// Port Busy flag for Port A and B
reg[1:0] dest_port[2];	// Destination port selector for port A and B

// Read both FIFO heads
// Check which is the desired dst port and check if it's busy
// If free: set port busy and keep reading FIFO till EOP and drive data on o/p port
// If busy - stall till busy goes low

always @(posedge clk)
	begin
	if(!rstN) begin		// Active low Reset
	for(int i=0;i<2;i++) begin
	read_fifo_head[i] <= 1'b1;	// Set read pointer to head of packet
	read_fifo_data[i] <= 1'b0;	// No valid data to read
	dest_port[i] <= 'b11;	// invalid
	port_busy[i] = 'b0;	// None of the ports are busy 
	end	// for loop1
	outDataA <= 'x;		// invalid data
	outDataB <= 'x;		// invalid data
	sopAo <= 'b0;
	sopBo <= 'b0;
	eopAo <= 'b0;
	eopBo <= 'b0;
	end 
	else begin		// Initialize SOP and EOP values
	sopAo <= 'b0;
	sopBo <= 'b0;
	eopAo <= 'b0;
	eopBo <= 'b0;
	for(int i = 0; i<2; i++)
	begin
	if (read_fifo_head[i]&&~fifo_empty[i]) begin	// Check: Fifo is not empty when head of new packet is encountered
	fifo_rd_en[i] <= 1'b1;		// Start reading
	read_fifo_head[i] <= 1'b0;	// No longer at the head of the packet
	read_fifo_data[i] <= 1'b1;	// Valid data available
	end	// end if
	else if (read_fifo_data[i] && ~fifo_full[i]) begin 
		if(fifo_rddata[i][32]) begin	// sop
		dest_port[i] = (fifo_rddata[i][31:0]==PORTB_ADDR) ? 'b01: 'b00;
		if(port_busy[dest_port[i]]) begin
		fifo_rd_en[i] <= 1'b0;		// stall until this dest port can accept
		end // end if
		else begin
		fifo_rd_en[i] <= 1'b1;		// enable read
		port_busy[dest_port[i]] <= 1'b1;// set busy - reading packets in progress
		end	// end else
		end	// end if
		else if(fifo_rddata[i][33]) begin	// Check: End of Packet
		fifo_rd_en[i] <= 1'b0;		// Disable read
		read_fifo_data[i] <= 1'b0;	// No data available to read
		read_fifo_head[i] <= 1'b1;	// Flag the head of (next) packet
		port_busy[dest_port[i]] <= 1'b0;	// Disable port busy - read done
		end	// end else-if
		else begin		// If EOP is not yet reached
			fifo_rd_en[i]<=1'b1;
		end	// end else
		if(dest_port[i]==0) begin
		outDataA <= fifo_rddata[i][31:0];
		sopAo <= fifo_rddata[i][32];
		eopAo <= fifo_rddata[i][33];
		end
		if(dest_port[i]==1) begin
		outDataB <= fifo_rddata[i][31:0];
		sopBo <= fifo_rddata[i][32];
		eopBo <= fifo_rddata[i][33];
		end
	end	// end else
	end 	// for loop2
	end 	// else block 
	end	// always

always @(posedge clk)
begin
	if(rstN==0)
	begin
	portAStall <= 0;
	portBStall <= 0;
	end	// end if
	else begin
	portAStall <= fifo_full[0];
	portBStall <= fifo_full[1];
	end	// end else
end	// always

endmodule:switch2x2