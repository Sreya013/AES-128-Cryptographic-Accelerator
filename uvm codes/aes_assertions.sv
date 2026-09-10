
// File    : aes_assertions.sv
// Project : AES-128 UVM Verification
// Purpose : SystemVerilog Assertions
//           Continuous property checking
//           Catches protocol and timing bugs


`ifndef AES_ASSERTIONS_SV
`define AES_ASSERTIONS_SV

module aes_assertions (
    input logic        aclk,
    input logic        aresetn,

    // AXI4-Lite signals to check
    input logic        awvalid,
    input logic        awready,
    input logic        wvalid,
    input logic        wready,
    input logic        bvalid,
    input logic        bready,
    input logic        arvalid,
    input logic        arready,
    input logic        rvalid,
    input logic        rready,

    // AES specific signals
    input logic        enc_done
);

    
    // Default clocking for all assertions
  
    default clocking cb @(posedge aclk);
    endclocking

    // Assertion 1 — Reset Check
    // During reset (aresetn=0) all outputs must be 0
    // awready, wready, bvalid, arready, rvalid must be low
   
    property p_reset_outputs;
        !aresetn |->
        (!awready && !wready && !bvalid &&
         !arready && !rvalid && !enc_done);
    endproperty

    a_reset_outputs: assert property (p_reset_outputs)
    else `uvm_error("ASSERTION",
        "AXI outputs not zero during reset!")

    // Assertion 2 — awready stability
    // awready must only be high when aresetn is high
   
    property p_awready_no_reset;
        !aresetn |-> !awready;
    endproperty

    a_awready_no_reset: assert property (p_awready_no_reset)
    else `uvm_error("ASSERTION",
        "awready high during reset!")

   
    // Assertion 3 — rvalid stability
    // rvalid must only be high when aresetn is high
  
    property p_rvalid_no_reset;
        !aresetn |-> !rvalid;
    endproperty

    a_rvalid_no_reset: assert property (p_rvalid_no_reset)
    else `uvm_error("ASSERTION",
        "rvalid high during reset!")

   
    // Assertion 4 — enc_done during reset
    // enc_done must never be high during reset
    
    property p_done_no_reset;
        !aresetn |-> !enc_done;
    endproperty

    a_done_no_reset: assert property (p_done_no_reset)
    else `uvm_error("ASSERTION",
        "enc_done high during reset!")

    // Assertion 5 — AXI write handshake
    // awready must eventually go high after awvalid
    // Within 10 clock cycles
    
    property p_aw_handshake;
        awvalid |-> ##[1:10] awready;
    endproperty

    a_aw_handshake: assert property (p_aw_handshake)
    else `uvm_error("ASSERTION",
        "awready did not respond within 10 cycles!")

   
    // Assertion 6 — AXI read handshake
    // arready must eventually go high after arvalid
    // Within 10 clock cycles
  
    property p_ar_handshake;
        arvalid |-> ##[1:10] arready;
    endproperty

    a_ar_handshake: assert property (p_ar_handshake)
    else `uvm_error("ASSERTION",
        "arready did not respond within 10 cycles!")

  
    // Assertion 7 — bvalid after write
    // After write handshake, bvalid must appear
    // Within 5 cycles
  
    property p_bvalid_after_write;
        (awvalid && awready) |-> ##[1:5] bvalid;
    endproperty

    a_bvalid_after_write: assert property (p_bvalid_after_write)
    else `uvm_error("ASSERTION",
        "bvalid did not appear after write!")

    // Cover properties
    // Track that certain scenarios actually happen
  
    c_enc_done: cover property (
        @(posedge aclk) enc_done);

    c_write_handshake: cover property (
        @(posedge aclk) (awvalid && awready));

    c_read_handshake: cover property (
        @(posedge aclk) (arvalid && arready));

endmodule

`endif