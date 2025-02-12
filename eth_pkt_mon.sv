//`include "eth_pkt.sv"
class eth_pkt_mon;
	virtual interface eth_sw_if rtl_intf;
	// Use mailboxes to put packets monitored on both inputs
	
	mailbox mbx_out[4];
	/*
	* mbx_out[0] -> packets seeen on input port A
	* mbx_out[1] -> packets seeen on input port B
	* mbx_out[2] -> packets seeen on output port A
	* mbx_out[3] -> packets seeen on output port B
	*/
	
       function new(mailbox mbx[4], virtual interface eth_sw_if rtl_intf);
	       this.mbx_out = mbx;
	       this.rtl_intf = rtl_intf;
       endfunction

       /**
       * Sample signal on a port
       * Create a packet class and print it to mailbox
       */
      task run;
	      fork
		      sample_portA_input_pkt();
		      sample_portA_output_pkt();
		      sample_portB_input_pkt();
		      sample_portB_output_pkt();
	      join
      endtask

      task sample_portA_input_pkt();
	      eth_pkt pkt;
	      int count = 0;
	      forever @(posedge rtl_intf.clk) begin
		      if(rtl_intf.eth_mon_cb.sopAi) begin
			      $display("time=%t, packet_mon:: Seeing SoP on Port A input",$time);
			      pkt=new();
			      count = 1;
			      pkt.dst_addr=rtl_intf.eth_mon_cb.inDataA;
		      end else if(count==1) begin
			      pkt.src_addr = rtl_intf.eth_mon_cb.inDataA;
			      count++;
		      end else if(rtl_intf.eth_mon_cb.eopAi) begin
			      pkt.pkt_crc = rtl_intf.eth_mon_cb.inDataA;
			      $display("time=%0t packet_mon:: Saw packet on Port A input: pkt=%s",$time,pkt.to_string());
			      mbx_out[0].put(pkt);
			      count = 0;
		      end else if(count>0) begin
			      pkt.pkt_data.push_back(rtl_intf.eth_mon_cb.inDataA);
			      count++;
		      end
	      end
      endtask
	
      task sample_portA_output_pkt();
	      eth_pkt pkt;
	      int count = 0;
	      forever @(posedge rtl_intf.clk) begin
		      if(rtl_intf.eth_mon_cb.sopAo) begin
			      $display("time=%t, packet_mon:: Seeing SoP on Port A output",$time);
			      pkt=new();
			      count = 1;
			      pkt.dst_addr=rtl_intf.eth_mon_cb.outDataA;
		      end else if(count==1) begin
			      pkt.src_addr = rtl_intf.eth_mon_cb.outDataA;
			      count++;
		      end else if(rtl_intf.eth_mon_cb.eopAo) begin
			      pkt.pkt_crc = rtl_intf.eth_mon_cb.outDataA;
			      $display("time=%0t packet_mon:: Saw packet on Port A output: pkt=%s",$time,pkt.to_string());
			      mbx_out[2].put(pkt);
			      count = 0;
		      end else if(count>0) begin
			      pkt.pkt_data.push_back(rtl_intf.eth_mon_cb.outDataA);
			      count++;
		      end
	      end
      endtask

      task sample_portB_input_pkt();
	      eth_pkt pkt;
	      int count = 0;
	      forever @(posedge rtl_intf.clk) begin
		      if(rtl_intf.eth_mon_cb.sopBi) begin
			      $display("time=%t, packet_mon:: Seeing SoP on Port B input",$time);
			      pkt=new();
			      count = 1;
			      pkt.dst_addr=rtl_intf.eth_mon_cb.inDataB;
		      end else if(count==1) begin
			      pkt.src_addr = rtl_intf.eth_mon_cb.inDataB;
			      count++;
		      end else if(rtl_intf.eth_mon_cb.eopBi) begin
			      pkt.pkt_crc = rtl_intf.eth_mon_cb.inDataB;
			      $display("time=%0t packet_mon:: Saw packet on Port B input: pkt=%s",$time,pkt.to_string());
			      mbx_out[1].put(pkt);
			      count = 0;
		      end else if(count>0) begin
			      pkt.pkt_data.push_back(rtl_intf.eth_mon_cb.inDataB);
			      count++;
		      end
	      end
      endtask

      task sample_portB_output_pkt();
	      eth_pkt pkt;
	      int count = 0;
	      forever @(posedge rtl_intf.clk) begin
		      if(rtl_intf.eth_mon_cb.sopBo) begin
			      $display("time=%t, packet_mon:: Seeing SoP on Port B output",$time);
			      pkt=new();
			      count = 1;
			      pkt.dst_addr=rtl_intf.eth_mon_cb.outDataB;
		      end else if(count==1) begin
			      pkt.src_addr = rtl_intf.eth_mon_cb.outDataB;
			      count++;
		      end else if(rtl_intf.eth_mon_cb.eopBo) begin
			      pkt.pkt_crc = rtl_intf.eth_mon_cb.outDataB;
			      $display("time=%0t packet_mon:: Saw packet on Port B output: pkt=%s",$time,pkt.to_string());
			      mbx_out[2].put(pkt);
			      count = 0;
		      end else if(count>0) begin
			      pkt.pkt_data.push_back(rtl_intf.eth_mon_cb.outDataB);
			      count++;
		      end
	      end
      endtask
      
endclass
