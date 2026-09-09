
// Module  : tb_keyschedule
// Project : AES-128/256 Crypto Accelerator
// Purpose : Testbench for aes_keyschedule module
//           Verifies all 11 round keys against NIST FIPS 197


module tb_keyschedule;

    // Signals
    logic [127:0] key;
    logic [127:0] round_key [0:10];

    // Instantiate Key Schedule
    aes_keyschedule uut (
        .key       (key),
        .round_key (round_key)
    );

    // Task to check one round key
    task check_rk;
        input integer rnum;
        input logic [127:0] expected;
        begin
            if (round_key[rnum] == expected)
                $display("RK%02d PASS  : %032X",
                    rnum, round_key[rnum]);
            else begin
                $display("RK%02d FAIL  : %032X",
                    rnum, round_key[rnum]);
                $display("     Expected : %032X",
                    expected);
            end
        end
    endtask

    initial begin
       
        $display("   AES Key Schedule Verification Test    ");
      

        // NIST FIPS 197 test key
        key = 128'h2B7E151628AED2A6ABF7158809CF4F3C;
        #10;

        $display("Key : %032X", key);
      

        // Verify all 11 round keys against NIST FIPS 197
        check_rk(0,  128'h2B7E151628AED2A6ABF7158809CF4F3C);
        check_rk(1,  128'hA0FAFE1788542CB123A339392A6C7605);
        check_rk(2,  128'hF2C295F27A96B9435935807A7359F67F);
        check_rk(3,  128'h3D80477D4716FE3E1E237E446D7A883B);
        check_rk(4,  128'hEF44A541A8525B7FB671253BDB0BAD00);
        check_rk(5,  128'hD4D1C6F87C839D87CAF2B8BC11F915BC);
        check_rk(6,  128'h6D88A37A110B3EFDDBF98641CA0093FD);
        check_rk(7,  128'h4E54F70E5F5FC9F384A64FB24EA6DC4F);
        check_rk(8,  128'hEAD27321B58DBAD2312BF5607F8D292F);
        check_rk(9,  128'hAC7766F319FADC2128D12941575C006E);
        check_rk(10, 128'hD014F9A8C9EE2589E13F0CC8B6630CA6);

        $display(" All Tests Complete");
     

        $finish;
    end

endmodule