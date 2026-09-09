
// Module  : tb_subbytes
// Project : AES-128/256 Crypto Accelerator
// Purpose : Testbench for aes_subbytes module
//           Uses NIST FIPS 197 Round 1 values


module tb_subbytes;

    // Signals
    logic [127:0] in;
    logic [127:0] out;

    // Instantiate SubBytes module
    aes_subbytes uut (
        .in  (in),
        .out (out)
    );

    initial begin
       
        $display("   AES SubBytes Verification Test        ");
        

        // Test 1 — NIST FIPS 197 Round 1
        // Input  = State after Initial AddRoundKey
        // = 19 3D E3 BE A0 F4 E2 2B 9A C6 8D 2A E9 F8 48 08
        // Output = State after SubBytes Round 1
        // = D4 27 11 AE E0 BF 98 F1 B8 B4 5D E5 1E 41 52 30

        in = 128'h193DE3BEA0F4E22B9AC68D2AE9F84808;
        #10;

        $display("Input  State : %032X", in);
        $display("Output State : %032X", out);
        $display("Expected     : D42711AEE0BF98F1B8B45DE51E415230");

        if (out == 128'hD42711AEE0BF98F1B8B45DE51E415230)
            $display("Test 1 PASS  SubBytes correct!");
        else
            $display("Test 1 FAIL  SubBytes incorrect!");


        // Test 2 — All zeros input
        // SBox[0x00] = 0x63
        // All 16 bytes = 0x00 → all output = 0x63
        in = 128'h00000000000000000000000000000000;
        #10;

        $display("Input  State : %032X", in);
        $display("Output State : %032X", out);
        $display("Expected     : 63636363636363636363636363636363");

        if (out == 128'h63636363636363636363636363636363)
            $display("Test 2 PASS  All zeros correct!");
        else
            $display("Test 2 FAIL  All zeros incorrect!");

        

        // Test 3 — All 0xFF input
        // SBox[0xFF] = 0x16
        // All 16 bytes = 0xFF → all output = 0x16
        in = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        #10;

        $display("Input  State : %032X", in);
        $display("Output State : %032X", out);
        $display("Expected     : 16161616161616161616161616161616");

        if (out == 128'h16161616161616161616161616161616)
            $display("Test 3 PASS  All FF correct!");
        else
            $display("Test 3 FAIL  All FF incorrect!");

        $display("All Tests Complete");
 

        $finish;
    end

endmodule