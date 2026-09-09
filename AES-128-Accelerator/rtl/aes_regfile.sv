
// Module  : aes_regfile
// Project : AES-128/256 Crypto Accelerator
// Purpose : Register File
//           Shared storage between firmware and hardware
//           Contains CTRL, STATUS, KEY, PT, CT registers
//           Address decoder included


module aes_regfile (
    input  logic        clk,
    input  logic        rst_n,

    // Write interface (from AXI4-Lite)
    input  logic        wr_en,
    input  logic [7:0]  wr_addr,
    input  logic [31:0] wr_data,

    // Read interface (from AXI4-Lite)
    input  logic [7:0]  rd_addr,
    output logic [31:0] rd_data,

    // Hardware inputs
    input  logic [127:0] ciphertext,  // from datapath
    input  logic         enc_done,    // from FSM

    // Hardware outputs
    output logic [127:0] key,         // to key schedule
    output logic [127:0] plaintext,   // to datapath
    output logic         start,       // to FSM
    output logic         key_size     // to FSM
);

    // Internal registers
   
    logic [31:0] ctrl_reg;        // 0x00
    logic [31:0] status_reg;      // 0x04
    logic [31:0] key_reg    [0:3]; // 0x08 to 0x14
    logic [31:0] pt_reg     [0:3]; // 0x28 to 0x34
    logic [31:0] ct_reg     [0:3]; // 0x38 to 0x44

    // Write logic — sequential
   
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ctrl_reg    <= 32'h0;
            key_reg[0]  <= 32'h0;
            key_reg[1]  <= 32'h0;
            key_reg[2]  <= 32'h0;
            key_reg[3]  <= 32'h0;
            pt_reg[0]   <= 32'h0;
            pt_reg[1]   <= 32'h0;
            pt_reg[2]   <= 32'h0;
            pt_reg[3]   <= 32'h0;
        end
        else begin
            // Auto clear start bit after 1 cycle
            ctrl_reg[0] <= 1'b0;

            if (wr_en) begin
                case (wr_addr)
                    8'h00: ctrl_reg   <= wr_data;
                    8'h08: key_reg[0] <= wr_data;
                    8'h0C: key_reg[1] <= wr_data;
                    8'h10: key_reg[2] <= wr_data;
                    8'h14: key_reg[3] <= wr_data;
                    8'h28: pt_reg[0]  <= wr_data;
                    8'h2C: pt_reg[1]  <= wr_data;
                    8'h30: pt_reg[2]  <= wr_data;
                    8'h34: pt_reg[3]  <= wr_data;
                    default: ; // ignore invalid addresses
                endcase
            end
        end
    end

    // Status register — written by hardware
  
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            status_reg <= 32'h0;
            ct_reg[0]  <= 32'h0;
            ct_reg[1]  <= 32'h0;
            ct_reg[2]  <= 32'h0;
            ct_reg[3]  <= 32'h0;
        end
        else begin
            if (enc_done) begin
                status_reg[0] <= 1'b1;  // done bit
                // Capture ciphertext when done
                ct_reg[0] <= ciphertext[127:96];
                ct_reg[1] <= ciphertext[95:64];
                ct_reg[2] <= ciphertext[63:32];
                ct_reg[3] <= ciphertext[31:0];
            end
            else if (ctrl_reg[0]) begin
                // Clear done when new encryption starts
                status_reg[0] <= 1'b0;
            end
        end
    end

    // Read logic — combinational address decoder
    
    always_comb begin
        case (rd_addr)
            8'h00: rd_data = ctrl_reg;
            8'h04: rd_data = status_reg;
            8'h08: rd_data = 32'h0;       // KEY write only
            8'h0C: rd_data = 32'h0;       // KEY write only
            8'h10: rd_data = 32'h0;       // KEY write only
            8'h14: rd_data = 32'h0;       // KEY write only
            8'h28: rd_data = pt_reg[0];
            8'h2C: rd_data = pt_reg[1];
            8'h30: rd_data = pt_reg[2];
            8'h34: rd_data = pt_reg[3];
            8'h38: rd_data = ct_reg[0];
            8'h3C: rd_data = ct_reg[1];
            8'h40: rd_data = ct_reg[2];
            8'h44: rd_data = ct_reg[3];
            default: rd_data = 32'hDEADBEEF; // invalid address
        endcase
    end

    // Output assignments to hardware blocks
  
    assign key       = {key_reg[0], key_reg[1],
                        key_reg[2], key_reg[3]};
    assign plaintext = {pt_reg[0],  pt_reg[1],
                        pt_reg[2],  pt_reg[3]};
    assign start     = ctrl_reg[0];
    assign key_size  = ctrl_reg[1];

endmodule