
// File    : aes_if.sv
// Project : AES-128 UVM Verification
// Purpose : SystemVerilog Interface
//           Bundles all AXI4-Lite signals
//           Bridge between DUT and UVM testbench


`ifndef AES_IF_SV
`define AES_IF_SV

interface aes_if (
    input logic aclk,
    input logic aresetn
);

    // AXI4-Lite Write Address Channel
   
    logic [7:0]  awaddr;
    logic        awvalid;
    logic        awready;

    // AXI4-Lite Write Data Channel
   
    logic [31:0] wdata;
    logic [3:0]  wstrb;
    logic        wvalid;
    logic        wready;

    // AXI4-Lite Write Response Channel
    logic [1:0]  bresp;
    logic        bvalid;
    logic        bready;

    
    // AXI4-Lite Read Address Channel
    
    logic [7:0]  araddr;
    logic        arvalid;
    logic        arready;

    
    // AXI4-Lite Read Data Channel
   
    logic [31:0] rdata;
    logic [1:0]  rresp;
    logic        rvalid;
    logic        rready;

  -
    // Clocking Block — Driver View
    // Driver drives outputs, reads inputs
    // #1 = drive/sample 1ns after clock edge
    // Prevents race conditions
  
    clocking drv_cb @(posedge aclk);
        default input #1 output #1;
        output awaddr;
        output awvalid;
        output wdata;
        output wstrb;
        output wvalid;
        output bready;
        output araddr;
        output arvalid;
        output rready;
        input  awready;
        input  wready;
        input  bvalid;
        input  bresp;
        input  arready;
        input  rvalid;
        input  rdata;
        input  rresp;
    endclocking

    // Clocking Block — Monitor View
    // Monitor only observes — never drives
  
    clocking mon_cb @(posedge aclk);
        default input #1;
        input awaddr;
        input awvalid;
        input awready;
        input wdata;
        input wstrb;
        input wvalid;
        input wready;
        input bresp;
        input bvalid;
        input bready;
        input araddr;
        input arvalid;
        input arready;
        input rdata;
        input rresp;
        input rvalid;
        input rready;
    endclocking

    // --------------------------------------------------------
    // Modport — Driver
    // --------------------------------------------------------
    modport driver_mp (
        clocking drv_cb,
        input    aclk,
        input    aresetn
    );

    // --------------------------------------------------------
    // Modport — Monitor
    // --------------------------------------------------------
    modport monitor_mp (
        clocking mon_cb,
        input    aclk,
        input    aresetn
    );

   
    // Task — Reset all driven signals to safe defaults
    // Called at start of simulation before DUT starts
   
    task reset_signals();
        drv_cb.awaddr  <= 8'h00;
        drv_cb.awvalid <= 1'b0;
        drv_cb.wdata   <= 32'h0;
        drv_cb.wstrb   <= 4'h0;
        drv_cb.wvalid  <= 1'b0;
        drv_cb.bready  <= 1'b0;
        drv_cb.araddr  <= 8'h00;
        drv_cb.arvalid <= 1'b0;
        drv_cb.rready  <= 1'b0;
    endtask

endinterface

`endif