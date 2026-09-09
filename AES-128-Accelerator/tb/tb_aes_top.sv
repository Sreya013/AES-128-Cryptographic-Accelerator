
// Module  : tb_aes_top
// Project : AES-128/256 Crypto Accelerator
// Purpose : Full system testbench
//           Verifies complete AES-128 encryption
//           Uses NIST FIPS 197 test vectors
//           Plaintext + Key → must produce correct Ciphertext


`timescale 1ns/1ps

module tb_aes_top;

    localparam ADDR_WIDTH = 8;
    localparam DATA_WIDTH = 32;

    // Global
    logic                    aclk;
    logic                    aresetn;

    // AXI4-Lite Write Address
    logic [ADDR_WIDTH-1:0]   awaddr;
    logic                    awvalid;
    logic                    awready;

    // AXI4-Lite Write Data
    logic [DATA_WIDTH-1:0]   wdata;
    logic [DATA_WIDTH/8-1:0] wstrb;
    logic                    wvalid;
    logic                    wready;

    // AXI4-Lite Write Response
    logic [1:0]              bresp;
    logic                    bvalid;
    logic                    bready;

    // AXI4-Lite Read Address
    logic [ADDR_WIDTH-1:0]   araddr;
    logic                    arvalid;
    logic                    arready;

    // AXI4-Lite Read Data
    logic [DATA_WIDTH-1:0]   rdata;
    logic [1:0]              rresp;
    logic                    rvalid;
    logic                    rready;

    // Instantiate top level
    aes_top #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(DATA_WIDTH)
    ) uut (
        .aclk    (aclk),
        .aresetn (aresetn),
        .awaddr  (awaddr),   .awvalid (awvalid),
        .awready (awready),  .wdata   (wdata),
        .wstrb   (wstrb),    .wvalid  (wvalid),
        .wready  (wready),   .bresp   (bresp),
        .bvalid  (bvalid),   .bready  (bready),
        .araddr  (araddr),   .arvalid (arvalid),
        .arready (arready),  .rdata   (rdata),
        .rresp   (rresp),    .rvalid  (rvalid),
        .rready  (rready)
    );

    // Clock — 10ns period = 100MHz
    initial aclk = 0;
    always #5 aclk = ~aclk;


    // Write register task
    task write_reg;
        input [ADDR_WIDTH-1:0] addr;
        input [DATA_WIDTH-1:0] data;
        begin
            awaddr  = addr;
            awvalid = 1;
            wdata   = data;
            wstrb   = 4'hF;
            wvalid  = 1;
            bready  = 1;
            #10;
            awvalid = 0;
            wvalid  = 0;
            #20;
            bready  = 0;
            #10;
        end
    endtask


    // Read register task
  
    task read_reg;
        input  [ADDR_WIDTH-1:0] addr;
        output [DATA_WIDTH-1:0] data;
        begin
            araddr  = addr;
            arvalid = 1;
            rready  = 1;
            #10;
            arvalid = 0;
            #20;
            data   = rdata;
            rready = 0;
            #10;
        end
    endtask

    logic [31:0] rd;
    logic [127:0] result;

    initial begin
        $display("=========================================");
        $display("   AES-128 Full System Verification      ");
        $display("=========================================");
        $display("NIST FIPS 197 Test Vector:");
        $display("Plaintext : 3243F6A8885A308D313198A2E0370734");
        $display("Key       : 2B7E151628AED2A6ABF7158809CF4F3C");
        $display("Expected  : 3925841D02DC09FBDC118597196A0B32");
        $display("=========================================");

        // Initialize
        aresetn = 0;
        awaddr=0; awvalid=0;
        wdata=0;  wstrb=0; wvalid=0;
        bready=0;
        araddr=0; arvalid=0;
        rready=0;

        // Reset
        #50;
        aresetn = 1;
        #50;

        
        // Step 1 — Write Key
        // Key = 2B7E1516 28AED2A6 ABF71588 09CF4F3C
        
        $display("Step 1 — Loading Key...");
        write_reg(8'h08, 32'h2B7E1516);
        write_reg(8'h0C, 32'h28AED2A6);
        write_reg(8'h10, 32'hABF71588);
        write_reg(8'h14, 32'h09CF4F3C);
        $display("Key loaded.");

        
        // Step 2 — Write Plaintext
        // PT = 3243F6A8 885A308D 313198A2 E0370734
      
        $display("Step 2 — Loading Plaintext...");
        write_reg(8'h28, 32'h3243F6A8);
        write_reg(8'h2C, 32'h885A308D);
        write_reg(8'h30, 32'h313198A2);
        write_reg(8'h34, 32'hE0370734);
        $display("Plaintext loaded.");

        
        // Step 3 — Write CTRL to start encryption
        // CTRL bit0 = 1 → start
        // CTRL bit1 = 0 → AES-128
       
        $display("Step 3 — Starting Encryption...");
        write_reg(8'h00, 32'h00000001);

    
        // Step 4 — Wait for encryption to complete
        // AES-128 needs about 15 clock cycles
        // Give it 500ns to be safe
     
        $display("Step 4 — Waiting for encryption...");
        #500;

        
        // Step 5 — Poll STATUS register
        // Wait until done bit = 1
        
        $display("Step 5 — Checking STATUS...");
        read_reg(8'h04, rd);
        $display("STATUS = %08X (bit0=done)", rd);

        if (rd[0] == 1'b1)
            $display("PASS  Encryption complete!");
        else
            $display("INFO  Still processing...");

        // Wait more if needed
        #200;
        read_reg(8'h04, rd);
        $display("STATUS = %08X", rd);

      
        // Step 6 — Read Ciphertext
        
        $display("Step 6 — Reading Ciphertext...");
        read_reg(8'h38, rd);
        result[127:96] = rd;
        $display("CT[0] = %08X", rd);

        read_reg(8'h3C, rd);
        result[95:64] = rd;
        $display("CT[1] = %08X", rd);

        read_reg(8'h40, rd);
        result[63:32] = rd;
        $display("CT[2] = %08X", rd);

        read_reg(8'h44, rd);
        result[31:0] = rd;
        $display("CT[3] = %08X", rd);

    
        // Step 7 — Compare with expected
       
        $display("Result   : %032X", result);
        $display("Expected : 3925841d02dc09fbdc118597196a0b32");

        if (result == 128'h3925841D02DC09FBDC118597196A0B32) begin
            $display("   FULL AES-128 ENCRYPTION VERIFIED!  ");
            $display("  RTL matches NIST FIPS 197 exactly!    ");
        end
        else begin
            $display("MISMATCH — checking individual bytes...");
            $display("Got      : %032X", result);
            $display("Expected : 3925841D02DC09FBDC118597196A0B32");
        end

        #100;
        $finish;
    end

endmodule