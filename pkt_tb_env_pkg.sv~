// package for top level environment class

package pkt_tb_env_pkg;
	`define NUMPORTS 2
	`define PORTA_ADDR 'hABCD
	`define PORTB_ADDR 'h1234

	// include the classes for the packet env components
	// including packet, driver, generator, monitor, checker etc
	`include "eth_pkt.sv"
	`include "eth_pkt_gen.sv"
	`include "eth_pkt_drv.sv"
	`include "eth_pkt_mon.sv"
	`include "eth_pkt_chk.sv"

	// create a top level class
	
	class pkt_tb_env;

		// create a name for the env
		string env_name;

		// declare objects for each of the classes included
		
		eth_pkt_gen_c pkt_gen;
		
		eth_pkt_drv pkt_drv;

		eth_pkt_mon pkt_mon;

		eth_pkt_chk pkt_chk;

		// Gen to driver connection
		mailbox mbx_gen_drv;

		// monitor to checker mailboxes
		mailbox mbx_mon_chk[4];

		virtual interface eth_sw_if rtl_intf;

		// constructor
		function new(string name, virtual interface eth_sw_if rtl_intf);
			this.env_name = name;
			this.rtl_intf = rtl_intf;

			// create a gen and drv mailbox
			mbx_gen_drv = new();
			pkt_gen = new(mbx_gen_drv);
			pkt_drv = new(mbx_gen_drv,rtl_intf);

			// create monitor and mailbox to connect checker and
			// monitor
			for (int i=0; i<4;i++)
			begin
				mbx_mon_chk[i]=new();
				$display("Create a mailbox (%0d) for monitor checker",i);
			end
			pkt_mon = new(mbx_mon_chk,rtl_intf);
			// create a checker instance and pass the 4 mailboxes
			// from which it can get packets
			pkt_chk = new(mbx_mon_chk);
		endfunction

		// main evaluation method
		task run();
			$display("pkt_tb_env::run() called");
			fork
				pkt_gen.run();
				pkt_drv.run();
				pkt_mon.run();
				//pkt_chk.run();
			join
		endtask

	endclass: pkt_tb_env

endpackage: pkt_tb_env_pkg
