
// File    : aes_monitor.sv
// Project : AES-128 UVM Verification
// Purpose : UVM Monitor
//           Passively observes AXI4-Lite interface
//           Reconstructs AES transactions
//           Sends to scoreboard via analysis port
`ifndef AES_MONITOR_SV
`define AES_MONITOR_SV

class aes_monitor extends uvm_monitor;

    // Register with UVM factory
    
    `uvm_component_utils(aes_monitor)

    
    // Virtual interface — read only view
 
    virtual aes_if vif;

    
    // Analysis port — sends transactions to scoreboard
    
    uvm_analysis_port #(aes_transaction) ap;

   
    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // build_phase
    // Create analysis port
    // Get virtual interface

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create analysis port
        ap = new("ap", this);

        // Get virtual interface from config database
        if (!uvm_config_db #(virtual aes_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("MONITOR",
                "Cannot get virtual interface!")
    endfunction

    
    // run_phase
    // Main monitor loop
    // Runs forever observing interface
    task run_phase(uvm_phase phase);
        // Wait for reset to complete
        @(posedge vif.aclk);
        wait(vif.aresetn === 1'b1);
        repeat(2) @(posedge vif.aclk);

        // Forever observe transactions
        forever begin
            aes_transaction tx;
            tx = aes_transaction::type_id::create("tx");
            collect_transaction(tx);
            ap.write(tx); // send to scoreboard
        end
    endtask

    // Task: collect_transaction
    // Observes interface and fills transaction fields
    task collect_transaction(aes_transaction tx);

        // Collect KEY writes
        collect_write(8'h08, tx.key[127:96]);
        collect_write(8'h0C, tx.key[95:64]);
        collect_write(8'h10, tx.key[63:32]);
        collect_write(8'h14, tx.key[31:0]);

        // Collect PLAINTEXT writes
        collect_write(8'h28, tx.plaintext[127:96]);
        collect_write(8'h2C, tx.plaintext[95:64]);
        collect_write(8'h30, tx.plaintext[63:32]);
        collect_write(8'h34, tx.plaintext[31:0]);

        // Wait for encryption to complete
        // Watch STATUS register read returning done=1
        wait_observe_done();

        // Collect CIPHERTEXT reads
        collect_read(8'h38, tx.ciphertext[127:96]);
        collect_read(8'h3C, tx.ciphertext[95:64]);
        collect_read(8'h40, tx.ciphertext[63:32]);
        collect_read(8'h44, tx.ciphertext[31:0]);

    endtask
    // Task: collect_write
    // Wait for write transaction at specific address
    // Capture write data
    task collect_write(
        input  logic [7:0]  expected_addr,
        output logic [31:0] data
    );
        // Wait for valid write handshake at our address
        @(vif.mon_cb);
        while (!(vif.mon_cb.awvalid &&
                 vif.mon_cb.awready &&
                 vif.mon_cb.awaddr == expected_addr))
            @(vif.mon_cb);

        // Capture write data
        data = vif.mon_cb.wdata;

    endtask

  
    // Task: collect_read
    // Wait for read transaction at specific address
    // Capture read data

    task collect_read(
        input  logic [7:0]  expected_addr,
        output logic [31:0] data
    );
        // Wait for valid read handshake at our address
        @(vif.mon_cb);
        while (!(vif.mon_cb.arvalid &&
                 vif.mon_cb.arready &&
                 vif.mon_cb.araddr == expected_addr))
            @(vif.mon_cb);

        // Wait one cycle for data to appear
        @(vif.mon_cb);
        data = vif.mon_cb.rdata;

    endtask

    // Task: wait_observe_done
    // Watch STATUS reads until done bit seen
    task wait_observe_done();
        logic [31:0] status;

        // Watch read transactions on STATUS address
        forever begin
            @(vif.mon_cb);
            if (vif.mon_cb.arvalid &&
                vif.mon_cb.arready &&
                vif.mon_cb.araddr == 8'h04) begin
                // STATUS being read
                @(vif.mon_cb);
                status = vif.mon_cb.rdata;
                if (status[0] === 1'b1)
                    break; // done bit seen
            end
        end
    endtask

endclass

`endif