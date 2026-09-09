
// Module  : tb_addroundkey
// Project : AES-128/256 Crypto Accelerator
// Purpose : Testbench for aes_addroundkey module
//           Uses NIST FIPS 197 values


module tb_addroundkey;

    // Signals
    logic [127:0] state;
    logic [127:0] round_key;
    logic [127:0] out;

    // Instantiate AddRoundKey
    aes_addroundkey uut (
        .state     (state),
        .round_key (round_key),
        .out       (out)
    );

    initial begin
       
        $display("AES AddRoundKey Verification Test");
      

        // Test 1 — NIST FIPS 197 Initial Round
        // Plaintext XOR Key = State after Initial Round
        // Plaintext  = 3243F6A8 885A308D 313198A2 E0370734
        // Key        = 2B7E1516 28AED2A6 ABF71588 09CF4F3C
        // Expected   = 193DE3BE A0F4E22B 9AC68D2A E9F84808
       
        state     = 128'h3243F6A8885A308D313198A2E0370734;
        round_key = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
        #10;

        $display("Test 1 — Initial Round");
        $display("State     : %032X", state);
        $display("RoundKey  : %032X", round_key);
        $display("Output    : %032X", out);
        $display("Expected  : 193DE3BEA0F4E22B9AC68D2AE9F84808");

        if (out == 128'h193DE3BEA0F4E22B9AC68D2AE9F84808)
            $display("Test 1 PASS  Initial Round correct!");
        else
            $display("Test 1 FAIL  Initial Round incorrect!");

        

       
        // Test 2 — NIST FIPS 197 Round 1 AddRoundKey
        // State after MixColumns   = 046681E5 E0CB199A 48F8D37A 2806264C
        // Round Key 1              = A0FAFE17 88542CB1 23A33939 2A6C7605
        // Expected after ARK       = A49C7FF2 689F352B 6B5BEA43 026A5049
       
        state     = 128'h046681E5E0CB199A48F8D37A2806264C;
        round_key = 128'hA0FAFE1788542CB123A339392A6C7605;
        #10;

        $display("Test 2 — Round 1 AddRoundKey");
        $display("State     : %032X", state);
        $display("RoundKey  : %032X", round_key);
        $display("Output    : %032X", out);
        $display("Expected  : A49C7FF2689F352B6B5BEA43026A5049");

        if (out == 128'hA49C7FF2689F352B6B5BEA43026A5049)
            $display("Test 2 PASS  Round 1 ARK correct!");
        else
            $display("Test 2 FAIL  Round 1 ARK incorrect!");

       

       
        // Test 3 — Self inverse property of XOR
        // Encrypt then decrypt should give original
        // A XOR K = B → B XOR K = A
       
        state     = 128'hDEADBEEFCAFEBABE0123456789ABCDEF;
        round_key = 128'hA5A5A5A5A5A5A5A5A5A5A5A5A5A5A5A5;
        #10;

        // First XOR — encrypt
        $display("Test 3 — XOR Self Inverse Property");
        $display("Original  : %032X", state);
        $display("After XOR : %032X", out);

        // Second XOR with same key — should give back original
        state = out;
        #10;

        $display("After 2nd : %032X", out);
        $display("Expected  : DEADBEEFCAFEBABE0123456789ABCDEF");

        if (out == 128'hDEADBEEFCAFEBABE0123456789ABCDEF)
            $display("Test 3 PASS  XOR self inverse correct!");
        else
            $display("Test 3 FAIL  XOR self inverse incorrect!");

       
        $display("All Tests Complete");
       

        $finish;
    end

endmodule