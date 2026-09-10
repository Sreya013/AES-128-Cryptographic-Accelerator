
// File    : aes_sequencer.sv
// Project : AES-128 UVM Verification
// Purpose : UVM Sequencer
//           Manages flow of transactions
//           from sequence to driver


`ifndef AES_SEQUENCER_SV
`define AES_SEQUENCER_SV

class aes_sequencer extends uvm_sequencer #(aes_transaction);

    // Register with UVM factory
    `uvm_component_utils(aes_sequencer)

    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    

endclass

`endif