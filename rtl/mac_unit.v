
module mac_unit (
    input clk,
    input rst,
    input clear,
    input enable,

    input signed [7:0] A,
    input signed [7:0] B,

    output reg signed [31:0] accumulator
);

    // 16-bit signed multiplication result
    wire signed [15:0] product;

    // Extend the product to 32 bits
    wire signed [31:0] product_extended;

    // Instantiate the multiplier
    multiplier_8bit MUL (
        .A(A),
        .B(B),
        .product(product)
    );

    // Sign extension
    assign product_extended =
        {{16{product[15]}}, product};

    // Sequential accumulation
    always @(posedge clk) begin

        if (rst)
            accumulator <= 32'sd0;

        else if (clear)
            accumulator <= 32'sd0;

        else if (enable)
            accumulator <= accumulator + product_extended;

    end

endmodule
