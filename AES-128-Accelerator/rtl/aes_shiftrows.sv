
// Module  : aes_shiftrows
// Project : AES-128/256 Crypto Accelerator
// Purpose : AES ShiftRows operation
//           Cyclically shifts rows of State matrix left
//           Row 0 → no shift
//           Row 1 → shift left 1
//           Row 2 → shift left 2
//           Row 3 → shift left 3
//           Purely combinational — zero logic gates
//           implemented as pure wire connections


module aes_shiftrows (
    input  logic [127:0] in,    // 128-bit input state
    output logic [127:0] out    // 128-bit output state
);

   
    // Row 0 — no shift
    // Bytes stay exactly in same position
    
    assign out[127:120] = in[127:120];  // Row0 Col0
    assign out[95:88]   = in[95:88];    // Row0 Col1
    assign out[63:56]   = in[63:56];    // Row0 Col2
    assign out[31:24]   = in[31:24];    // Row0 Col3

    
    // Row 1 — shift left by 1
    // Col0←Col1, Col1←Col2, Col2←Col3, Col3←Col0(wrap)
    
    assign out[119:112] = in[87:80];    // Row1 Col0 ← Col1
    assign out[87:80]   = in[55:48];    // Row1 Col1 ← Col2
    assign out[55:48]   = in[23:16];    // Row1 Col2 ← Col3
    assign out[23:16]   = in[119:112];  // Row1 Col3 ← Col0(wrap)

  
    // Row 2 — shift left by 2
    // Col0←Col2, Col1←Col3, Col2←Col0(wrap), Col3←Col1(wrap)
    
    assign out[111:104] = in[47:40];    // Row2 Col0 ← Col2
    assign out[79:72]   = in[15:8];     // Row2 Col1 ← Col3
    assign out[47:40]   = in[111:104];  // Row2 Col2 ← Col0(wrap)
    assign out[15:8]    = in[79:72];    // Row2 Col3 ← Col1(wrap)

   
    // Row 3 — shift left by 3
    // Col0←Col3, Col1←Col0(wrap), Col2←Col1(wrap), Col3←Col2(wrap)
   
    assign out[103:96]  = in[7:0];      // Row3 Col0 ← Col3
    assign out[71:64]   = in[103:96];   // Row3 Col1 ← Col0(wrap)
    assign out[39:32]   = in[71:64];    // Row3 Col2 ← Col1(wrap)
    assign out[7:0]     = in[39:32];    // Row3 Col3 ← Col2(wrap)

endmodule