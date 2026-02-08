module regbank(clk,dr,sr1,sr2,rddata1,rddata2,wrdata,write,rst);
input clk,rst,write;
input [4:0] sr1,sr2,dr;
input [31:0] wrdata;
output [31:0] rddata1,rddata2;
integer k;

reg [31:0] regfile [31:0];

assign rddata1=regfile[sr1];
assign rddata2=regfile[sr2];

always @(posedge clk) begin
    if(rst) begin
        for ( k=0 ;k<32 ;k++ ) begin
            regfile[k]<=0;
            
        end
    end
    else 
    begin
        if (write) begin
            regfile[dr]<=wrdata;
            
        end
    end
    
end



endmodule