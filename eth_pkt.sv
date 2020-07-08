/* 
* Define packet class with details of packet properties
*/

class eth_pkt;
	parameter PORTA_ADDR = 32'hABCD;
	parameter PORTB_ADDR = 32'h1234;
	rand bit [31:0] src_addr;
	rand bit [31:0] dst_addr;
	rand byte pkt_data[$];	// Generate random number of data bytes. Min:52, as per spec
	bit [31:0] pkt_crc;

	int pkt_size_bytes;
	byte pkt_full[$];

	// Define constraint on addresses: src and dst
	constraint addr_c{
		src_addr inside {32'habcd,32'h1234};
		dst_addr inside {32'habcd,32'h1234};
	}

	// Define constraint on packet data size
	
	constraint pkt_data_c{
		pkt_data.size() >=52;
		pkt_data.size() <=1506;
		pkt_data.size()%4==0;
	}
	

	// Define constraint for small/large/medium packets

	/*	
	constraint pkt_size_c {			// CHECK
		pkt_data.size() dist
		{
			[52:255]:=25,
			[255:1023]:=50,
			[1024:1506]:=25
		};
	}
	*/
	// Add more constraints for data patterns
	
	function void build_custom_random();
	int rand_num;
	rand_num=$urandom_range(0,3);
	case(rand_num)
		0: begin
			src_addr = 32'habcd;
			dst_addr = 32'habcd;
		end
		1: begin
			src_addr = 32'habcd;
			dst_addr = 32'h1234;
		end
		2: begin
			src_addr = 32'h1234;
			dst_addr = 32'h1234;
		end
		3: begin
			src_addr = 32'h1234;
			dst_addr = 32'habcd;
		end
	endcase
	fill_pkt_data();
	post_randomize();
	endfunction	

	function void fill_pkt_data();
		int pkt_data_size;
		//pkt_data_size = $urandom_range(8,24);
		pkt_data_size = $urandom_range(52,1506);

		// make it double word aligned (multiple of 4)
		 pkt_data_size = (pkt_data_size >> 2) << 2;
		for (int i=0;i<pkt_data.size();i++)
		begin
			pkt_data.push_back($urandom());
		end
	endfunction

	function bit[31:0] calc_crc();
		//return ^pkt_data;
		return 32'habcd1234;
	endfunction

	function void post_randomize();		// create a complete packet
		pkt_crc = calc_crc();
		pkt_size_bytes = pkt_data.size()+4+4+4;	// 4B for src_addr, 4B for dst_addr, 4B for crc
		for(int i=0;i<4;i++)
		begin
			pkt_full.push_back(dst_addr >> i*8);	// 0 to 3 bytes DA
		end
		for (int i=0;i<4;i++)
		begin
			pkt_full.push_back(src_addr >> i*8);	// 4-7 bytes SA
		end
		// Push actual data bytes
		for(int i=0;i<pkt_data.size;i++)
		begin
			pkt_full.push_back(pkt_data[i]);
		end
		for(int i=0;i<4;i++)
		begin
			pkt_full.push_back(pkt_crc>>i*8);	// last 4 bytes of CRC
		end
	endfunction

	// return a string that prints all fields
	function string to_string();
		string msg;
		msg = $psprintf("sa=%x da=%x crc=%x",src_addr,dst_addr,pkt_crc);
		return msg;
	endfunction

	function bit compare_pkt(eth_pkt pkt);
		if((this.src_addr==pkt.src_addr) &&
			(this.dst_addr==pkt.dst_addr)&&
			(this.pkt_crc==pkt.pkt_crc) &&
			is_data_match(this.pkt_data,pkt.pkt_data))
		begin
			return 1'b1;
		end
		return 1'b0;
	endfunction

	function bit is_data_match(byte data1[],byte data2[]);
		// define is_data_match
		if(data1.size()!=data2.size())
		begin
			$display("packet sizes don't match");
			return 1'b0;
		end
		else
		begin
		/*	Pseudo logic:
		* check byte wise if bytes match in a for loop
		* */
	       	for(int i=0;i<data1.size();i++)
		begin
			if(data1[i]!=data2[i])
			begin
				return 1'b0;
				break;
			end
		end
		return 1'b1;
		end
		
	endfunction
endclass
