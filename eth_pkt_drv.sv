//`include "eth_pkt.sv"
//`include "eth_pkt_gen.sv"
typedef eth_pkt;
//typedef eth_pkt_gen_c;

parameter PORTA_ADDR = 32'hABCD;
parameter PORTB_ADDR = 32'h1234;
class eth_pkt_drv;
	// Use virtual interface to point to the same interface
	virtual interface eth_sw_if rtl_intf;

	// use a mailbox to rcv packets from the generator
	mailbox mbx_input;

	function new(mailbox mbx, virtual interface eth_sw_if intf);
		mbx_input = mbx;
		this.rtl_intf = intf;
	endfunction

	task run;
		eth_pkt pkt;
		//$display("INSIDE DRIVER:: Total Num of packets info from generator : %0d",gen_c.num_pkts);
		int count_inc_pkt =0;		// keep count of incoming packets
		forever begin
			mbx_input.get(pkt);
			count_inc_pkt += 1;
			$display("\t PKT DRIVER :: Got packet no. %0d \n \t RECEIVED PKT INFO: %s \n",count_inc_pkt,pkt.to_string());
			// Drive on Port A/B based on SA
			if(pkt.src_addr == PORTA_ADDR) 
				begin
				drv_pkt_portA(pkt);
				end 
			else if(pkt.src_addr == PORTB_ADDR) 
				begin
				drv_pkt_portB(pkt);
				end
			else 
				begin
				$display("Packets SA is neither Port A or Port B, not continuing");
				//$display(" PKT DRIVER :: All packets driven on ports. Ending Simulation... ");
				//$finish();
				end	
			end
	endtask

	task drv_pkt_portA(eth_pkt pkt);
		// Drive signals as per protocol
		int count;
		int numDwords;			// number of data words
		bit [31:0] cur_dword;		// current data word
		count = 0;
		numDwords = pkt.pkt_size_bytes/4;
		$display("\tPKT DRIVER :: drv_pkt_portA: numDwords=%0d\n",numDwords);
		forever @(posedge rtl_intf.clk) begin
			if(!rtl_intf.portAStall) begin
				rtl_intf.eth_drv_cb.sopAi <= 1'b0;
				rtl_intf.eth_drv_cb.eopAi <= 1'b0;
				cur_dword[7:0] = pkt.pkt_full[4*count];
				cur_dword[15:8] = pkt.pkt_full[4*count+1];
				cur_dword[23:16] = pkt.pkt_full[4*count+2];
				cur_dword[31:24] = pkt.pkt_full[4*count+3];
				$display("time=%t pkt_drv::drv_pkt_portA:count=%0d cur_word=%h",$time,count,cur_dword);
				if(count==0) begin
					rtl_intf.eth_drv_cb.sopAi <= 1'b1;
					rtl_intf.eth_drv_cb.inDataA <= cur_dword;
					count = count+1;
				end else if (count==numDwords-1) begin
					rtl_intf.eth_drv_cb.eopAi <= 1'b1;
					rtl_intf.eth_drv_cb.inDataA <= cur_dword;
					count = count+1;
				end else if (count == numDwords) begin
					count = 0;
					break;
				end else begin
					rtl_intf.eth_drv_cb.inDataA <= cur_dword;
					count = count+1;
				end
			end
		end
	endtask

	task drv_pkt_portB(eth_pkt pkt);
		// Drive signals as per protocol
		int count;
		int numDwords;
		bit [31:0] cur_dword;
		count = 0;
		numDwords = pkt.pkt_size_bytes/4;
		$display("pkt_drv::drv_pkt_portA: numDwords=%0d ",numDwords);
		forever @(posedge rtl_intf.clk) begin
			if(!rtl_intf.portAStall) begin
				rtl_intf.eth_drv_cb.sopBi <= 1'b0;
				rtl_intf.eth_drv_cb.eopBi <= 1'b0;
				cur_dword[7:0] = pkt.pkt_full[4*count];
				cur_dword[15:8] = pkt.pkt_full[4*count+1];
				cur_dword[23:16] = pkt.pkt_full[4*count+2];
				cur_dword[31:24] = pkt.pkt_full[4*count+3];
				$display("time=%t pkt_drv::drv_pkt_portB:count=%0d cur_word=%h",$time,count,cur_dword);
				if(count==0) begin
					rtl_intf.eth_drv_cb.sopBi <= 1'b1;
					rtl_intf.eth_drv_cb.inDataB <= cur_dword;
					count = count+1;
				end else if (count==numDwords-1) begin
					rtl_intf.eth_drv_cb.eopBi <= 1'b1;
					rtl_intf.eth_drv_cb.inDataB <= cur_dword;
					count = count+1;
				end else if (count == numDwords) begin
					count = 0;
					break;
				end else begin
					rtl_intf.eth_drv_cb.inDataB <= cur_dword;
					count = count+1;
				end
			end
		end
	endtask
endclass
