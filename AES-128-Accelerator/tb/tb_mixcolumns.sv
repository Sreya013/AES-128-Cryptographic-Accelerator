
// Module  : tb_mixcolumns
// Project : AES-128/256 Crypto Accelerator
// Purpose : Testbench for aes_mixcolumns module
//           Uses NIST FIPS 197 Round 1 values


module tb_mixcolumns;

    // Signals
    logic [127:0] in;
    logic [127:0] out;

    // Instantiate MixColumns
    aes_mixcolumns uut (
        .in  (in),
        .out (out)
    );

    initial begin
     
        $display("   AES MixColumns Verification Test      ");
     

        // Test 1 — NIST FIPS 197 Round 1
        // Input  = State after ShiftRows
        // = D4 BF 5D 30 E0 B4 52 AE B8 41 11 F1 1E 27 98 E5
        // Output = State after MixColumns
        // = 04 66 81 E5 E0 CB 19 9A 48 F8 D3 7A 28 06 26 4C

        in = 128'hD4BF5D30E0B452AEB84111F11E2798E5;
        #10;

        $display("Input    : %032X", in);
        $display("Output   : %032X", out);
        $display("Expected : 046681E5E0CB199A48F8D37A2806264C");

        if (out == 128'h046681E5E0CB199A48F8D37A2806264C)
            $display("Test 1 PASS  MixColumns correct!");
        else
            $display("Test 1 FAIL  MixColumns incorrect!");


        // Test 2 — FIPS 197 known vector
        // Single column test
        // Column = DB 13 53 45
        // Expected output column = 8E 4D A1 BC

        in = 128'hDB13534500000000000000000000000;
        #10;

        $display("Input    : %032X", in);
        $display("Output   : %032X", out);
        $display("Col0 out : %02X %02X %02X %02X",
            out[127:120], out[119:112], out[111:104], out[103:96]);
        $display("Expected : 8E 4D A1 BC");

        if (out[127:96] == 32'h8E4DA1BC)
            $display("Test 2 PASS Column vector correct!");
        else
            $display("Test 2 FAIL  Column vector incorrect!");

        $display("All Tests Complete ");
     

        $finish;
    end

endmodule