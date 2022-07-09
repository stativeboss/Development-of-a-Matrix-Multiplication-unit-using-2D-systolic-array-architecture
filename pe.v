//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//This module is the building block (pe) for 2D systolic array for matrix multiplication
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module pe(tb_in, lr_in, clk, rst, tb_out, lr_out, pe_out);
input [7:0] lr_in, tb_in;//left to right and top to bottom inputs
input clk, rst;
output reg [7:0] lr_out, tb_out;//left to right and top to bottom outputs
output reg [31:0] pe_out;//pe's output
wire [15:0] product;//of inputs
always @(posedge rst or posedge clk) 
begin
	if(rst) begin
		pe_out <= 0;
		lr_out <= 0;
		tb_out <= 0;
	end
	else begin
		pe_out <= pe_out + {16'b0, product};//adder followed by a FF
		lr_out <= lr_in;
		tb_out <= tb_in;
	end
end
assign product = lr_in*tb_in;
endmodule


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//The 4x4 array
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

module fxf_array( tb_in0, tb_in1, tb_in2, tb_in3, lr_in0, lr_in4, lr_in8, lr_in12, clk, rst);
	
input [7:0] lr_in0, lr_in4, lr_in8, lr_in12, tb_in0, tb_in1, tb_in2, tb_in3;
input clk, rst;

wire [7:0] tb_in0, tb_in1, tb_in2, tb_in3;
wire [7:0] lr_in0, lr_in4, lr_in8, lr_in12;
wire [7:0] tb_out0, tb_out1, tb_out2, tb_out3, tb_out4, tb_out5, tb_out6, tb_out7, tb_out8, tb_out9, tb_out10, tb_out11, tb_out12, tb_out13, tb_out14, tb_out15;
wire [7:0] lr_out0, lr_out1, lr_out2, lr_out3, lr_out4, lr_out5, lr_out6, lr_out7, lr_out8, lr_out9, lr_out10, lr_out11, lr_out12, lr_out13, lr_out14, lr_out15;
wire [31:0] c0, c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15;

//1st row 1st element which takes memory inputs from LR and TB
pe pe0 (tb_in0, lr_in0, clk, rst, tb_out0, lr_out0, c0);

//1st row other elements that take inputs TB from memory_B
pe pe1 (tb_in1, lr_out0, clk, rst, tb_out1, lr_out1, c1);
pe pe2 (tb_in2, lr_out1, clk, rst, tb_out2, lr_out2, c2);
pe pe3 (tb_in3, lr_out2, clk, rst, tb_out3, lr_out3, c3);
	
//1st coloumn other elements that take inputs LR from memory_A
pe pe4 (tb_out0, lr_in4, clk, rst, tb_out4, lr_out4, c4);
pe pe8 (tb_out4, lr_in8, clk, rst, tb_out8, lr_out8, c8);
pe pe12 (tb_out8, lr_in12, clk, rst, tb_out12, lr_out12, c12);

//2nd row other elements
pe pe5 (tb_out1, lr_out4, clk, rst, tb_out5, lr_out5, c5);
pe pe6 (tb_out2, lr_out5, clk, rst, tb_out6, lr_out6, c6);
pe pe7 (tb_out3, lr_out6, clk, rst, tb_out7, lr_out7, c7);

//3rd row other elements
pe pe9 (tb_out5, lr_out8, clk, rst, tb_out9, lr_out9, c9);
pe pe10 (tb_out6, lr_out9, clk, rst, tb_out10, lr_out10, c10);
pe pe11 (tb_out7, lr_out10, clk, rst, tb_out11, lr_out11, c11);

//4th row other elements
pe pe13 (tb_out9, lr_out12, clk, rst, tb_out13, lr_out13, c13);
pe pe14 (tb_out10, lr_out13, clk, rst, tb_out14, lr_out14, c14);
pe pe15 (tb_out11, lr_out14, clk, rst, tb_out15, lr_out15, c15);		      
endmodule

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//The three memory modules
//for Memory_A and Memory_B, each address can hold 16 bytes of data and each memory unit has 64 addresses 
//for Memory_C, each address can hold 32 bytes of data and each memory unit has 32 addresses
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////
//First memory block: Memory_A
///////////////////////
module mem_A

#(

//--------------------------------------------------------------------------

parameter   NUM_COL_a             =  16,
parameter   COL_WIDTH_a           =   8,
parameter   ADDR_WIDTH_a          =   6,
// Addr  Width in bits : 2**ADDR_WIDTH = RAM Depth
parameter   DATA_WIDTH_a      =  NUM_COL_a*COL_WIDTH_a  // Data  Width in bits

   //----------------------------------------------------------------------

 )

(input clk, rst,
input wr_enA,
input rd_enA,
input [ADDR_WIDTH_a-1:0] addrA_a,
input [COL_WIDTH_a-1:0] dinA_a,
output reg [COL_WIDTH_a-1:0] lr_in0,
input [ADDR_WIDTH_a-1:0] addrB_a,
input [COL_WIDTH_a-1:0] dinB_a,
output reg [COL_WIDTH_a-1:0] lr_in4,
input [ADDR_WIDTH_a-1:0] addrC_a,
input [COL_WIDTH_a-1:0] dinC_a,
output reg [COL_WIDTH_a-1:0] lr_in8,
input [ADDR_WIDTH_a-1:0] addrD_a,
input [COL_WIDTH_a-1:0] dinD_a,
output reg [COL_WIDTH_a-1:0] lr_in12);

// Core Memory  
reg [DATA_WIDTH_a-1:0]   ram_block_a [(2**ADDR_WIDTH_a)-1:0];
integer                i,j,k,l;

// Port-A Operation

always @ (posedge clk) begin
	if(wr_enA) begin
		if (rst) begin
			for(i=0;i<(2**ADDR_WIDTH_a);i=i+1) begin
		
               ram_block_a[i] <= 128'b0;
			end
		end
		else begin
			for(i=0;i<NUM_COL_a;i=i+1) begin
		
               ram_block_a[addrA_a][i*COL_WIDTH_a +: COL_WIDTH_a] <= dinA_a;
			end
		end
	end
	else if (rd_enA) begin
		for (i=0; i<NUM_COL_a; i=i+1)begin
		
         lr_in0 <= ram_block_a[addrA_a][i*COL_WIDTH_a +: COL_WIDTH_a];  
		end
    end
end

 

// Port-B Operation:

always @ (posedge clk) begin
	if(wr_enA) begin
		if(rst) begin
			for(j=0;j<(2**ADDR_WIDTH_a);j=j+1) begin
		
               ram_block_a[j] <= 128'b0;
			end
		end
		else begin
			for(j=1;j<NUM_COL_a;j=j+1) begin
		
			   ram_block_a[addrB_a][0 +: COL_WIDTH_a] <= 8'b0;
               ram_block_a[addrB_a][j*COL_WIDTH_a +: COL_WIDTH_a] <= dinB_a;
			end
		end
	end	 
	else if(rd_enA) begin
		for(j=0;j<NUM_COL_a;j=j+1) begin
		
				lr_in4 <= ram_block_a[addrB_a][j*COL_WIDTH_a +: COL_WIDTH_a];
				
		end
    end
end


// Port-C Operation

always @ (posedge clk) begin
	if(wr_enA) begin
		if(rst) begin
			for(k=0;k<(2**ADDR_WIDTH_a);k=k+1) begin
		
               ram_block_a[k] <= 128'b0;
			end
		end
		else begin
			for(k=2;k<NUM_COL_a;k=k+1) begin
		
			   ram_block_a[addrC_a][0 +: COL_WIDTH_a] <= 8'b0;
			   ram_block_a[addrC_a][COL_WIDTH_a +: COL_WIDTH_a] <= 8'b0;
               ram_block_a[addrC_a][k*COL_WIDTH_a +: COL_WIDTH_a] <= dinC_a;
			end
		end
	end	 
	else if(rd_enA) begin
		for(k=0;k<NUM_COL_a;k=k+1) begin
		
				lr_in8 <= ram_block_a[addrC_a][k*COL_WIDTH_a +: COL_WIDTH_a];
				
		end
    end
end

// Port-D Operation

always @ (posedge clk) begin
	if(wr_enA) begin
		if(rst) begin
			for(l=0;l<(2**ADDR_WIDTH_a);l=l+1) begin
		
               ram_block_a[l] <= 128'b0;
			end
		end
		else begin
			for(l=3;l<NUM_COL_a;l=l+1) begin
		
			   ram_block_a[addrD_a][0 +: COL_WIDTH_a] <= 8'b0;
			   ram_block_a[addrD_a][COL_WIDTH_a +: COL_WIDTH_a] <= 8'b0;
			   ram_block_a[addrD_a][2*COL_WIDTH_a +: COL_WIDTH_a] <= 8'b0;
               ram_block_a[addrD_a][l*COL_WIDTH_a +: COL_WIDTH_a] <= dinD_a;
			end
		end
	end	 
	else if(rd_enA) begin
		for(l=0;l<NUM_COL_a;l=l+1) begin
		
				lr_in12 <= ram_block_a[addrD_a][l*COL_WIDTH_a +: COL_WIDTH_a];
				
		end
    end
end

endmodule

//////////////////////
//Second memory block: Memory_B
//////////////////////

module mem_B

#(

//--------------------------------------------------------------------------

parameter   NUM_COL_b             =  16,
parameter   COL_WIDTH_b           =   8,
parameter   ADDR_WIDTH_b          =   6,
// Addr  Width in bits : 2**ADDR_WIDTH = RAM Depth
parameter   DATA_WIDTH_b      =  NUM_COL_b*COL_WIDTH_b  // Data  Width in bits

   //----------------------------------------------------------------------

 )

(input clk, rst,
input wr_enB,
input rd_enB,
input [ADDR_WIDTH_b-1:0] addrA_b,
input [COL_WIDTH_b-1:0] dinA_b,
output reg [COL_WIDTH_b-1:0] tb_in0,
input [ADDR_WIDTH_b-1:0] addrB_b,
input [COL_WIDTH_b-1:0] dinB_b,
output reg [COL_WIDTH_b-1:0] tb_in1,
input [ADDR_WIDTH_b-1:0] addrC_b,
input [COL_WIDTH_b-1:0] dinC_b,
output reg [COL_WIDTH_b-1:0] tb_in2,
input [ADDR_WIDTH_b-1:0] addrD_b,
input [COL_WIDTH_b-1:0] dinD_b,
output reg [COL_WIDTH_b-1:0] tb_in3);

// Core Memory  
reg [DATA_WIDTH_b-1:0]   ram_block_b [(2**ADDR_WIDTH_b)-1:0];
integer                p,q,r,s;

// Port-A Operation

always @ (posedge clk) begin
	if(wr_enB) begin
		if(rst) begin
			for(p=0;p<(2**ADDR_WIDTH_b);p=p+1) begin
		
               ram_block_b[p] <= 128'b0;
			end
		end
		else begin
			for(p=0;p<NUM_COL_b;p=p+1) begin
		
               ram_block_b[addrA_b][p*COL_WIDTH_b +: COL_WIDTH_b] <= dinA_b;
			end
        end
	end
	else if (rd_enB) begin
		for (p=0; p<NUM_COL_b; p=p+1)begin
		
         tb_in0 <= ram_block_b[addrA_b][p*COL_WIDTH_b +: COL_WIDTH_b];  
		end
    end
end

 

// Port-B Operation:

always @ (posedge clk) begin
	if(wr_enB) begin
		if(rst) begin
			for(q=0;q<(2**ADDR_WIDTH_b);q=q+1) begin
		
               ram_block_b[q] <= 128'b0;
			end
		end
		else begin
			for(q=1;q<NUM_COL_b;q=q+1) begin
		
			   ram_block_b[addrB_b][0 +: COL_WIDTH_b] <= 8'b0;
               ram_block_b[addrB_b][q*COL_WIDTH_b +: COL_WIDTH_b] <= dinB_b;
			end
		end
	end	 
	else if(rd_enB) begin
		for(q=0;q<NUM_COL_b;q=q+1) begin
		
				tb_in1 <= ram_block_b[addrB_b][q*COL_WIDTH_b +: COL_WIDTH_b];
				
		end
    end
end


// Port-C Operation

always @ (posedge clk) begin
	if(wr_enB) begin
		if(rst) begin
			for(r=0;r<(2**ADDR_WIDTH_b);r=r+1) begin
		
               ram_block_b[r] <= 128'b0;
			end
		end
		else begin
			for(r=2;r<NUM_COL_b;r=r+1) begin
		
			   ram_block_b[addrC_b][0 +: COL_WIDTH_b] <= 8'b0;
			   ram_block_b[addrC_b][COL_WIDTH_b +: COL_WIDTH_b] <= 8'b0;
               ram_block_b[addrC_b][r*COL_WIDTH_b +: COL_WIDTH_b] <= dinC_b;
			end
		end
	end	 
	else if(rd_enB) begin
		for(r=0;r<NUM_COL_b;r=r+1) begin
		
				tb_in2 <= ram_block_b[addrC_b][s*COL_WIDTH_b +: COL_WIDTH_b];
				
		end
    end
end

// Port-D Operation

always @ (posedge clk) begin
	if(wr_enB) begin
		if(rst) begin
			for(s=0;s<(2**ADDR_WIDTH_b);s=s+1) begin
		
               ram_block_b[s] <= 128'b0;
			end
		end
		else begin
			for(s=3;s<NUM_COL_b;s=s+1) begin
		
			   ram_block_b[addrD_b][0 +: COL_WIDTH_b] <= 8'b0;
			   ram_block_b[addrD_b][COL_WIDTH_b +: COL_WIDTH_b] <= 8'b0;
			   ram_block_b[addrD_b][2*COL_WIDTH_b +: COL_WIDTH_b] <= 8'b0;
               ram_block_b[addrD_b][s*COL_WIDTH_b +: COL_WIDTH_b] <= dinD_b;
			end
		end
	end	 
	else if(rd_enB) begin
		for(s=0;s<NUM_COL_b;s=s+1) begin
		
				tb_in3 <= ram_block_b[addrD_b][s*COL_WIDTH_b +: COL_WIDTH_b];
				
		end
    end
end

endmodule

///////////////
//Third Memory Block: Memory_C
//////////////

module mem_C

#(

//--------------------------------------------------------------------------

parameter   NUM_COL_c             =   4,
parameter   COL_WIDTH_c           =   8,
parameter   ADDR_WIDTH_c          =   8,
parameter   DEPTH_c               =  2**ADDR_WIDTH_c, // Addr  Width in bits : 2**ADDR_WIDTH = RAM Depth
parameter   DATA_WIDTH_c          =  NUM_COL_c*COL_WIDTH_c  // Data  Width in bits

   //----------------------------------------------------------------------

 )

(input clk, rst,
input wr_enC,
input rd_enC,
input [31:0] c0,c1, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15,
output reg [31:0] row_1out, row_2out, row_3out, row_4out);

// Core Memory  
reg [DATA_WIDTH_c-1:0]   ram_block_c [DEPTH_c-1:0];
integer                w;

// Port Operation

always @ (posedge clk) begin
	if(wr_enC) begin
		if(rst) begin
			for(w=0; w< DEPTH_c-1;w=w+1)begin
				ram_block_c[w]<= 32'b0;
			end
		end
		else begin
			ram_block_c[0]<={c0, c1, c2, c3};
			ram_block_c[1]<={c4, c5, c6, c7};
			ram_block_c[2]<={c8, c9, c10, c11};
			ram_block_c[3]<={c12, c13, c14, c15};
        end
	end
	else if (rd_enC) begin
			row_1out<= ram_block_c[0];
			row_2out<= ram_block_c[1];
			row_3out<= ram_block_c[2];
			row_4out<= ram_block_c[3];
		end
end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////
//The control logic
/////////////////////////////////////////////////////////////////////////////////////////////
//1. No matter the matrix size, the multiplication is always 4x16 : 16x4 (buffed up other bytes with 0).
//2. Number of cycles taken for this operation is pre-calculated and after these many cycles, a complete flag is raised and this is when the data from mem_C is ready to be read.
//3. After receiving data_incoming signal from source, write enable is made high for memories A and B for 17 cycles. The first cycle is used to reset these memories.
//4. Data is written into A and B based on the addresses given by source in the next 16 cycles. 
//5. After 17 cycles, write enable is disabled and read enable is forced high and the data is read byte by byte. 
//6. Therefore writing and reading don't happen simultaneously.
//7. read_enable signal for A and B also raises write enable for C. This goes low only as mentioned in step-2.
//8. read_enable is high for mem_C for atleast 4 cycles after this.
//9. All this while (since the time read enable is raised high for A and B and till step-8 is done), a busy flag is raised and given as input to the source saying that it 
//	 can't write data.
/////////////////////////////////////////////////////////////////////////////////////////////





