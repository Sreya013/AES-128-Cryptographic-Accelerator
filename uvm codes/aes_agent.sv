
// File    : aes_agent.sv
// Project : AES-128 UVM Verification
// Purpose : UVM Agent
//           Bundles driver, monitor, sequencer
//           Reusable verification component

`ifndef AES_AGENT_SV
`define AES_AGENT_SV

class aes_agent extends uvm_agent;

    // Register with UVM factory
    
    `uvm_component_utils(aes_agent)

    
    // Agent components

    aes_driver     drv;
    aes_monitor    mon;
    aes_sequencer  seqr;

  
    // Analysis port
    // Exposes monitor output to environment
    // Environment connects this to scoreboard
   
    uvm_analysis_port #(aes_transaction) ap;
    // Constructor
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction
    // build_phase
    // Create all sub-components
   
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        // Create analysis port
        ap = new("ap", this);

        // Create driver, monitor, sequencer
        drv  = aes_driver::type_id::create("drv", this);
        mon  = aes_monitor::type_id::create("mon", this);
        seqr = aes_sequencer::type_id::create("seqr", this);

    endfunction

    // connect_phase
    // Connect components together
  
    function void connect_phase(uvm_phase phase);

        // Connect driver to sequencer
        // Driver gets transactions from sequencer
        drv.seq_item_port.connect(seqr.seq_item_export);

        // Connect monitor analysis port to agent port
        // Environment will connect agent port to scoreboard
        mon.ap.connect(ap);

    endfunction

endclass

`endif