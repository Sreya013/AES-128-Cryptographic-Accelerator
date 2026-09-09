
// Module  : tb_regfile
// Project : AES-128/256 Crypto Accelerator
// Purpose : Testbench for aes_regfile module

`timescale 1ns/1ps
module tb_regfile;

    // Signals
    logic        clk;
    logic        rst_n;
    logic        wr_en;
    logic [7:0]  wr_addr;
    logic [31:0] wr_data;
    logic [7:0]  rd_addr;
    logic [31:0] rd_data;
    logic [127:0] ciphertext;
    logic         enc_done;
    logic [127:0] key;
    logic [127:0] plaintext;
    logic         start;
    logic         key_size;

    // Instantiate Register File
    aes_regfile uut (
        .clk        (clk),
        .rst_n      (rst_n),
        .wr_en      (wr_en),
        .wr_addr    (wr_addr),
        .wr_data    (wr_data),
        .rd_addr    (rd_addr),
        .rd_data    (rd_data),
        .ciphertext (ciphertext),
        .enc_done   (enc_done),
        .key        (key),
        .plaintext  (plaintext),
        .start      (start),
        .key_size   (key_size)
    );

    // Clock — 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Task to write a register
    task write_reg;
        input [7:0]  addr;
        input [31:0] data;
        begin
            @(posedge clk); #1;
            wr_en   = 1;
            wr_addr = addr;
            wr_data = data;
            @(posedge clk); #1;
            wr_en   = 0;
        end
    endtask

    // Task to read a register
    task read_reg;
        input  [7:0]  addr;
        output [31:0] data;
        begin
            rd_addr = addr;
            #1;
            data = rd_data;
        end
    endtask

    logic [31:0] rdata;

    initial begin
      
        $display("AES Register File Verification Test");
       

        // Initialize
        rst_n      = 0;
        wr_en      = 0;
        wr_addr    = 0;
        wr_data    = 0;
        rd_addr    = 0;
        ciphertext = 0;
        enc_done   = 0;

        // Apply reset
        @(posedge clk); #1;
        @(posedge clk); #1;
        rst_n = 1;
        @(posedge clk); #1;

       
        // Test 1 — Write and read KEY registers
      
        $display("Test 1 — Writing KEY registers");
        write_reg(8'h08, 32'h2B7E1516);
        write_reg(8'h0C, 32'h28AED2A6);
        write_reg(8'h10, 32'hABF71588);
        write_reg(8'h14, 32'h09CF4F3C);

        @(posedge clk); #1;
        if (key == 128'h2B7E151628AED2A6ABF7158809CF4F3C)
            $display("PASS  Key assembled correctly: %032X", key);
        else
            $display("FAIL  Key incorrect: %032X", key);

        // Verify KEY reads back as 0 (write only)
        read_reg(8'h08, rdata);
        if (rdata == 32'h0)
            $display("PASS  KEY[0] read = 0 (write only protected)");
        else
            $display("FAIL  KEY[0] should read 0, got %08X", rdata);

        
        // Test 2 — Write PLAINTEXT registers
     
        $display("Test 2 — Writing PLAINTEXT registers");
        write_reg(8'h28, 32'h3243F6A8);
        write_reg(8'h2C, 32'h885A308D);
        write_reg(8'h30, 32'h313198A2);
        write_reg(8'h34, 32'hE0370734);

        @(posedge clk); #1;
        if (plaintext == 128'h3243F6A8885A308D313198A2E0370734)
            $display("PASS  Plaintext assembled: %032X", plaintext);
        else
            $display("FAIL  Plaintext incorrect: %032X", plaintext);

        
        // Test 3 — Write CTRL register, check start
    
        $display("Test 3 — CTRL register start bit");
        write_reg(8'h00, 32'h00000001); // start = 1

        // Start should pulse for 1 cycle
        @(posedge clk); #1;
        $display("Start signal = %b (should be 1)", start);

        @(posedge clk); #1;
        $display("Start signal = %b (should be 0 auto cleared)", start);

    
        $display("Test 4 — Hardware writes ciphertext");
        ciphertext = 128'h3925841D02DC09FBDC118597196A0B32;
        enc_done   = 1;
        @(posedge clk); #1;
        enc_done = 0;
        @(posedge clk); #1;

        // Read STATUS — should show done = 1
        read_reg(8'h04, rdata);
        if (rdata[0] == 1'b1)
            $display("PASS  STATUS done bit = 1");
        else
            $display("FAIL  STATUS done bit not set");

        // Read CIPHERTEXT registers
        read_reg(8'h38, rdata);
        if (rdata == 32'h3925841D)
            $display("PASS  CT[0] = %08X", rdata);
        else
            $display("FAIL  CT[0] = %08X expected 3925841D", rdata);

        read_reg(8'h3C, rdata);
        if (rdata == 32'h02DC09FB)
            $display("PASS  CT[1] = %08X", rdata);
        else
            $display("FAIL  CT[1] = %08X expected 02DC09FB", rdata);

        read_reg(8'h40, rdata);
        if (rdata == 32'hDC118597)
            $display("PASS  CT[2] = %08X", rdata);
        else
            $display("FAIL  CT[2] = %08X expected DC118597", rdata);

        read_reg(8'h44, rdata);
        if (rdata == 32'h196A0B32)
            $display("PASS  CT[3] = %08X", rdata);
        else
            $display("FAIL  CT[3] = %08X expected 196A0B32", rdata);

        
        // Test 5 — Invalid address returns DEADBEEF
        
       
        $display("Test 5 — Invalid address decode");
        read_reg(8'hFF, rdata);
        if (rdata == 32'hDEADBEEF)
            $display("PASS  Invalid addr = DEADBEEF");
        else
            $display("FAIL  Invalid addr = %08X", rdata);

       
        $display("All Tests Complete");
        

        #20;
        $finish;
    end

endmodule