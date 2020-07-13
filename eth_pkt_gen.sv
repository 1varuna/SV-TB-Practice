//`include "eth_pkt.sv"
//typedef eth_pkt;

class eth_pkt_gen_c;
	int num_pkts;	// Number of packets to be generated
	
	mailbox mbx_out;

	function new(mailbox mbx);
		mbx_out = mbx;
	endfunction

	task run;
		eth_pkt pkt;
		int count=0;
		num_pkts = $urandom_range(2,50);
		//$display("\t INSIDE PKT_GENERATOR :: Number of packets to be generated are: %d\n",num_pkts);
		for (int i=0;i<num_pkts;i++)
		begin
			// create a new packet, randomize and put to mailbox
			pkt = new();
			count=count+1;
			$display("\tPKT GENERATOR :: New packet created... pkt no. %0d out of %0d packets \n",count,num_pkts);
			`ifndef NO_RANDOMIZE
				pkt.build_custom_random();
				$display("\tPKT INFO: %s\n",pkt.to_string());
			`else
				assert(pkt.randomize());
				$display("\tPKT INFO: %s\n",pkt.to_string());
			`endif
				mbx_out.put(pkt);
		end
	endtask

endclass

