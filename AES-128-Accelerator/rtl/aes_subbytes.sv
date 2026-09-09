
// Module  : aes_subbytes
// Project : AES-128/256 Crypto Accelerator
// Purpose : AES SubBytes operation
//           Applies S-Box substitution to all 16 bytes
//           of the State matrix simultaneously
//           Purely combinational — no clock needed


module aes_subbytes (
    input  logic [127:0] in,   // 128-bit input state
    output logic [127:0] out   // 128-bit output state
);

    // Instantiate 16 S-Boxes — one per byte
    // All work simultaneously in parallel
    // Byte 0 is the most significant byte [127:120]

    aes_sbox sbox_00 (.in(in[127:120]), .out(out[127:120]));
    aes_sbox sbox_01 (.in(in[119:112]), .out(out[119:112]));
    aes_sbox sbox_02 (.in(in[111:104]), .out(out[111:104]));
    aes_sbox sbox_03 (.in(in[103:96]),  .out(out[103:96]));
    aes_sbox sbox_04 (.in(in[95:88]),   .out(out[95:88]));
    aes_sbox sbox_05 (.in(in[87:80]),   .out(out[87:80]));
    aes_sbox sbox_06 (.in(in[79:72]),   .out(out[79:72]));
    aes_sbox sbox_07 (.in(in[71:64]),   .out(out[71:64]));
    aes_sbox sbox_08 (.in(in[63:56]),   .out(out[63:56]));
    aes_sbox sbox_09 (.in(in[55:48]),   .out(out[55:48]));
    aes_sbox sbox_10 (.in(in[47:40]),   .out(out[47:40]));
    aes_sbox sbox_11 (.in(in[39:32]),   .out(out[39:32]));
    aes_sbox sbox_12 (.in(in[31:24]),   .out(out[31:24]));
    aes_sbox sbox_13 (.in(in[23:16]),   .out(out[23:16]));
    aes_sbox sbox_14 (.in(in[15:8]),    .out(out[15:8]));
    aes_sbox sbox_15 (.in(in[7:0]),     .out(out[7:0]));

endmodule