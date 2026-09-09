
// Module  : tb_fsm
// Project : AES-128/256 Crypto Accelerator
// Purpose : Testbench for aes_fsm module
//           Verifies state transitions and output signals


module tb_fsm;

    // Signals
    logic       clk;
    logic       rst_n;
    logic       start;
    logic       key_size;
    logic [3:0] round_num;
    logic       mc_enable;
    logic       enc_done;
    logic       state_load;
    logic [3:0] rk_sel;

    // Instantiate FSM
    aes_fsm uut (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .key_size   (key_size),
        .round_num  (round_num),
        .mc_enable  (mc_enable),
        .enc_done   (enc_done),
        .state_load (state_load),
        .rk_sel     (rk_sel)
    );

    // Clock generation — 10ns period = 100MHz
    initial clk = 0;
    always #5 clk = ~clk;

    // Monitor — prints every clock cycle
    initial begin
        $monitor("T=%0t | rst=%b start=%b | rnd=%0d mc=%b done=%b load=%b rk=%0d",
            $time, rst_n, start,
            round_num, mc_enable,
            enc_done, state_load, rk_sel);
    end

    initial begin
      
        $display("   AES FSM Verification Test             ");
       

        // Initialize
        rst_n    = 0;
        start    = 0;
        key_size = 0;  // AES-128

        // Apply reset for 2 cycles
        @(posedge clk); #1;
        @(posedge clk); #1;

        // Release reset
        rst_n = 1;
        @(posedge clk); #1;

       
        $display("Reset released — FSM in IDLE");
       

        // Assert start
        start = 1;
        @(posedge clk); #1;
        start = 0;

     
        $display("Start asserted — FSM begins encryption");
      

        // Wait for encryption to complete
        // AES-128 = IDLE + KEY_EXP + INIT + 9 MAIN + FINAL + DONE
        // = approximately 14 cycles
        repeat(15) @(posedge clk);

        // Check done signal
        if (enc_done)
            $display("PASS  enc_done asserted correctly!");
        else
            $display("FAIL  enc_done not asserted!");


        // Test 2 — verify mc_enable is OFF in DONE state
        if (!mc_enable)
            $display("PASS  mc_enable = 0 in DONE state");
        else
            $display("FAIL  mc_enable should be 0 in DONE");

        
        $display("All Tests Complete ");
       

        #20;
        $finish;
    end

endmodule