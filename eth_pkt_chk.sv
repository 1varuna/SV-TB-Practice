// Ethernet packet checker

//`include "eth_pkt.sv"

//parameter PORTA_ADDR = 32'hABCD;
//parameter PORTB_ADDR = 32'h1234;
class eth_pkt_chk;
	// Using one mailbox per input/output port
	mailbox mbx_in[4];

	// Mailbox 0 - input port A, 1 - input port B
	// Mailbox 2 - output port A, 3 - output port B
	
	eth_pkt exp_pkt_A[$];		// expected packet queue at port A
	eth_pkt exp_pkt_B[$];		// expected packet queue at port B

	// constructor
	function new(mailbox mbx[4]);
		for(int i=0; i<4; i++)
		begin
			this.mbx_in[i] = mbx[i];
		end
	endfunction

	task run;
		$display("pkt_chk::run() called");
		fork
			get_and_process(0);
			get_and_process(1);
			//get_and_process(2);
			get_and_process(3);
		join_none
	endtask

	task get_and_process(int port);
		eth_pkt pkt;
		$display("pkt_chk::get_and_process() \t process_pkt on port=%0d called",port);
		forever begin
			mbx_in[port].get(pkt);
			$display("time=%0t pkt_chk:: got packet on port:%0d packet=%s",$time,port,pkt.to_string());
			if(port<2) begin		// input packets (1 and 2)
				gen_exp_pkt(pkt);
			end
			else begin			// output packets (3 and 4)
				chk_exp_pkt(port,pkt);
			end
		end
	endtask

	function void gen_exp_pkt(eth_pkt pkt);
		if(pkt.dst_addr == PORTA_ADDR) begin
			exp_pkt_A.push_back(pkt);
		end
		else if (pkt.dst_addr == PORTB_ADDR) begin
			exp_pkt_B.push_back(pkt);
		end
		else begin
			$error("Illegal packet received");
		end
	endfunction

	function void chk_exp_pkt(int port, eth_pkt pkt);
		eth_pkt exp;
		if(port==2) begin
			exp = exp_pkt_A.pop_front();
		end
		else if(port==3) begin
			exp = exp_pkt_B.pop_front();
		end
		if(pkt.compare_pkt(exp)) begin
			$display("Packet on port 2 (output A) matches");
		end
		else begin
			$display("Packet on port 3 (output B) matches");
		end
	endfunction

endclass
