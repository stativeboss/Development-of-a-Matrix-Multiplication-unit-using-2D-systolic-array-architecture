# Development-of-a-Matrix-Multiplication-unit-using-2D-systolic-array-architecture

The verilog design file can be found [here](https://github.com/stativeboss/Development-of-a-Matrix-Multiplication-unit-using-2D-systolic-array-architecture/blob/main/pe.v).

## Top-level block diagram
![image](https://user-images.githubusercontent.com/14873110/178118222-5b429bb1-6f7f-46fb-9bdc-fb3991479c57.png)

## Sub-block level description

### Notation overview

![image](https://user-images.githubusercontent.com/14873110/178118006-c4f37cdf-771a-429a-82b2-d142c513bafe.png)


### Memory A and Memory B

![image](https://user-images.githubusercontent.com/14873110/178118596-6c2fcb2d-68df-47f7-b393-ebab13fad5e9.png)

- Each memory is 64 locations deep.
- Each memory location is 16 byte wide and is written (or read) byte by byte.
- There are four address pointers A, B, C and D that can read (or write) 4 bytes of data simultaneously (1 byte per pointer per cycle). This is how data is fed as input into the systolic array unit.
- Each pointer would stay at a particular address for 17 cycles. This limits the maximum number of rows (and coloumns based on AxB) an input matrix can have to 16.
- The first cycle is used to write 128-bit 0 in all the address locations and each byte would then be overwritten in the subsequent cycles based on address given.

### Memory C

![image](https://user-images.githubusercontent.com/14873110/178119112-2f11acc2-307c-4f66-9288-b2da4443d248.png)

- This memory has 256 address locations.
- Each location is 4 byte wide.
- The outputs of four PEs from one row are concatenated and stored in one address location of this register. This way, only 4 address locations are utilised.
- The data in each address gets overwritten each cycle and the final result is obtained after 17cycles of multiplication start.
 



### Control Logic
1. No matter the matrix size, the multiplication is always 4x16 : 16x4 (buffed up other bytes with 0).
2. Number of cycles taken for this operation is pre-calculated and after these many cycles, a complete flag is raised and this is when the data from mem_C is ready to be read.
3. After receiving data_incoming signal from source, write enable is made high for memories A and B for 17 cycles. The first cycle is used to reset these memories.
4. Data is written into A and B based on the addresses given by source in the next 16 cycles. 
5. After 17 cycles, write enable is disabled and read enable is forced high and the data is read byte by byte. 
6. Therefore writing and reading don't happen simultaneously.
7. read_enable signal for A and B also raises write enable for C. This goes low only as mentioned in step-2.
8. read_enable is high for mem_C for atleast 4 cycles after this.
9. All this while (since the time read enable is raised high for A and B and till step-8 is done), a busy flag is raised and given as input to the source saying that it can't write data.

## Future work
1. Conversion of control logic into verilog code.
2. Checking the design with a proper test-bench.
3. Improvising the speed of the design by taking the input matrices's size into consideration.
