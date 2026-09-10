
// File    : aes_transaction.sv
// Project : AES-128 UVM Verification
// Purpose : UVM Sequence Item
//           Data packet carrying one AES operation
//           plaintext + key → ciphertext

`ifndef AES_TRANSACTION_SV
`define AES_TRANSACTION_SV

class aes_transaction extends uvm_sequence_item;

    
    // Fields
    // rand = randomizable by randomize()
    
    rand logic [127:0] plaintext;   // input to DUT
    rand logic [127:0] key;         // input to DUT
         logic [127:0] ciphertext;  // output from DUT
                                    // not randomized
                                    // filled after encryption

    
    // Register with UVM Factory
    // Enables factory creation and override
    
    `uvm_object_utils_begin(aes_transaction)
        `uvm_field_int(plaintext,  UVM_ALL_ON)
        `uvm_field_int(key,        UVM_ALL_ON)
        `uvm_field_int(ciphertext, UVM_ALL_ON)
    `uvm_object_utils_end

    
    // Constructor
    // name = instance name passed by factory
    
    function new(string name = "aes_transaction");
        super.new(name);
    endfunction

  
    // Constraint — AES-128 only
    // key is always 128 bits
    // No all-zero key (weak key, separate corner case test)
    
    constraint valid_key {
        key != 128'h0;
    }


    // convert2string — for debug printing
    // Called automatically by UVM logger
    
    function string convert2string();
        return $sformatf(
            "\nPT  = %032X\nKEY = %032X\nCT  = %032X",
            plaintext, key, ciphertext);
    endfunction

endclass

`endif