
`timescale 1ns/1ps

module mac_unit_tb;

    reg clk;
    reg rst;
    reg clear;
    reg enable;

    reg signed [7:0] A;
    reg signed [7:0] B;

    wire signed [31:0] accumulator;

    integer errors;

    // Instantiate the MAC unit
    mac_unit DUT (
        .clk(clk),
        .rst(rst),
        .clear(clear),
        .enable(enable),
        .A(A),
        .B(B),
        .accumulator(accumulator)
    );

    // Generate a clock with a 10 ns period
    always #5 clk = ~clk;

    // Task to apply inputs and verify the result
    task check_step;

        input signed [7:0] test_A;
        input signed [7:0] test_B;
        input test_rst;
        input test_clear;
        input test_enable;
        input signed [31:0] expected;

        begin
            @(negedge clk);

            A = test_A;
            B = test_B;
            rst = test_rst;
            clear = test_clear;
            enable = test_enable;

            @(posedge clk);
            #1;

            if (accumulator !== expected) begin

                $display(
                    "FAIL: A=%0d B=%0d Expected=%0d Got=%0d",
                    A, B, expected, accumulator
                );

                errors = errors + 1;

            end
            else begin

                $display(
                    "PASS: A=%0d B=%0d Accumulator=%0d",
                    A, B, accumulator
                );

            end
        end

    endtask

    // Main test sequence
    initial begin

        clk = 0;
        rst = 0;
        clear = 0;
        enable = 0;
        A = 0;
        B = 0;
        errors = 0;

        $display("Starting MAC Unit Verification");

        // Reset test
        check_step(0, 0, 1, 0, 0, 0);

        // Sequential accumulation tests
        check_step(2, 1, 0, 0, 1, 2);
        check_step(-3, 2, 0, 0, 1, -4);
        check_step(4, -1, 0, 0, 1, -8);
        check_step(1, 3, 0, 0, 1, -5);

        // Enable disabled: accumulator must hold its value
        check_step(100, 100, 0, 0, 0, -5);

        // Clear must take priority over enable
        check_step(9, 9, 0, 1, 1, 0);

        // Accumulation after clearing
        check_step(2, 3, 0, 0, 1, 6);

        // Reset must take priority over enable
        check_step(10, 10, 1, 0, 1, 0);

        // Negative product after reset
        check_step(1, -7, 0, 0, 1, -7);

        $display("------------------------------");

        if (errors == 0)
            $display("ALL MAC TESTS PASSED!");
        else
            $display("MAC TESTS FAILED: %0d errors", errors);

        $finish;

    end

endmodule
