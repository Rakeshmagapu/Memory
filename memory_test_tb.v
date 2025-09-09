`include "memory.v"
module tb;
	parameter WIDTH=8;
	parameter DEPTH=32;
	parameter ADDR_WIDTH=$clog2(DEPTH);
	reg clk,rst,wr_rd,valid;
	reg [ADDR_WIDTH-1:0] addr;
	reg [WIDTH-1:0] wdata;
	wire [WIDTH-1:0] rdata;
	wire ready;
	integer i;
	reg [20*8-1:0] test_name;
	memory #(.WIDTH(WIDTH),.DEPTH(DEPTH),.ADDR_WIDTH(ADDR_WIDTH)) dut(clk,rst,addr,wr_rd,wdata,valid,rdata,ready);
	always #5 clk=~clk;
	initial begin
		$value$plusargs("test_name=%0s",test_name);// string is very important
		//reset mode
		clk=0;
		rst=1;
		addr=0;
		wr_rd=0;
		wdata=0;
		valid=0;
		repeat(2) @(posedge clk);
		rst=0;
		case(test_name)
			"1wr_1rd":begin
					  	write(15,1);
						read(15,1);
					  end
			"5wr_5rd":begin
					  	write(20,5);
						read(20,5);
					  end
			"fd_wr_fd_rd":begin
						  	write(0,DEPTH);
							read(0,DEPTH);
						  end
			"bd_wr_bd_rd":begin
						  	b_write();
							b_read();
						  end
			"fd_wr_bd_rd":begin
					  	  	write(0,DEPTH);
							b_read();
						  end
			"bd_wr_fd_rd":begin
						  	b_write();
							read(0,DEPTH);
						  end
			"1st_quator_wr_rd":begin
								write(0,DEPTH/4);
								read(0,DEPTH/4);
							   end
			"2nd_quator_wr_rd":begin
							   	write(DEPTH/4,DEPTH/4);
							   	read(DEPTH/4,DEPTH/4);
							   end
			"3rd_quator_wr_rd":begin
							   	write(DEPTH/2,DEPTH/4);
							   	read(DEPTH/2,DEPTH/4);
							   end
			"4th_quator_wr_rd":begin
							   	write((3*DEPTH)/4,DEPTH/4);
							   	read((3*DEPTH)/4,DEPTH/4);
							   end
			"consecutive":begin
							for(i=0;i<DEPTH;i=i+1)begin
								consecutive(i);
							end
						  end
		endcase		
		#100;
		$finish;
	end
	task write(input reg [ADDR_WIDTH-1:0] start_loc, input reg [ADDR_WIDTH:0] num_writes);
	begin
		for(i=start_loc;i<(start_loc+num_writes);i=i+1)begin
			@(posedge clk);
			wr_rd=1;
			addr=i;
			wdata=$random;
			valid=1;
			wait(ready==1);
		end
		//deinitialization after write	
		@(posedge clk);
		wr_rd=0;
		addr=0;
		wdata=0;
		valid=0;
	end
	endtask

	task read(input reg [ADDR_WIDTH-1:0] start_loc, input reg [ADDR_WIDTH:0] num_reads);
	begin
		for(i=start_loc;i<(start_loc+num_reads);i=i+1)begin
			@(posedge clk);
			wr_rd=0;
			addr=i;
			valid=1;
			wait(ready==1);
		end
		//deinitialization after read
		@(posedge clk);
		wr_rd=0;
		addr=0;
		valid=0;
	end
	endtask

	task b_write();
		$readmemh("input.hex",dut.mem);
	endtask

	task b_read();
		$writememh("output.hex",dut.mem);
	endtask

	task consecutive(input reg [ADDR_WIDTH-1:0] loc);
	begin
		@(posedge clk);
		wr_rd=1;
		addr=loc;
		wdata=$random;
		valid=1;
		wait(ready==1);

		@(posedge clk);
		wr_rd=0;
		addr=loc;
		valid=1;
		wait(ready==1);
	end
	endtask
endmodule
