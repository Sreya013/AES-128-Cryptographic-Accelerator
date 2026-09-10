
// File    : aes_coverage.sv
// Project : AES-128 UVM Verification
// Purpose : Functional Coverage
//           Tracks what scenarios have been tested
//           Reports coverage percentage


`ifndef AES_COVERAGE_SV
`define AES_COVERAGE_SV

class aes_coverage extends uvm_subscriber #(aes_transaction);

    `uvm_component_utils(aes_coverage)

  
    // Previous transaction — for back to back checking
   
    aes_transaction prev_tx;

   
    // Covergroup — defines what to measure

    covergroup aes_cg;

        
        // Plaintext coverage
        // Are we testing important plaintext patterns?
        
        cp_plaintext: coverpoint tx.plaintext {
            bins all_zeros = {128'h0};
            bins all_ones  = {128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF};
            bins others    = default;
        }

       
        // Key coverage
        // Are we testing important key patterns?
       
        cp_key: coverpoint tx.key {
            bins all_ones  = {128'hFFFFFFFF_FFFFFFFF_FFFFFFFF_FFFFFFFF};
            bins others    = default;
        }

      
        // Plaintext MSB coverage
        // Upper byte of plaintext
        // Ensures wide range of values tested
       
        cp_pt_msb: coverpoint tx.plaintext[127:120] {
            bins low    = {[8'h00 : 8'h3F]};
            bins mid_lo = {[8'h40 : 8'h7F]};
            bins mid_hi = {[8'h80 : 8'hBF]};
            bins high   = {[8'hC0 : 8'hFF]};
        }

      
        // Key MSB coverage
        // Upper byte of key
       
        cp_key_msb: coverpoint tx.key[127:120] {
            bins low    = {[8'h00 : 8'h3F]};
            bins mid_lo = {[8'h40 : 8'h7F]};
            bins mid_hi = {[8'h80 : 8'hBF]};
            bins high   = {[8'hC0 : 8'hFF]};
        }

      
        // Cross coverage
        // Plaintext MSB range vs Key MSB range
        // Ensures different combinations tested
        
        cx_pt_key: cross cp_pt_msb, cp_key_msb;

    endgroup

    // Transaction handle for covergroup sampling
   
    aes_transaction tx;

 
    // Constructor
   
    function new(string name, uvm_component parent);
        super.new(name, parent);
        aes_cg = new(); // create covergroup instance
        prev_tx = null;
    endfunction

   
    // build_phase
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
    endfunction

    
    // write()
    // Called automatically when monitor sends transaction
    // Sample coverage
   
    function void write(aes_transaction t);
        tx = t;          // set handle for covergroup
        aes_cg.sample(); // sample all coverpoints
        prev_tx = t;     // save for next iteration
    endfunction

    // report_phase
    // Print coverage results
   
    function void report_phase(uvm_phase phase);
        `uvm_info("COVERAGE",
            $sformatf(
            "\n======\n   Functional Coverage Report\n=======\n   Coverage : %.2f%%\n==",
            aes_cg.get_coverage()),
            UVM_NONE)
    endfunction

endclass

`endif