module PIPO(clk,ld,din,dout);
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

module shift_reg(clk,sin,din,dout,clr,ld,lds);
input clk,sin,clr,ld,lds;
input [15:0] din;
output reg [15:0] dout;

 initial dout = 0; 

always @(posedge clk)
begin
  if (clr)
  dout <= 0;
else if (ld)
  dout <= din;
else if (lds)
  dout <= {sin, dout[15:1]};
end
endmodule

module dff(clk,clr,din,dout,sftd);
input clk,clr,sftd;
input  din;
output reg  dout;
  
  initial dout = 0; 

always @(posedge clk)
begin
    if(clr)
    dout<=0;
    else if(sftd)
    dout<=din;
end
endmodule

module alu(clk,addsub,q1,q2,out);
input addsub,clk;
input [15:0] q1,q2;
output [15:0] out;



assign out = addsub ? (q1 + q2) : (q1 - q2);

endmodule

module cntr(clk,out,ldc,dec);
input clk,ldc,dec;
output reg [4:0] out;

initial out = 0; 

always @(posedge clk) begin
    
     if(ldc)
    out<=5'b01111;
    else if(dec)
    out<=out-1;
    
end

endmodule

module BOOTHMULT(
    input clk,lda,ldq,ldm,decc,clra,sft,clrff,addsub,clrq,ldcnt,
    input [15:0] data_in,
    output qm1,eqz,q0

);
wire signed [15:0] A,M,Z,Q;
assign q0= Q[0];

wire [4:0] count;

assign eqz = (count == 0);

shift_reg AR(.clk(clk),.ld(lda),.din(Z),.dout(A),.lds(sft),.sin(A[15]),.clr(clra));

shift_reg QR(.clk(clk),.ld(ldq),.din(data_in),.dout(Q),.lds(sft),.sin(A[0]),.clr(clrq));

dff Qm(.clk(clk),.clr(clrff),.din(q0),.sftd(sft),.dout(qm1));

cntr c1(.clk(clk),.dec(decc),.ldc(ldcnt),.out(count));

PIPO MR(.clk(clk),.ld(ldm),.din(data_in),.dout(M));

alu AN(.clk(clk),.addsub(addsub),.q1(A),.q2(M),.out(Z));



endmodule

module controller(
    input start,eqz,clk, q0,qm,
    output reg done,lda,ldq,ldm,decc,clra,sft,clrff,addsub,clrq,ldcnt
);

parameter s0=0,s1=1,s2=2,s3=3,s4=4,s5=5,s6=6;
reg [2:0] state,next_state;

always @(*) begin
    case (state)
        s0: next_state=start?s1:s0;
        s1:next_state=s2;
        s2:next_state=({q0,qm}==2'b01)?s3:({q0,qm}==2'b10)?s4:s5;
        s3:next_state=s5;
        s4:next_state=s5;
      s5:next_state=(eqz==1)?s6:({q0,qm}==2'b01 )?s3:s4;
        s6:next_state=s6;
        default: next_state=s0;
    endcase
    
end

always @(posedge clk) begin
    state<=next_state;
    
end

  assign lda     = ((state == s3)||(state == s4))?1:0;
  assign clra    =  (state == s0)?1:0;
  assign sft    =  (state == s5)?1:0;
  assign ldq     =  (state == s2)?1:0;
  assign clrq    =  (state == s0)?1:0;
	
  assign ldm     =  (state == s1)?1:0;
  assign clrff   =  (state == s0)?1:0;
  assign addsub     =  (state == s3)?1:0;
    
  assign decc    =  (state == s5)?1:0;
  assign ldcnt =  (state == s1)?1:0; 
  assign done    =  (state == s6)?1:0;	

endmodule

module BOOTH_TOP(
    input clk, start,
    input [15:0] data_in,
    output done
);
    // Control signals wired between Controller and Datapath
    wire lda, ldq, ldm, decc, clra, sft, clrff, addsub, clrq, ldcnt;
    wire qm1, eqz, q0;

    // Instantiate Datapath
    
    BOOTHMULT datapath (
        .clk(clk), .lda(lda), .ldq(ldq), .ldm(ldm), .decc(decc), 
        .clra(clra), .sft(sft), .clrff(clrff), .addsub(addsub), 
        .clrq(clrq), .ldcnt(ldcnt), .data_in(data_in), 
        .qm1(qm1), .eqz(eqz), .q0(q0) 
    );

    // Instantiate Controller
    controller ctrl (
        .clk(clk), .start(start), .eqz(eqz), .q0(q0), .qm(qm1),
        .done(done), .lda(lda), .ldq(ldq), .ldm(ldm), .decc(decc), 
        .clra(clra), .sft(sft), .clrff(clrff), .addsub(addsub), 
        .clrq(clrq), .ldcnt(ldcnt)
    );
endmodule




