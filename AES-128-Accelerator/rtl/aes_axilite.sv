`timescale 1ns/1ps

module aes_axilite #(
    parameter ADDR_WIDTH = 8,
    parameter DATA_WIDTH = 32
)(
    input  logic                    aclk,
    input  logic                    aresetn,

    // Write Address Channel
    input  logic [ADDR_WIDTH-1:0]   awaddr,
    input  logic                    awvalid,
    output logic                    awready,

    // Write Data Channel
    input  logic [DATA_WIDTH-1:0]   wdata,
    input  logic [DATA_WIDTH/8-1:0] wstrb,
    input  logic                    wvalid,
    output logic                    wready,

    // Write Response Channel
    output logic [1:0]              bresp,
    output logic                    bvalid,
    input  logic                    bready,

    // Read Address Channel
    input  logic [ADDR_WIDTH-1:0]   araddr,
    input  logic                    arvalid,
    output logic                    arready,

    // Read Data Channel
    output logic [DATA_WIDTH-1:0]   rdata,
    output logic [1:0]              rresp,
    output logic                    rvalid,
    input  logic                    rready,

    // Register File interface
    output logic                    rf_wr_en,
    output logic [ADDR_WIDTH-1:0]   rf_wr_addr,
    output logic [DATA_WIDTH-1:0]   rf_wr_data,
    output logic [ADDR_WIDTH-1:0]   rf_rd_addr,
    input  logic [DATA_WIDTH-1:0]   rf_rd_data
);

   
    // Write path - fully combinational
    // Accept immediately when both valid
   
    assign awready    = aresetn & awvalid & wvalid & ~bvalid;
    assign wready     = aresetn & awvalid & wvalid & ~bvalid;
    assign rf_wr_en   = awvalid & wvalid & ~bvalid;
    assign rf_wr_addr = awaddr;
    assign rf_wr_data = wdata;
    assign bresp      = 2'b00;

    // Write response register
    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn)
            bvalid <= 1'b0;
        else if (awvalid && wvalid && !bvalid)
            bvalid <= 1'b1;
        else if (bvalid && bready)
            bvalid <= 1'b0;
    end

    // Read path - combinational address, registered data
    
    assign arready    = aresetn & arvalid & ~rvalid;
    assign rf_rd_addr = araddr;
    assign rresp      = 2'b00;

    always_ff @(posedge aclk or negedge aresetn) begin
        if (!aresetn) begin
            rvalid <= 1'b0;
            rdata  <= '0;
        end
        else if (arvalid && !rvalid) begin
            rvalid <= 1'b1;
            rdata  <= rf_rd_data;
        end
        else if (rvalid && rready) begin
            rvalid <= 1'b0;
        end
    end

endmodule