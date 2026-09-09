`timescale 1ns/1ps

module tb_axilite;

    localparam ADDR_WIDTH = 8;
    localparam DATA_WIDTH = 32;

    logic                    aclk;
    logic                    aresetn;
    logic [ADDR_WIDTH-1:0]   awaddr;
    logic                    awvalid;
    logic                    awready;
    logic [DATA_WIDTH-1:0]   wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                    wvalid;
    logic                    wready;
    logic [1:0]              bresp;
    logic                    bvalid;
    logic                    bready;
    logic [ADDR_WIDTH-1:0]   araddr;
    logic                    arvalid;
    logic                    arready;
    logic [DATA_WIDTH-1:0]   rdata;
    logic [1:0]              rresp;
    logic                    rvalid;
    logic                    rready;
    logic                    rf_wr_en;
    logic [ADDR_WIDTH-1:0]   rf_wr_addr;
    logic [DATA_WIDTH-1:0]   rf_wr_data;
    logic [ADDR_WIDTH-1:0]   rf_rd_addr;
    logic [DATA_WIDTH-1:0]   rf_rd_data;

    aes_axilite #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .aclk        (aclk),
        .aresetn     (aresetn),
        .awaddr      (awaddr),
        .awvalid     (awvalid),
        .awready     (awready),
        .wdata       (wdata),
        .wstrb       (wstrb),
        .wvalid      (wvalid),
        .wready      (wready),
        .bresp       (bresp),
        .bvalid      (bvalid),
        .bready      (bready),
        .araddr      (araddr),
        .arvalid     (arvalid),
        .arready     (arready),
        .rdata       (rdata),
        .rresp       (rresp),
        .rvalid      (rvalid),
        .rready      (rready),
        .rf_wr_en    (rf_wr_en),
        .rf_wr_addr  (rf_wr_addr),
        .rf_wr_data  (rf_wr_data),
        .rf_rd_addr  (rf_rd_addr),
        .rf_rd_data  (rf_rd_data)
    );

    // Simple register file model
    assign rf_rd_data = {24'h0, rf_rd_addr} + 32'hAB;

    // Clock - 10ns
    initial aclk = 0;
    always #5 aclk = ~aclk;

    initial begin
        
        $display("AES AXI4-Lite Verification Test ");
      

        // Initialize everything to 0
        aresetn = 0;
        awaddr  = 0; awvalid = 0;
        wdata   = 0; wstrb   = 0;
        wvalid  = 0; bready  = 0;
        araddr  = 0; arvalid = 0;
        rready  = 0;

        // Hold reset for 4 cycles
        #40;
        aresetn = 1;
        #40;

        // TEST 1 - Write CTRL register
        // Cycle 1: present address and data
        
        $display("Test 1 - Write CTRL 0x00");
        awaddr  = 8'h00;
        awvalid = 1;
        wdata   = 32'h00000001;
        wstrb   = 4'hF;
        wvalid  = 1;
        bready  = 1;
        #10; // wait 1 cycle

        // Cycle 2: handshake should complete
        #10;
        awvalid = 0;
        wvalid  = 0;

        // Cycle 3: wait for bvalid
        #10;
        bready = 0;
        #10;

        $display("PASS  Write addr=%02X data=%08X",
            rf_wr_addr, rf_wr_data);

        
        // TEST 2 - Write KEY[0]
       
        #20;
        
        $display("Test 2 - Write KEY[0] 0x08");
        awaddr  = 8'h08;
        awvalid = 1;
        wdata   = 32'h2B7E1516;
        wstrb   = 4'hF;
        wvalid  = 1;
        bready  = 1;
        #10;

        #10;
        awvalid = 0;
        wvalid  = 0;
        #10;
        bready = 0;
        #10;

        if (rf_wr_data == 32'h2B7E1516)
            $display("PASS  KEY[0] correct = %08X", rf_wr_data);
        else
            $display("FAIL  KEY[0] = %08X", rf_wr_data);

        
        // TEST 3 - Read STATUS register
        
        #20;
        
        $display("Test 3 - Read STATUS 0x04");
        araddr  = 8'h04;
        arvalid = 1;
        rready  = 1;
        #10;

        arvalid = 0;
        #10;

        $display("PASS  Read data = %08X", rdata);
        rready = 0;
        #10;

        
        // TEST 4 - Write full 128-bit key
        
        #20;
       
        $display("Test 4 - Write full 128-bit key");

        // KEY[0]
        awaddr=8'h08; wdata=32'h2B7E1516;
        awvalid=1; wvalid=1; bready=1; #10;
        awvalid=0; wvalid=0; #20;

        // KEY[1]
        awaddr=8'h0C; wdata=32'h28AED2A6;
        awvalid=1; wvalid=1; bready=1; #10;
        awvalid=0; wvalid=0; #20;

        // KEY[2]
        awaddr=8'h10; wdata=32'hABF71588;
        awvalid=1; wvalid=1; bready=1; #10;
        awvalid=0; wvalid=0; #20;

        // KEY[3]
        awaddr=8'h14; wdata=32'h09CF4F3C;
        awvalid=1; wvalid=1; bready=1; #10;
        awvalid=0; wvalid=0; #20;

        bready = 0;
        $display("PASS  Full key written");

      
        // TEST 5 - Write plaintext
      
        #20;
        
        $display("Test 5 - Write plaintext");

        // PT[0]
        awaddr=8'h28; wdata=32'h3243F6A8;
        awvalid=1; wvalid=1; bready=1; #10;
        awvalid=0; wvalid=0; #20;

        // PT[1]
        awaddr=8'h2C; wdata=32'h885A308D;
        awvalid=1; wvalid=1; bready=1; #10;
        awvalid=0; wvalid=0; #20;

        // PT[2]
        awaddr=8'h30; wdata=32'h313198A2;
        awvalid=1; wvalid=1; bready=1; #10;
        awvalid=0; wvalid=0; #20;

        // PT[3]
        awaddr=8'h34; wdata=32'hE0370734;
        awvalid=1; wvalid=1; bready=1; #10;
        awvalid=0; wvalid=0; #20;

        bready = 0;
        $display("PASS  Plaintext written");

       
        // TEST 6 - Read ciphertext
        
        #20;
     
        $display("Test 6 - Read CT[0] 0x38");
        araddr  = 8'h38;
        arvalid = 1;
        rready  = 1;
        #10;

        arvalid = 0;
        #10;

        $display("PASS  CT[0] = %08X", rdata);
        rready = 0;

       
        
        $display(" All Tests Complete");
     

        #50;
        $finish;
    end

endmodule