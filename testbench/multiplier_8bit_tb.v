
`timescale 1ns/1ps

module multiplier_8bit_tb;

    reg signed [7:0] A;
    reg signed [7:0] B;

    wire signed [15:0] product;

    integer errors;

    // Instantiate the multiplier hardware
    multiplier_8bit DUT (
        .A(A),
        .B(B),
        .product(product)
    );

    // Task to check one multiplication
    task check;
        input signed [7:0] test_A;
        input signed [7:0] test_B;
        input signed [15:0] expected;

        begin
            A = test_A;
            B = test_B;

            #10;

            if (product !== expected) begin
                $display("FAIL: A=%0d B=%0d Expected=%0d Got=%0d",
                         A, B, expected, product);
                errors = errors + 1;
            end
            else begin
                $display("PASS: A=%0d B=%0d Product=%0d",
                         A, B, product);
            end
        end
    endtask

    // Apply test cases
    initial begin

        errors = 0;

        $display("Starting INT8 Multiplier Verification");

        check(5, 3, 15);
        check(-5, 3, -15);
        check(-5, -3, 15);
        check(127, 127, 16129);
        check(-128, 127, -16256);
        check(-128, -128, 16384);
        check(0, -37, 0);
        check(-1, 1, -1);

        $display("------------------------------");

        if (errors == 0)
            $display("ALL TESTS PASSED!");
        else
            $display("TESTS FAILED: %0d errors", errors);

        $finish;

    end

endmodule
