
// File    : aes_test.sv
// Project : AES-128 UVM Verification
// Purpose : UVM Tests
//           Creates environment
//           Starts sequences
//           Controls simulation


`ifndef AES_TEST_SV
`define AES_TEST_SV

// Base Test — common setup for all tests

class aes_base_test extends uvm_test;

    `uvm_component_utils(aes_base_test)

    // Environment
    aes_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // build_phase — create environment
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = aes_env::type_id::create("env", this);
    endfunction

    // end_of_elaboration_phase — print topology
    function void end_of_elaboration_phase(uvm_phase phase);
        uvm_top.print_topology();
    endfunction

endclass


// Test 1 — NIST Test
// Runs only NIST FIPS 197 known answer test

class aes_nist_test extends aes_base_test;

    `uvm_component_utils(aes_nist_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        aes_nist_sequence nist_seq;

        // Raise objection — keep simulation running
        phase.raise_objection(this);

        // Create and start NIST sequence
        nist_seq = aes_nist_sequence::type_id::create(
                   "nist_seq");
        nist_seq.start(env.agt.seqr);

        // Small delay after sequence completes
        #100;

        // Drop objection — allow simulation to end
        phase.drop_objection(this);

    endtask

endclass



// Test 2 — Random Test
// Runs randomized transactions

class aes_random_test extends aes_base_test;

    `uvm_component_utils(aes_random_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        aes_nist_sequence    nist_seq;
        aes_random_sequence  rand_seq;

        phase.raise_objection(this);

        // Always run NIST first as sanity check
        `uvm_info("RANDOM_TEST",
            "Running NIST sanity check first",
            UVM_NONE)
        nist_seq = aes_nist_sequence::type_id::create(
                   "nist_seq");
        nist_seq.start(env.agt.seqr);

        // Then run random transactions
        `uvm_info("RANDOM_TEST",
            "Starting random transactions",
            UVM_NONE)
        rand_seq = aes_random_sequence::type_id::create(
                   "rand_seq");
        rand_seq.num_transactions = 20;
        rand_seq.start(env.agt.seqr);

        #100;
        phase.drop_objection(this);

    endtask

endclass


// Test 3 — Full Test
// Runs all sequences in order
// Maximum coverage

class aes_full_test extends aes_base_test;

    `uvm_component_utils(aes_full_test)

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    task run_phase(uvm_phase phase);
        aes_nist_sequence    nist_seq;
        aes_random_sequence  rand_seq;
        aes_corner_sequence  corner_seq;

        phase.raise_objection(this);

        // Step 1 — NIST regression
        `uvm_info("FULL_TEST",
            "Step 1: NIST regression test",
            UVM_NONE)
        nist_seq = aes_nist_sequence::type_id::create(
                   "nist_seq");
        nist_seq.start(env.agt.seqr);

        // Step 2 — Random transactions
        `uvm_info("FULL_TEST",
            "Step 2: Random transactions",
            UVM_NONE)
        rand_seq = aes_random_sequence::type_id::create(
                   "rand_seq");
        rand_seq.num_transactions = 20;
        rand_seq.start(env.agt.seqr);

        // Step 3 — Corner cases
        `uvm_info("FULL_TEST",
            "Step 3: Corner case tests",
            UVM_NONE)
        corner_seq = aes_corner_sequence::type_id::create(
                     "corner_seq");
        corner_seq.start(env.agt.seqr);

        #100;
        phase.drop_objection(this);

    endtask

endclass

`endif