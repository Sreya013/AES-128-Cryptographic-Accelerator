
// Module  : aes_fsm
// Project : AES-128/256 Crypto Accelerator
// Purpose : AES Control FSM
//           Controls all datapath operations
//           Sequences through encryption rounds
//           6 states — IDLE to DONE


module aes_fsm (
    input  logic       clk,        // system clock
    input  logic       rst_n,      // active low reset
    input  logic       start,      // begin encryption
    input  logic       key_size,   // 0=AES128, 1=AES256

    output logic [3:0] round_num,  // current round number
    output logic       mc_enable,  // MixColumns enable
    output logic       enc_done,   // encryption complete
    output logic       state_load, // load plaintext into state reg
    output logic [3:0] rk_sel      // round key select
);

    
    // State encoding using enum
    // Clean, readable, synthesis friendly
  
    typedef enum logic [2:0] {
        IDLE        = 3'b000,
        KEY_EXP     = 3'b001,
        INIT_ROUND  = 3'b010,
        MAIN_ROUND  = 3'b011,
        FINAL_ROUND = 3'b100,
        DONE        = 3'b101
    } state_t;

    state_t current_state, next_state;

    // Round counter
    logic [3:0] round_cnt;
    logic [3:0] max_rounds; // 10 for AES128, 14 for AES256

    
    // Max rounds based on key size
  
    assign max_rounds = key_size ? 4'd14 : 4'd10;

   
    // Sequential block — state register + round counter
    // Updates on every rising clock edge
 
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset — go to IDLE, clear counter
            current_state <= IDLE;
            round_cnt     <= 4'd0;
        end
        else begin
            current_state <= next_state;

            // Round counter logic
            case (current_state)
                IDLE: begin
                    round_cnt <= 4'd0;
                end

                INIT_ROUND: begin
                    round_cnt <= 4'd1;
                end

                MAIN_ROUND: begin
                    if (round_cnt < max_rounds - 1)
                        round_cnt <= round_cnt + 4'd1;
                end

                FINAL_ROUND: begin
                    round_cnt <= max_rounds;
                end

                default: begin
                    round_cnt <= round_cnt;
                end
            endcase
        end
    end

    
    // Combinational block — next state logic
   
    always_comb begin
        // Default next state = stay in current state
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (start)
                    next_state = KEY_EXP;
            end

            KEY_EXP: begin
                // Key expansion is combinational
                // so we only need 1 cycle here
                next_state = INIT_ROUND;
            end

            INIT_ROUND: begin
                next_state = MAIN_ROUND;
            end

            MAIN_ROUND: begin
                if (round_cnt == max_rounds - 1)
                    next_state = FINAL_ROUND;
                else
                    next_state = MAIN_ROUND;
            end

            FINAL_ROUND: begin
                next_state = DONE;
            end

            DONE: begin
                if (start)
                    next_state = KEY_EXP;
                else
                    next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
            end
        endcase
    end

    
    // Output logic — based on current state
   
    always_comb begin
        // Default values
        mc_enable  = 1'b0;
        enc_done   = 1'b0;
        state_load = 1'b0;
        round_num  = round_cnt;
        rk_sel     = round_cnt;

        case (current_state)
            IDLE: begin
                mc_enable  = 1'b0;
                enc_done   = 1'b0;
                state_load = 1'b0;
                round_num  = 4'd0;
                rk_sel     = 4'd0;
            end

            KEY_EXP: begin
                mc_enable  = 1'b0;
                enc_done   = 1'b0;
                state_load = 1'b1;  // load plaintext now
                round_num  = 4'd0;
                rk_sel     = 4'd0;
            end

            INIT_ROUND: begin
                mc_enable  = 1'b0;  // no MixColumns
                enc_done   = 1'b0;
                state_load = 1'b0;
                round_num  = 4'd0;
                rk_sel     = 4'd0;  // use Round Key 0
            end

            MAIN_ROUND: begin
                mc_enable  = 1'b1;  // MixColumns ON
                enc_done   = 1'b0;
                state_load = 1'b0;
                round_num  = round_cnt;
                rk_sel     = round_cnt;
            end

            FINAL_ROUND: begin
                mc_enable  = 1'b0;  // MixColumns OFF
                enc_done   = 1'b0;
                state_load = 1'b0;
                round_num  = max_rounds;
                rk_sel     = max_rounds;
            end

            DONE: begin
                mc_enable  = 1'b0;
                enc_done   = 1'b1;  // signal done
                state_load = 1'b0;
                round_num  = max_rounds;
                rk_sel     = max_rounds;
            end

            default: begin
                mc_enable  = 1'b0;
                enc_done   = 1'b0;
                state_load = 1'b0;
                round_num  = 4'd0;
                rk_sel     = 4'd0;
            end
        endcase
    end

endmodule