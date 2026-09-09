
// Module  : aes_addroundkey
// Project : AES-128/256 Crypto Accelerator
// Purpose : AES AddRoundKey operation
//           XORs 128-bit State with 128-bit Round Key
//           Purely combinational — just 128 XOR gates
//           Used in every round including initial round


module aes_addroundkey (
    input  logic [127:0] state,      // current State
    input  logic [127:0] round_key,  // current Round Key
    output logic [127:0] out         // State XOR Round Key
);

    // 128-bit XOR — simplest operation in AES
    // Every bit of state XORed with
    // corresponding bit of round_key
    assign out = state ^ round_key;

endmodule