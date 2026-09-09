
// Module  : tb_sbox
// Project : AES-128/256 Crypto Accelerator
// Purpose : Testbench for aes_sbox module
//           Verifies against NIST FIPS 197 values


module tb_sbox;

    // Declare signals
    logic [7:0] in;
    logic [7:0] out;

    // Instantiate the S-Box module
    aes_sbox uut (
        .in  (in),
        .out (out)
    );

    // Test procedure
    initial begin
       
        $display("   AES S-Box Verification Test      ");
      

        // Test 1 — from our manual trace
        // Input 0x53 should give 0xED
        in = 8'h53;
        #10;
        if (out == 8'hed)
            $display("Test 1 PASS: SBox[0x53] = 0x%02X", out);
        else
            $display("Test 1 FAIL: SBox[0x53] = 0x%02X, Expected 0xED", out);

        // Test 2 — from our manual trace
        // Input 0x19 should give 0xD4
        in = 8'h19;
        #10;
        if (out == 8'hd4)
            $display("Test 2 PASS: SBox[0x19] = 0x%02X", out);
        else
            $display("Test 2 FAIL: SBox[0x19] = 0x%02X, Expected 0xD4", out);

        // Test 3 — from our manual trace
        // Input 0xA0 should give 0xE0
        in = 8'ha0;
        #10;
        if (out == 8'he0)
            $display("Test 3 PASS: SBox[0xA0] = 0x%02X", out);
        else
            $display("Test 3 FAIL: SBox[0xA0] = 0x%02X, Expected 0xE0", out);

        // Test 4 — from our manual trace
        // Input 0x9A should give 0xB8
        in = 8'h9a;
        #10;
        if (out == 8'hb8)
            $display("Test 4 PASS: SBox[0x9A] = 0x%02X", out);
        else
            $display("Test 4 FAIL: SBox[0x9A] = 0x%02X, Expected 0xB8", out);

        // Test 5 — FIPS 197 known value
        // Input 0x00 should give 0x63
        in = 8'h00;
        #10;
        if (out == 8'h63)
            $display("Test 5 PASS: SBox[0x00] = 0x%02X", out);
        else
            $display("Test 5 FAIL: SBox[0x00] = 0x%02X, Expected 0x63", out);

        // Test 6 — FIPS 197 known value
        // Input 0xFF should give 0x16
        in = 8'hff;
        #10;
        if (out == 8'h16)
            $display("Test 6 PASS: SBox[0xFF] = 0x%02X", out);
        else
            $display("Test 6 FAIL: SBox[0xFF] = 0x%02X, Expected 0x16", out);

        // Test 7 — from our manual trace Round 1
        // Input 0x3D should give 0x27
        in = 8'h3d;
        #10;
        if (out == 8'h27)
            $display("Test 7 PASS: SBox[0x3D] = 0x%02X", out);
        else
            $display("Test 7 FAIL: SBox[0x3D] = 0x%02X, Expected 0x27", out);

        // Test 8 — from our manual trace Round 1
        // Input 0xE3 should give 0x11
        in = 8'he3;
        #10;
        if (out == 8'h11)
            $display("Test 8 PASS: SBox[0xE3] = 0x%02X", out);
        else
            $display("Test 8 FAIL: SBox[0xE3] = 0x%02X, Expected 0x11", out);

       
        $display("   All Tests Complete               ");
       

        $finish;
    end

endmodule