
// Module  : aes_mixcolumns
// Project : AES-128/256 Crypto Accelerator
// Purpose : AES MixColumns operation
//           Mixes each column of State matrix
//           using GF(2^8) arithmetic
//           4 columns processed simultaneously
//           Purely combinational


module aes_mixcolumns (
    input  logic [127:0] in,    // 128-bit input state
    output logic [127:0] out    // 128-bit output state
);

    // Function: xtime
    // Purpose : Multiply one byte by 2 in GF(2^8)
    //           = shift left 1 + conditional XOR 0x1B
  
    function automatic logic [7:0] xtime (
        input logic [7:0] b
    );
        xtime = {b[6:0], 1'b0} ^ (b[7] ? 8'h1b : 8'h00);
    endfunction

    
    // Function: mix_col
    // Purpose : Mix one column of 4 bytes
    //           Applies MixColumns recipe using xtime
 
    function automatic logic [31:0] mix_col (
        input logic [31:0] col
    );
        logic [7:0] s0, s1, s2, s3;
        logic [7:0] t0, t1, t2, t3;

        // Extract 4 bytes from column
        s0 = col[31:24];
        s1 = col[23:16];
        s2 = col[15:8];
        s3 = col[7:0];

        // Apply MixColumns recipe
        // New S0 = (2×S0) XOR (3×S1) XOR S2 XOR S3
        t0 = xtime(s0) ^ (xtime(s1) ^ s1) ^ s2 ^ s3;

        // New S1 = S0 XOR (2×S1) XOR (3×S2) XOR S3
        t1 = s0 ^ xtime(s1) ^ (xtime(s2) ^ s2) ^ s3;

        // New S2 = S0 XOR S1 XOR (2×S2) XOR (3×S3)
        t2 = s0 ^ s1 ^ xtime(s2) ^ (xtime(s3) ^ s3);

        // New S3 = (3×S0) XOR S1 XOR S2 XOR (2×S3)
        t3 = (xtime(s0) ^ s0) ^ s1 ^ s2 ^ xtime(s3);

        // Pack 4 new bytes back into one 32-bit column
        mix_col = {t0, t1, t2, t3};
    endfunction

  
    // Apply mix_col to all 4 columns simultaneously
    // Column 0 = in[127:96]   (most significant)
    // Column 1 = in[95:64]
    // Column 2 = in[63:32]
    // Column 3 = in[31:0]     (least significant)
  
    assign out[127:96] = mix_col(in[127:96]);  // Column 0
    assign out[95:64]  = mix_col(in[95:64]);   // Column 1
    assign out[63:32]  = mix_col(in[63:32]);   // Column 2
    assign out[31:0]   = mix_col(in[31:0]);    // Column 3

endmodule