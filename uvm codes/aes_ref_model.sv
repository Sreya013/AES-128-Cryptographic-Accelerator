
// File    : aes_ref_model.sv
// Project : AES-128 UVM Verification
// Purpose : Independent AES-128 Reference Model
//           Software implementation of AES-128
//           Used by scoreboard to compute expected ciphertext
//           Completely independent from RTL implementation
//           Verified against NIST FIPS 197


`ifndef AES_REF_MODEL_SV
`define AES_REF_MODEL_SV

class aes_ref_model;

    // AES S-Box — same values as hardware
    // but stored here independently as a lookup array
   
    static logic [7:0] sbox [0:255] = '{
        8'h63, 8'h7c, 8'h77, 8'h7b, 8'hf2, 8'h6b, 8'h6f, 8'hc5,
        8'h30, 8'h01, 8'h67, 8'h2b, 8'hfe, 8'hd7, 8'hab, 8'h76,
        8'hca, 8'h82, 8'hc9, 8'h7d, 8'hfa, 8'h59, 8'h47, 8'hf0,
        8'had, 8'hd4, 8'ha2, 8'haf, 8'h9c, 8'ha4, 8'h72, 8'hc0,
        8'hb7, 8'hfd, 8'h93, 8'h26, 8'h36, 8'h3f, 8'hf7, 8'hcc,
        8'h34, 8'ha5, 8'he5, 8'hf1, 8'h71, 8'hd8, 8'h31, 8'h15,
        8'h04, 8'hc7, 8'h23, 8'hc3, 8'h18, 8'h96, 8'h05, 8'h9a,
        8'h07, 8'h12, 8'h80, 8'he2, 8'heb, 8'h27, 8'hb2, 8'h75,
        8'h09, 8'h83, 8'h2c, 8'h1a, 8'h1b, 8'h6e, 8'h5a, 8'ha0,
        8'h52, 8'h3b, 8'hd6, 8'hb3, 8'h29, 8'he3, 8'h2f, 8'h84,
        8'h53, 8'hd1, 8'h00, 8'hed, 8'h20, 8'hfc, 8'hb1, 8'h5b,
        8'h6a, 8'hcb, 8'hbe, 8'h39, 8'h4a, 8'h4c, 8'h58, 8'hcf,
        8'hd0, 8'hef, 8'haa, 8'hfb, 8'h43, 8'h4d, 8'h33, 8'h85,
        8'h45, 8'hf9, 8'h02, 8'h7f, 8'h50, 8'h3c, 8'h9f, 8'ha8,
        8'h51, 8'ha3, 8'h40, 8'h8f, 8'h92, 8'h9d, 8'h38, 8'hf5,
        8'hbc, 8'hb6, 8'hda, 8'h21, 8'h10, 8'hff, 8'hf3, 8'hd2,
        8'hcd, 8'h0c, 8'h13, 8'hec, 8'h5f, 8'h97, 8'h44, 8'h17,
        8'hc4, 8'ha7, 8'h7e, 8'h3d, 8'h64, 8'h5d, 8'h19, 8'h73,
        8'h60, 8'h81, 8'h4f, 8'hdc, 8'h22, 8'h2a, 8'h90, 8'h88,
        8'h46, 8'hee, 8'hb8, 8'h14, 8'hde, 8'h5e, 8'h0b, 8'hdb,
        8'he0, 8'h32, 8'h3a, 8'h0a, 8'h49, 8'h06, 8'h24, 8'h5c,
        8'hc2, 8'hd3, 8'hac, 8'h62, 8'h91, 8'h95, 8'he4, 8'h79,
        8'he7, 8'hc8, 8'h37, 8'h6d, 8'h8d, 8'hd5, 8'h4e, 8'ha9,
        8'h6c, 8'h56, 8'hf4, 8'hea, 8'h65, 8'h7a, 8'hae, 8'h08,
        8'hba, 8'h78, 8'h25, 8'h2e, 8'h1c, 8'ha6, 8'hb4, 8'hc6,
        8'he8, 8'hdd, 8'h74, 8'h1f, 8'h4b, 8'hbd, 8'h8b, 8'h8a,
        8'h70, 8'h3e, 8'hb5, 8'h66, 8'h48, 8'h03, 8'hf6, 8'h0e,
        8'h61, 8'h35, 8'h57, 8'hb9, 8'h86, 8'hc1, 8'h1d, 8'h9e,
        8'he1, 8'hf8, 8'h98, 8'h11, 8'h69, 8'hd9, 8'h8e, 8'h94,
        8'h9b, 8'h1e, 8'h87, 8'he9, 8'hce, 8'h55, 8'h28, 8'hdf,
        8'h8c, 8'ha1, 8'h89, 8'h0d, 8'hbf, 8'he6, 8'h42, 8'h68,
        8'h41, 8'h99, 8'h2d, 8'h0f, 8'hb0, 8'h54, 8'hbb, 8'h16
    };

    // --------------------------------------------------------
    // Rcon values for key schedule
    // --------------------------------------------------------
    static logic [7:0] rcon [1:10] = '{
        8'h01, 8'h02, 8'h04, 8'h08, 8'h10,
        8'h20, 8'h40, 8'h80, 8'h1b, 8'h36
    };

    // --------------------------------------------------------
    // Function: xtime
    // Multiply byte by 2 in GF(2^8)
    // --------------------------------------------------------
    static function automatic logic [7:0] xtime(
        input logic [7:0] b
    );
        return {b[6:0], 1'b0} ^ (b[7] ? 8'h1b : 8'h00);
    endfunction

  
    // Function: sub_word
    // Apply S-Box to all 4 bytes of a word
 
    static function automatic logic [31:0] sub_word(
        input logic [31:0] w
    );
        return {sbox[w[31:24]],
                sbox[w[23:16]],
                sbox[w[15:8]],
                sbox[w[7:0]]};
    endfunction

   
    // Function: rot_word
    // Rotate word left by 1 byte
   
    static function automatic logic [31:0] rot_word(
        input logic [31:0] w
    );
        return {w[23:0], w[31:24]};
    endfunction

    
    // Function: add_round_key
    // XOR state with round key
    static function automatic logic [127:0] add_round_key(
        input logic [127:0] state,
        input logic [127:0] rk
    );
        return state ^ rk;
    endfunction

    
    // Function: sub_bytes
    // Apply S-Box to all 16 bytes of state
    
    static function automatic logic [127:0] sub_bytes(
        input logic [127:0] state
    );
        logic [127:0] result;
        for (int i = 0; i < 16; i++) begin
            result[127-(i*8) -: 8] =
                sbox[state[127-(i*8) -: 8]];
        end
        return result;
    endfunction

    // Function: shift_rows
    // Cyclically shift rows of state
   
    static function automatic logic [127:0] shift_rows(
        input logic [127:0] s
    );
        logic [7:0] b[0:15];
        logic [127:0] result;

        // Extract bytes
        for (int i = 0; i < 16; i++)
            b[i] = s[127-(i*8) -: 8];

        // Row 0 — no shift: b0 b4 b8  b12
        // Row 1 — shift 1:  b5 b9 b13 b1
        // Row 2 — shift 2:  b10 b14 b2 b6
        // Row 3 — shift 3:  b15 b3 b7 b11
        result = {b[0],  b[5],  b[10], b[15],
                  b[4],  b[9],  b[14], b[3],
                  b[8],  b[13], b[2],  b[7],
                  b[12], b[1],  b[6],  b[11]};
        return result;
    endfunction

    // Function: mix_single_col
    // Mix one column of 4 bytes
   
    static function automatic logic [31:0] mix_single_col(
        input logic [31:0] col
    );
        logic [7:0] s0, s1, s2, s3;
        logic [7:0] t0, t1, t2, t3;

        s0 = col[31:24];
        s1 = col[23:16];
        s2 = col[15:8];
        s3 = col[7:0];

        t0 = xtime(s0) ^ (xtime(s1)^s1) ^ s2 ^ s3;
        t1 = s0 ^ xtime(s1) ^ (xtime(s2)^s2) ^ s3;
        t2 = s0 ^ s1 ^ xtime(s2) ^ (xtime(s3)^s3);
        t3 = (xtime(s0)^s0) ^ s1 ^ s2 ^ xtime(s3);

        return {t0, t1, t2, t3};
    endfunction

    
    // Function: mix_columns
    // Mix all 4 columns
   
    static function automatic logic [127:0] mix_columns(
        input logic [127:0] state
    );
        return {mix_single_col(state[127:96]),
                mix_single_col(state[95:64]),
                mix_single_col(state[63:32]),
                mix_single_col(state[31:0])};
    endfunction

   
    // Function: key_expansion
    // Expand 128-bit key into 11 round keys
   
    static function automatic void key_expansion(
        input  logic [127:0] key,
        output logic [127:0] round_keys[0:10]
    );
        logic [31:0] w[0:43];

        // Initial 4 words from original key
        w[0] = key[127:96];
        w[1] = key[95:64];
        w[2] = key[63:32];
        w[3] = key[31:0];

        // Generate remaining words
        for (int i = 4; i < 44; i++) begin
            logic [31:0] temp;
            temp = w[i-1];
            if (i % 4 == 0)
                temp = sub_word(rot_word(temp))
                       ^ {rcon[i/4], 24'h0};
            w[i] = w[i-4] ^ temp;
        end

        // Pack words into round keys
        for (int r = 0; r <= 10; r++)
            round_keys[r] = {w[r*4],   w[r*4+1],
                             w[r*4+2], w[r*4+3]};
    endfunction


    // Function: encrypt
    // Main AES-128 encryption function
    // This is what scoreboard calls
    // Input:  plaintext + key
    // Output: correct ciphertext
    
    static function automatic logic [127:0] encrypt(
        input logic [127:0] plaintext,
        input logic [127:0] key
    );
        logic [127:0] state;
        logic [127:0] round_keys[0:10];

        // Step 1 — expand key
        key_expansion(key, round_keys);

        // Step 2 — initial round
        state = add_round_key(plaintext, round_keys[0]);

        // Step 3 — main rounds 1 to 9
        for (int r = 1; r <= 9; r++) begin
            state = sub_bytes(state);
            state = shift_rows(state);
            state = mix_columns(state);
            state = add_round_key(state, round_keys[r]);
        end

        // Step 4 — final round (no mix_columns)
        state = sub_bytes(state);
        state = shift_rows(state);
        state = add_round_key(state, round_keys[10]);

        return state;
    endfunction

endclass

`endif