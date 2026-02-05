module mul_datapath(lda, ldb, clrp, decb, ldp, datain, clk, eqz);
input lda, ldb, clrp, decb, ldp, clk;
input [15:0] datain;
output eqz;

wire [15:0] X, Y, Z, BO;

PIPO1 A(clk, lda, datain, X);
PIPO2 P(clk, ldp, Z, Y, clrp);
PIPO3 B(clk, ldb, datain, BO, decb);
adder  N(Z, X, Y);
ezero  E(BO, eqz);

endmodule


module PIPO1(clk,ld,din,dout);
input clk,ld;
input [15:0] din;
output reg [15:0] dout;
  
  initial dout = 0; 

always @(posedge clk)
begin
    if(ld)
    dout<=din;
end

endmodule

module adder(out,a,b);
input [15:0]a,b;
output reg [15:0]out;
always @(*)
begin
    out=a+b;
end
endmodule

module PIPO2(clk,ld,din,dout,clr);
input clk,ld,clr;
input [15:0] din;
output reg [15:0] dout;

always @(posedge clk)
begin
    if (clr)
    dout<=0;
    else if(ld)
    dout<=din;
end


endmodule


module PIPO3(clk,ld,din,dout,dec);
input clk,ld,dec;
input [15:0] din;
output reg [15:0] dout;
  
  initial dout = 0; 

always @(posedge clk)
begin
     if(ld)
    dout<=din;

    else if(dec)
    dout<=dout-1;
end


endmodule

module ezero(data,eqz);
input [15:0] data;
output eqz;

assign eqz=data==1;
endmodule

module controller(lda,ldp,ldb,clk,decb,start,done,eqz,clrp);
input clk,start,eqz;
output reg lda,ldp,ldb,decb,clrp,done;
parameter s0 =0, s1=1,s2=2,s3=3,s4=4 ;
reg [3:0] state,next_state;
  
  initial state = s0;
always @(*)
begin
    case(state)
    s0:next_state<=start?s1:s0;
    s1:next_state<=s2;
    s2:next_state<=s3;
    s3:next_state<=eqz?s4:s3;
    s4:next_state<=s4;
    default:next_state<=s0;
    endcase
end
always @(posedge clk)
begin
    state<=next_state;
end

always @(*) begin
    lda  = 0;
    ldb  = 0;
    ldp  = 0;
    decb = 0;
    clrp = 0;
    done = 0;

    case (state)
        s1: lda = 1;
        s2: begin
            ldb  = 1;
            clrp = 1;
        end
        s3: begin
            ldp  = 1;
            decb = 1;
        end
        s4: done = 1;
    endcase
end

endmodule





