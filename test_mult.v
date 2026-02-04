module testbench;
    reg [15:0] data_in;
    reg clk, start;
    wire done, lda, ldb, ldp, clrp, decb, eqz;

    // Fixed mapping: .datain instead of .BUS
    mul_datapath dp (
        .eqz(eqz), .lda(lda), .ldb(ldb), .clrp(clrp), 
        .decb(decb), .ldp(ldp), .datain(data_in), .clk(clk)
    );

    controller con (
        .lda(lda), .ldp(ldp), .ldb(ldb), .clk(clk), 
        .decb(decb), .start(start), .done(done), .eqz(eqz), .clrp(clrp)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0; start = 0; data_in = 0;
         data_in = 7;
    #7;            // <<< move away from clock edge
    start = 1;
    #10;
    start = 0;

        #10 start = 0; data_in = 10;  // Load B
        wait(done);
        #10 $display("Final Result: %d", dp.Y);
        $finish;
    end

    initial begin
        $monitor("Time: %t | Accumulator: %d | Done: %b", $time, dp.Y, done);
        $dumpfile("mul.vcd");
        $dumpvars(0, testbench);
    end
endmodule