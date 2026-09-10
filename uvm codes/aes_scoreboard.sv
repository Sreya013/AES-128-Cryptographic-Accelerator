
// File    : aes_scoreboard.sv
// Project : AES-128 UVM Verification
// Purpose : Scoreboard
//           Receives transactions from monitor
//           Compares DUT output vs Reference Model
//           Reports PASS/FAIL


`ifndef AES_SCOREBOARD_SV
`define AES_SCOREBOARD_SV

class aes_scoreboard extends uvm_scoreboard;

    
    // Register with UVM factory
  
    `uvm_component_utils(aes_scoreboard)

  
    // TLM Analysis Import
    // Monitor writes transactions here automatically
   
    uvm_analysis_imp #(aes_transaction, aes_scoreboard) imp;

    
    // Counters for reporting
    
    int pass_count;
    int fail_count;
    int total_count;

    
    // Constructor
   
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    
    // build_phase
    // Create TLM port
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
        pass_count  = 0;
        fail_count  = 0;
        total_count = 0;
    endfunction

    
    // write()
    // Called automatically by UVM when monitor sends tx
    // This is the main checking function
    
    function void write(aes_transaction tx);
        logic [127:0] expected_ct;

        // Get correct ciphertext from reference model
        expected_ct = aes_ref_model::encrypt(
                        tx.plaintext,
                        tx.key);

        total_count++;

        // Compare DUT output vs expected
        if (tx.ciphertext === expected_ct) begin
            pass_count++;
            `uvm_info("SCOREBOARD",
                $sformatf("PASS [%0d] CT=%032X",
                total_count, tx.ciphertext),
                UVM_MEDIUM)
        end
        else begin
            fail_count++;
            `uvm_error("SCOREBOARD",
                $sformatf(
                "\nFAIL [%0d]\nPT      = %032X\nKEY     = %032X\nDUT CT  = %032X\nEXP CT  = %032X",
                total_count,
                tx.plaintext,
                tx.key,
                tx.ciphertext,
                expected_ct))
        end
    endfunction

    
    // report_phase
    // Print final summary after all transactions done
    
    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD",
            $sformatf(
            "\n==========================================\n   AES-128 Verification Summary\n==========================================\n   Total      : %0d\n   Passed     : %0d\n   Failed     : %0d\n==========================================",
            total_count, pass_count, fail_count),
            UVM_NONE)

        if (fail_count == 0)
            `uvm_info("SCOREBOARD",
                "ALL TESTS PASSED! AES-128 VERIFIED!",
                UVM_NONE)
        else
            `uvm_error("SCOREBOARD",
                $sformatf("%0d TESTS FAILED!", fail_count))
    endfunction

endclass

`endif