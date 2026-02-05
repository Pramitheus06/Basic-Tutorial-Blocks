`timescale 1ns/1ps

module tb_booth();
    reg clk, start;
    reg [15:0] data_in;
    wire done;

    // Instantiate the Top Module
    BOOTH_TOP dut (
        .clk(clk), 
        .start(start), 
        .data_in(data_in), 
        .done(done)
    );

    // Clock Generation (10ns period)
    always #5 clk = ~clk;

    initial begin
        // Initialize
        clk = 0;
        start = 0;
        data_in = 0;

        $display("--- Starting Booth's Multiplier Test ---");
        
        // Step 1: Load Multiplicand (M) = 10
        #10 data_in = 16'd10;
        start = 1;
        #10 start = 0;

        // Step 2: Load Multiplier (Q) = -5
        // In your controller, S2 is where LDQ happens. 
        // We wait for the state machine to move.
        wait(dut.ldq); 
        data_in = -16'd5; 
        
        // Step 3: Wait for completion
        wait(done);
        
        #10;
        $display("Multiplication Finished!");
        $display("Result (A): %h", dut.datapath.A);
        $display("Result (Q): %h", dut.datapath.Q);
        $display("Full 32-bit Product: %h", {dut.datapath.A, dut.datapath.Q});
        
        if ({dut.datapath.A, dut.datapath.Q} == 32'hFFFFFFCE)
            $display("SUCCESS: 10 * -5 = -50");
        else
            $display("FAILURE: Result mismatch");

        #50 $finish;
    end
endmodule