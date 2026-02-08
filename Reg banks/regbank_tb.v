
module regbank_tb;
reg clk,rst,write;
reg [4:0] sr1,sr2,dr;
reg [31:0] wrdata;
wire [31:0] rddata1,rddata2;
integer k;

regbank REG (clk,dr,sr1,sr2,rddata1,rddata2,wrdata,write,rst);

initial clk=0;
always #5 clk=~clk;

initial begin
    $dumpfile ("regfile.vcd");
    $dumpvars (0,regbank_tb);
    #1 rst=1; write=0;
    #5 rst=0;
end


initial
begin
    #7
    for (k=0; k<32; k=k+1)
    begin
        dr = k; wrdata = 10* k; write = 1;
        #10 write = 0;
    end

    #20
    for (k=0; k<32; k=k+2)
    begin
        sr1 = k; sr2 = k+1;
        #5;
        $display ("reg[%2d] = %d, reg[%2d] = %d", sr1, rddata1, sr2, rddata2);
    end

    #2000 $finish;
end
endmodule
