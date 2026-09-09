
// Module  : aes_top
// Project : AES-128/256 Crypto Accelerator
// Purpose : Top level module
//           Connects all 9 submodules together
//           Complete AES encryption engine
//           AXI4-Lite slave interface
// Module  : aes_top
// Project : AES-128 Crypto Accelerator
// Purpose : Top-level AES-128 encryption engine
//
// Datapath:
//   Plaintext
//      |
//      v
//   AddRoundKey (Round 0)
//      |
//      v
//   Rounds 1-9:
//      SubBytes -> ShiftRows -> MixColumns -> AddRoundKey
//      |
//      v
//   Round 10:
//      SubBytes -> ShiftRows -> AddRoundKey
//      |
//      v
//   Ciphertext
//
// AXI4-Lite slave interface

`timescale 1ns/1ps

module aes_top #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input  logic                     aclk,
    input  logic                     aresetn,

    
    // AXI4-Lite Write Address
  
    input  logic [ADDR_WIDTH-1:0]    awaddr,
    input  logic                     awvalid,
    output logic                     awready,

    
    // AXI4-Lite Write Data
   
    input  logic [DATA_WIDTH-1:0]    wdata,
    input  logic [DATA_WIDTH/8-1:0]  wstrb,
    input  logic                     wvalid,
    output logic                     wready,

    
    // AXI4-Lite Write Response
    
    output logic [1:0]               bresp,
    output logic                     bvalid,
    input  logic                     bready,

  
    // AXI4-Lite Read Address
    
    input  logic [ADDR_WIDTH-1:0]    araddr,
    input  logic                     arvalid,
    output logic                     arready,

    
    // AXI4-Lite Read Data

    output logic [DATA_WIDTH-1:0]    rdata,
    output logic [1:0]               rresp,
    output logic                     rvalid,
    input  logic                     rready
);

   
    // INTERNAL SIGNALS
  

    
    // AXI <-> Register File
    
    logic                     rf_wr_en;
    logic [ADDR_WIDTH-1:0]    rf_wr_addr;
    logic [DATA_WIDTH-1:0]    rf_wr_data;

    logic [ADDR_WIDTH-1:0]    rf_rd_addr;
    logic [DATA_WIDTH-1:0]    rf_rd_data;

    
    // Hardware configuration
   
    logic [127:0] key;
    logic [127:0] plaintext;
    logic         start;
    logic         key_size;

    
    // FSM control signals
    
    logic [3:0]   round_num;
    logic         mc_enable;
    logic         enc_done;
    logic         state_load;
    logic [3:0]   rk_sel;

    
    // AES Key Schedule
    // AES-128 => Round Keys 0 through 10
    logic [127:0] round_keys [0:10];
    logic [127:0] current_round_key;

   
    // AES datapath
    
    logic [127:0] state_reg;

    logic [127:0] pipeline_input;

    logic [127:0] after_subbytes;
    logic [127:0] after_shiftrows;
    logic [127:0] after_mixcolumns_raw;
    logic [127:0] after_mixcolumns;

    logic [127:0] ark_input;
    logic [127:0] after_addroundkey;

   
    // Final ciphertext register
    //
    // IMPORTANT:
    // The ciphertext is captured at the end of Round 10.
    // It must NOT continue through the AES combinational
    // datapath during the DONE state.
    
    logic [127:0] ciphertext_reg;
    logic [127:0] ciphertext;


    
    // AXI4-LITE INTERFACE
    

    aes_axilite #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) u_axilite (
        .aclk       (aclk),
        .aresetn    (aresetn),

        .awaddr     (awaddr),
        .awvalid    (awvalid),
        .awready    (awready),

        .wdata      (wdata),
        .wstrb      (wstrb),
        .wvalid     (wvalid),
        .wready     (wready),

        .bresp      (bresp),
        .bvalid     (bvalid),
        .bready     (bready),

        .araddr     (araddr),
        .arvalid    (arvalid),
        .arready    (arready),

        .rdata      (rdata),
        .rresp      (rresp),
        .rvalid     (rvalid),
        .rready     (rready),

        .rf_wr_en   (rf_wr_en),
        .rf_wr_addr (rf_wr_addr),
        .rf_wr_data (rf_wr_data),

        .rf_rd_addr (rf_rd_addr),
        .rf_rd_data (rf_rd_data)
    );


  
    // REGISTER FILE
    

    aes_regfile u_regfile (
        .clk        (aclk),
        .rst_n      (aresetn),

        .wr_en      (rf_wr_en),
        .wr_addr    (rf_wr_addr),
        .wr_data    (rf_wr_data),

        .rd_addr    (rf_rd_addr),
        .rd_data    (rf_rd_data),

        .ciphertext (ciphertext),
        .enc_done   (enc_done),

        .key        (key),
        .plaintext  (plaintext),
        .start      (start),
        .key_size   (key_size)
    );


    
    // CONTROL FSM
    

    aes_fsm u_fsm (
        .clk        (aclk),
        .rst_n      (aresetn),

        .start      (start),
        .key_size   (key_size),

        .round_num  (round_num),
        .mc_enable  (mc_enable),
        .enc_done   (enc_done),
        .state_load (state_load),
        .rk_sel     (rk_sel)
    );


   
    // KEY SCHEDULE
    

    aes_keyschedule u_keyschedule (
        .key       (key),
        .round_key (round_keys)
    );

    // Select current round key
    assign current_round_key = round_keys[rk_sel];


    
    // AES DATAPATH
    // 
    //
    // Round 0:
    //     Plaintext XOR RoundKey[0]
    //
    // Rounds 1-9:
    //     SubBytes
    //     ShiftRows
    //     MixColumns
    //     AddRoundKey
    //
    // Round 10:
    //     SubBytes
    //     ShiftRows
    //     NO MixColumns
    //     AddRoundKey
    //
    // 


    
    // Select input to AES transformation
    //
    // Round 0:
    //     plaintext is used directly
    //
    // Rounds 1-10:
    //     previously registered state is used
    
    assign pipeline_input =
        (round_num == 4'd0) ?
        plaintext :
        state_reg;


    
    // SubBytes
 
    aes_subbytes u_subbytes (
        .in  (pipeline_input),
        .out (after_subbytes)
    );


   
    // ShiftRows
    
    aes_shiftrows u_shiftrows (
        .in  (after_subbytes),
        .out (after_shiftrows)
    );


    
    // MixColumns
    
    aes_mixcolumns u_mixcolumns (
        .in  (after_shiftrows),
        .out (after_mixcolumns_raw)
    );


    
    // MixColumns enable/bypass
    //
    // Round 1-9:
    //     mc_enable = 1
    //
    // Round 10:
    //     mc_enable = 0
    
    assign after_mixcolumns =
        mc_enable ?
        after_mixcolumns_raw :
        after_shiftrows;


    
    // AddRoundKey input
    //
    // For Round 0:
    //     Plaintext directly
    //
    // For Rounds 1-10:
    //     Output of previous transformation
    
    assign ark_input =
        (round_num == 4'd0) ?
        plaintext :
        after_mixcolumns;


    
    // AddRoundKey
    
    aes_addroundkey u_addroundkey (
        .state     (ark_input),
        .round_key (current_round_key),
        .out       (after_addroundkey)
    );


   
    // STATE REGISTER

    //
    // IMPORTANT FIX #1:
    //
    // During KEY_EXP:
    //
    //     state_reg <= Plaintext XOR RoundKey[0]
    //
    // NOT:
    //
    //     state_reg <= Plaintext
    //
    // This establishes the correct AES initial state.
    //
    

    always_ff @(posedge aclk or negedge aresetn) begin

        if (!aresetn) begin
            state_reg <= 128'h0;
        end

        else begin

        
            // Initial AddRoundKey
            
            if (state_load) begin

                state_reg <= after_addroundkey;

            end

            
            // Rounds 1-9
            //
            // Round 10 is captured separately below.
           
            else if (!enc_done &&
                     (round_num > 4'd0) &&
                     (round_num < 4'd10)) begin

                state_reg <= after_addroundkey;

            end

        end

    end


    
    // FINAL CIPHERTEXT REGISTER
    
    // IMPORTANT FIX #2:
    // Round 10 produces the final ciphertext.
    // Capture that value in a register so that once the FSM
    // enters DONE, the ciphertext does not pass through
    // SubBytes/ShiftRows/AddRoundKey again.
    

    always_ff @(posedge aclk or negedge aresetn) begin

        if (!aresetn) begin

            ciphertext_reg <= 128'h0;

        end

        else begin

            
            // AES-128 final round
            // round_num = 10
            // enc_done  = 0 while FINAL_ROUND is active
            
            if (!enc_done &&
                (round_num == 4'd10)) begin

                ciphertext_reg <= after_addroundkey;

            end

        end

    end


 
    // CIPHERTEXT OUTPUT
    // The register file reads this stable registered value.
    
    assign ciphertext = ciphertext_reg;


endmodule