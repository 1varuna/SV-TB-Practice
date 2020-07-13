module eth_fsm (
	input clk,
	input rstN,
	input [31:0] data_in,
	input iSop,		// Start of packet for input
	input iEop,		// End of packet for input
	output reg wr_en,	// output write enable
	output reg [33:0] data_out	// 32 bit data, 2 bits for Sop and Eop
);

parameter PORTA_ADDR = 32'hABCD;
parameter PORTB_ADDR = 32'h1234;

reg [2:0] nState;	// FSM : next state
reg [2:0] pState;	// FSM : present state

parameter IDLE = 3'b000;
parameter DEST_ADDR_RCVD = 3'b001;
parameter DATA_RCV = 3'b010;
parameter DONE = 3'b011;

reg [31:0] dst_addr;
reg [31:0] src_addr;

reg [33:0] data_word;

reg iSop_d;
reg iEop_d;

reg [31:0] iData_d;

always @(pState,iSop,iEop,data_in)
begin
	nState=IDLE;
	case(pState)
	IDLE: begin
		if(iSop==1)
		begin
		dst_addr=data_in;
		nState = DEST_ADDR_RCVD;
		end
		else begin
		nState = IDLE;
		end
		end
	
	DEST_ADDR_RCVD: begin
		src_addr = data_in;
		nState = DATA_RCV;
		end
	DATA_RCV: begin
		if(iEop) begin
		nState = DONE;
		end
		else begin
		nState = DATA_RCV;
		end
		end
	DONE: begin
		nState = IDLE;
		end
	endcase
end

always @(posedge clk)
	begin
	pState <= nState;;
	iSop_d <= iSop;
	iEop_d <= iEop;
	iData_d <= data_in;
	end

always @ (posedge clk)
	begin
	if(rstN==0)
	begin
	wr_en <= 1'b0;
	end
	else if(pState != IDLE) begin
	wr_en <= 1'b1;
	data_out = {iEop_d,iSop_d,iData_d};
	end
	else begin
	wr_en <= 1'b0;
	end
	end
endmodule
