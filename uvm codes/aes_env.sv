
// File    : aes_env.sv
// Project : AES-128 UVM Verification
// Purpose : UVM Environment
//           Top level verification container
//           Connects agent to scoreboard


`ifndef AES_ENV_SV
`define AES_ENV_SV

class aes_env extends uvm_env;

   
    // Register with UVM factory
   
    `uvm_component_utils(aes_env)

    // Environment components
  
    aes_agent      agt;
    aes_scoreboard sb;

    // Constructor
 
    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    // build_phase
    // Create agent and scoreboard
  
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agt = aes_agent::type_id::create("agt", this);
        sb  = aes_scoreboard::type_id::create("sb", this);

    endfunction

    // connect_phase
    // Connect agent monitor output to scoreboard input
   
    function void connect_phase(uvm_phase phase);

        // Connect agent analysis port to scoreboard
        // Transactions flow:
        // monitor → agent.ap → scoreboard.imp
        agt.ap.connect(sb.imp);

    endfunction

endclass

`endif