
// File    : aes_driver.sv
// Project : AES-128 UVM Verification
// Purpose : UVM Driver
//           Receives transactions from sequencer
//           Converts to AXI4-Lite signal operations
//           Drives DUT through virtual interface


`ifndef AES_DRIVER_SV
`define AES_DRIVER_SV

class aes_driver extends uvm_driver #(aes_transaction);

    
    // Register with UVM factory
    
    `uvm_component_utils(aes_driver)

  
    // Virtual interface handle
    // Points to actual interface in tb_top
   
    virtual aes_if vif;

    // Constructor
    
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

   
    // build_phase
    // Get virtual interface from config database
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Get interface handle from config database
        // tb_top posted it there at simulation start
        if (!uvm_config_db #(virtual aes_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("DRIVER",
                "Cannot get virtual interface from config db")
    endfunction

    
    // run_phase
    // Main driver loop
    // Runs forever — gets transaction, drives, repeat
    
    task run_phase(uvm_phase phase);
        // Initialize all signals to safe state
        reset_dut();

        // Wait for reset to complete
        @(posedge vif.aclk);
        wait(vif.aresetn === 1'b1);
        repeat(2) @(posedge vif.aclk);

        // Forever loop — keep driving transactions
        forever begin
            aes_transaction tx;

            // Get next transaction from sequencer
            seq_item_port.get_next_item(tx);

            // Drive transaction to DUT
            drive_transaction(tx);

            // Tell sequencer this transaction is done
            seq_item_port.item_done();
        end
    endtask

    
    // Task: reset_dut
    // Set all driven signals to 0
    
    task reset_dut();
        vif.drv_cb.awaddr  <= 8'h00;
        vif.drv_cb.awvalid <= 1'b0;
        vif.drv_cb.wdata   <= 32'h0;
        vif.drv_cb.wstrb   <= 4'h0;
        vif.drv_cb.wvalid  <= 1'b0;
        vif.drv_cb.bready  <= 1'b0;
        vif.drv_cb.araddr  <= 8'h00;
        vif.drv_cb.arvalid <= 1'b0;
        vif.drv_cb.rready  <= 1'b0;
    endtask

 
    // Task: drive_transaction
    // Converts one transaction into AXI4-Lite operations
    
    task drive_transaction(aes_transaction tx);

        // Step 1 — Write KEY registers
        axi_write(8'h08, tx.key[127:96]);
        axi_write(8'h0C, tx.key[95:64]);
        axi_write(8'h10, tx.key[63:32]);
        axi_write(8'h14, tx.key[31:0]);

        // Step 2 — Write PLAINTEXT registers
        axi_write(8'h28, tx.plaintext[127:96]);
        axi_write(8'h2C, tx.plaintext[95:64]);
        axi_write(8'h30, tx.plaintext[63:32]);
        axi_write(8'h34, tx.plaintext[31:0]);

        // Step 3 — Write CTRL register to start encryption
        axi_write(8'h00, 32'h00000001);

        // Step 4 — Wait for encryption to complete
        wait_for_done();

        // Step 5 — Read CIPHERTEXT registers
        axi_read(8'h38, tx.ciphertext[127:96]);
        axi_read(8'h3C, tx.ciphertext[95:64]);
        axi_read(8'h40, tx.ciphertext[63:32]);
        axi_read(8'h44, tx.ciphertext[31:0]);

    endtask

    
    // Task: wait_for_done
    // Poll STATUS register until done bit = 1
    
    task wait_for_done();
        logic [31:0] status;
        int timeout = 0;

        do begin
            axi_read(8'h04, status);
            timeout++;
            if (timeout > 1000)
                `uvm_fatal("DRIVER",
                    "Timeout waiting for enc_done!")
        end while (status[0] !== 1'b1);
    endtask

   
    // Task: axi_write
    // One complete AXI4-Lite write transaction
  
    task axi_write(
        input logic [7:0]  addr,
        input logic [31:0] data
    );
        // Present address and data together
        @(vif.drv_cb);
        vif.drv_cb.awaddr  <= addr;
        vif.drv_cb.awvalid <= 1'b1;
        vif.drv_cb.wdata   <= data;
        vif.drv_cb.wstrb   <= 4'hF;
        vif.drv_cb.wvalid  <= 1'b1;
        vif.drv_cb.bready  <= 1'b1;

        // Wait for handshake
        @(vif.drv_cb);
        vif.drv_cb.awvalid <= 1'b0;
        vif.drv_cb.wvalid  <= 1'b0;

        // Wait for response
        @(vif.drv_cb);
        vif.drv_cb.bready  <= 1'b0;

        // Small gap between transactions
        repeat(2) @(vif.drv_cb);
    endtask

   
    // Task: axi_read
    // One complete AXI4-Lite read transaction
 
    task axi_read(
        input  logic [7:0]  addr,
        output logic [31:0] data
    );
        // Present read address
        @(vif.drv_cb);
        vif.drv_cb.araddr  <= addr;
        vif.drv_cb.arvalid <= 1'b1;
        vif.drv_cb.rready  <= 1'b1;

        // Wait for address handshake
        @(vif.drv_cb);
        vif.drv_cb.arvalid <= 1'b0;

        // Wait for data
        @(vif.drv_cb);
        data = vif.drv_cb.rdata;
        vif.drv_cb.rready  <= 1'b0;

        // Small gap
        repeat(2) @(vif.drv_cb);
    endtask

endclass

`endif