
// File    : tb_top.sv
// Project : AES-128 UVM Verification
// Purpose : Top level testbench module
//           Only module in UVM environment
//           Creates clock, reset, interface
//           Instantiates DUT
//           Starts UVM test


`timescale 1ns/1ps

// Include all UVM files
`include "uvm_macros.svh"
import uvm_pkg::*;

// Include all project files
`include "aes_if.sv"
`include "aes_transaction.sv"
`include "aes_ref_model.sv"
`include "aes_scoreboard.sv"
`include "aes_driver.sv"
`include "aes_monitor.sv"
`include "aes_sequencer.sv"
`include "aes_sequence.sv"
`include "aes_agent.sv"
`include "aes_env.sv"
`include "aes_test.sv"


module tb_top;

   
    // Clock and Reset signals
  
    logic aclk;
    logic aresetn;

    // Interface instance
    // Shared between DUT and UVM components
    
    aes_if dut_if (
        .aclk    (aclk),
        .aresetn (aresetn)
    );

    // DUT instantiation
    // Connect DUT ports to interface signals
   
    aes_top #(
        .ADDR_WIDTH(8),
        .DATA_WIDTH(32)
    ) dut (
        .aclk    (aclk),
        .aresetn (aresetn),

        // Write Address Channel
        .awaddr  (dut_if.awaddr),
        .awvalid (dut_if.awvalid),
        .awready (dut_if.awready),

        // Write Data Channel
        .wdata   (dut_if.wdata),
        .wstrb   (dut_if.wstrb),
        .wvalid  (dut_if.wvalid),
        .wready  (dut_if.wready),

        // Write Response Channel
        .bresp   (dut_if.bresp),
        .bvalid  (dut_if.bvalid),
        .bready  (dut_if.bready),

        // Read Address Channel
        .araddr  (dut_if.araddr),
        .arvalid (dut_if.arvalid),
        .arready (dut_if.arready),

        // Read Data Channel
        .rdata   (dut_if.rdata),
        .rresp   (dut_if.rresp),
        .rvalid  (dut_if.rvalid),
        .rready  (dut_if.rready)
    );
  
  // Assertions block

/*aes_assertions u_assertions (
    .aclk    (aclk),
    .aresetn (aresetn),
    .awvalid (dut_if.awvalid),
    .awready (dut_if.awready),
    .wvalid  (dut_if.wvalid),
    .wready  (dut_if.wready),
    .bvalid  (dut_if.bvalid),
    .bready  (dut_if.bready),
    .arvalid (dut_if.arvalid),
    .arready (dut_if.arready),
    .rvalid  (dut_if.rvalid),
    .rready  (dut_if.rready),
    .enc_done(dut.u_fsm.enc_done)
);*/

   
    // Clock generation — 10ns period = 100MHz

    initial aclk = 0;
    always #5 aclk = ~aclk;

   
    // Reset generation
    // Assert reset for 10 cycles then release
   
    initial begin
        aresetn = 1'b0;
        repeat(10) @(posedge aclk);
        aresetn = 1'b1;
        `uvm_info("TB_TOP",
            "Reset released — simulation starting",
            UVM_NONE)
    end

   
    // UVM Setup and Launch
  
    initial begin
        // Post interface to config database
        // All UVM components retrieve it from here
        uvm_config_db #(virtual aes_if)::set(
            null,    // context (null = global)
            "*",     // target (all components)
            "vif",   // name used to retrieve
            dut_if   // actual interface handle
        );

        // Start UVM test
        // Test name passed via +UVM_TESTNAME plusarg
        // or hardcoded here for EDA Playground
        run_test("aes_full_test");
    end

 
    // Timeout watchdog
    // Kills simulation if it runs too long
    // Prevents infinite loops
 
    initial begin
        #1_000_000;
        `uvm_fatal("TB_TOP",
            "SIMULATION TIMEOUT — check for deadlock!")
    end
initial begin
    $dumpfile("dump.vcd");

    $dumpvars(0, tb_top.aclk);
    $dumpvars(0, tb_top.aresetn);

    $dumpvars(0, tb_top.dut_if.awaddr);
    $dumpvars(0, tb_top.dut_if.awvalid);
    $dumpvars(0, tb_top.dut_if.awready);

    $dumpvars(0, tb_top.dut_if.wdata);
    $dumpvars(0, tb_top.dut_if.wvalid);
    $dumpvars(0, tb_top.dut_if.wready);

    $dumpvars(0, tb_top.dut_if.bvalid);
    $dumpvars(0, tb_top.dut_if.bready);

    $dumpvars(0, tb_top.dut_if.araddr);
    $dumpvars(0, tb_top.dut_if.arvalid);
    $dumpvars(0, tb_top.dut_if.arready);

    $dumpvars(0, tb_top.dut_if.rdata);
    $dumpvars(0, tb_top.dut_if.rvalid);
    $dumpvars(0, tb_top.dut_if.rready);
    
   $dumpvars(0,tb_top.dut.u_fsm.enc_done);
end

endmodule