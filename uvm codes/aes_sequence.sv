
// File    : aes_sequence.sv
// Project : AES-128 UVM Verification
// Purpose : UVM Sequences
//           Defines what stimulus to generate
//           Three sequences for different test scenarios


`ifndef AES_SEQUENCE_SV
`define AES_SEQUENCE_SV


// Sequence 1 — NIST Test Vector
// Sends exact NIST FIPS 197 known answer test
// Must always pass — used as regression check

class aes_nist_sequence extends uvm_sequence #(aes_transaction);

    `uvm_object_utils(aes_nist_sequence)

    function new(string name = "aes_nist_sequence");
        super.new(name);
    endfunction

    task body();
        aes_transaction tx;

        `uvm_info("NIST_SEQ",
            "Starting NIST FIPS 197 test vector",
            UVM_NONE)

        // Create transaction
        tx = aes_transaction::type_id::create("tx");

        // Send to sequencer
        start_item(tx);

        // Fill with exact NIST values
        // No randomization — fixed known values
        tx.plaintext = 128'h3243F6A8885A308D313198A2E0370734;
        tx.key       = 128'h2B7E151628AED2A6ABF7158809CF4F3C;

        finish_item(tx);

        `uvm_info("NIST_SEQ",
            "NIST test vector sent successfully",
            UVM_NONE)

    endtask

endclass



// Sequence 2 — Random Sequence
// Sends N fully randomized transactions
// Main verification workhorse
// Scoreboard automatically checks each one

class aes_random_sequence extends uvm_sequence #(aes_transaction);

    `uvm_object_utils(aes_random_sequence)

    // Number of transactions to generate
    // Can be set from test before starting sequence
    int unsigned num_transactions = 20;

    function new(string name = "aes_random_sequence");
        super.new(name);
    endfunction

    task body();
        aes_transaction tx;

        `uvm_info("RAND_SEQ",
            $sformatf("Starting %0d random transactions",
            num_transactions),
            UVM_NONE)

        repeat(num_transactions) begin
            // Create fresh transaction each time
            tx = aes_transaction::type_id::create("tx");

            start_item(tx);

            // Randomize plaintext and key
            // constraint valid_key ensures key != 0
            if (!tx.randomize())
                `uvm_fatal("RAND_SEQ",
                    "Randomization failed!")

            finish_item(tx);
        end

        `uvm_info("RAND_SEQ",
            $sformatf("Completed %0d random transactions",
            num_transactions),
            UVM_NONE)

    endtask

endclass



// Sequence 3 — Corner Case Sequence
// Tests specific edge cases that random might miss

class aes_corner_sequence extends uvm_sequence #(aes_transaction);

    `uvm_object_utils(aes_corner_sequence)

    function new(string name = "aes_corner_sequence");
        super.new(name);
    endfunction

    task body();
        aes_transaction tx;

        `uvm_info("CORNER_SEQ",
            "Starting corner case tests",
            UVM_NONE)

        // Corner Case 1 — All zero plaintext
        // Key is random, plaintext is all zeros
       
        tx = aes_transaction::type_id::create("tx_zero_pt");
        start_item(tx);
        if (!tx.randomize() with {
            plaintext == 128'h0;
        })
            `uvm_fatal("CORNER_SEQ",
                "Corner case 1 randomization failed!")
        `uvm_info("CORNER_SEQ",
            "Sending all-zero plaintext", UVM_LOW)
        finish_item(tx);

      
        // Corner Case 2 — All FF plaintext
   
        tx = aes_transaction::type_id::create("tx_ff_pt");
        start_item(tx);
        if (!tx.randomize() with {
            plaintext == 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        })
            `uvm_fatal("CORNER_SEQ",
                "Corner case 2 randomization failed!")
        `uvm_info("CORNER_SEQ",
            "Sending all-FF plaintext", UVM_LOW)
        finish_item(tx);

        // Corner Case 3 — All FF key
        
        tx = aes_transaction::type_id::create("tx_ff_key");
        start_item(tx);
        if (!tx.randomize() with {
            key == 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        })
            `uvm_fatal("CORNER_SEQ",
                "Corner case 3 randomization failed!")
        `uvm_info("CORNER_SEQ",
            "Sending all-FF key", UVM_LOW)
        finish_item(tx);

        // Corner Case 4 — Same input twice
        // DUT should produce same output both times
       
        tx = aes_transaction::type_id::create("tx_repeat_1");
        start_item(tx);
        if (!tx.randomize())
            `uvm_fatal("CORNER_SEQ",
                "Corner case 4a randomization failed!")

        // Save values for repeat
        begin
            logic [127:0] saved_pt  = tx.plaintext;
            logic [127:0] saved_key = tx.key;

            finish_item(tx);

            // Send exact same input again
            tx = aes_transaction::type_id::create("tx_repeat_2");
            start_item(tx);
            if (!tx.randomize() with {
                plaintext == saved_pt;
                key       == saved_key;
            })
                `uvm_fatal("CORNER_SEQ",
                    "Corner case 4b randomization failed!")

            `uvm_info("CORNER_SEQ",
                "Sending same input twice", UVM_LOW)
            finish_item(tx);
        end

        `uvm_info("CORNER_SEQ",
            "Corner case tests complete",
            UVM_NONE)

    endtask

endclass

`endif