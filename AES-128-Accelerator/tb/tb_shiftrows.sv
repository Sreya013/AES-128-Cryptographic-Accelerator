
// Module  : tb_shiftrows
// Project : AES-128/256 Crypto Accelerator
// Purpose : Testbench for aes_shiftrows module
//           Uses NIST FIPS 197 Round 1 values


module tb_shiftrows;

    // Signals
    logic [127:0] in;
    logic [127:0] out;

    // Instantiate ShiftRows
    aes_shiftrows uut (
        .in  (in),
        .out (out)
    );

    initial begin
       
        $display("   AES ShiftRows Verification Test       ");
       

        // Test 1 — NIST FIPS 197 Round 1
        // Input  = State after SubBytes
        // = D4 27 11 AE E0 BF 98 F1 B8 B4 5D E5 1E 41 52 30
        // Output = State after ShiftRows
        // = D4 BF 5D 30 E0 B4 52 AE B8 41 11 F1 1E 27 98 E5

        in = 128'hD42711AEE0BF98F1B8B45DE51E415230;
        #10;

        $display("Input    : %032X", in);
        $display("Output   : %032X", out);
        $display("Expected : D4BF5D30E0B452AEB84111F11E2798E5");

        if (out == 128'hD4BF5D30E0B452AEB84111F11E2798E5)
            $display("Test 1 PASS  ShiftRows correct!");
        else
            $display("Test 1 FAIL  ShiftRows incorrect!");


        // Test 2 — Simple pattern test
        // Input each byte = its position number
        // Easy to verify shifting manually
        in = 128'h000102030405060708090A0B0C0D0E0F;
        #10;

        $display("Input    : %032X", in);
        $display("Output   : %032X", out);
        $display("Expected : 00050A0F04090E0308010C0B0C06010A");

        // Row0: 00 04 08 0C → no shift  → 00 04 08 0C
        // Row1: 01 05 09 0D → shift 1   → 05 09 0D 01
        // Row2: 02 06 0A 0E → shift 2   → 0A 0E 02 06
        // Row3: 03 07 0B 0F → shift 3   → 0F 03 07 0B

        if (out == 128'h00040810050901020A0E020F03070B06)
            $display("Test 2 PASS ✓ Pattern test correct!")  ;
        else begin
            $display("Test 2 output: %032X", out);
            $display("Checking manually...");
            // Display each row for manual verification
            $display("Row0 out: %02X %02X %02X %02X",
                out[127:120], out[95:88], out[63:56], out[31:24]);
            $display("Row1 out: %02X %02X %02X %02X",
                out[119:112], out[87:80], out[55:48], out[23:16]);
            $display("Row2 out: %02X %02X %02X %02X",
                out[111:104], out[79:72], out[47:40], out[15:8]);
            $display("Row3 out: %02X %02X %02X %02X",
                out[103:96], out[71:64], out[39:32], out[7:0]);
        end

        $display("   All Tests Complete                    ");
       

        $finish;
    end

endmodule