
module mac_controller (
    input clk,
    input rst,
    input start,

    input [31:0] inputs_bus,
    input [127:0] weights_bus,

    output reg [127:0] outputs_bus,
    output wire done
);

    // FSM state definitions
    localparam IDLE      = 3'b000;
    localparam CLEAR_ACC = 3'b001;
    localparam COMPUTE   = 3'b010;
    localparam STORE     = 3'b011;
    localparam DONE      = 3'b100;

    reg [2:0] state;

    // Counters
    reg [1:0] input_count;
    reg [1:0] neuron_count;

    // MAC control signals
    wire mac_clear;
    wire mac_enable;

    // Selected operands
    wire signed [7:0] selected_input;
    wire signed [7:0] selected_weight;

    // MAC accumulator
    wire signed [31:0] accumulator;

    // Generate control signals from FSM state
    assign mac_clear  = (state == CLEAR_ACC);
    assign mac_enable = (state == COMPUTE);

    assign done = (state == DONE);

    // Select input and weight using counters
    assign selected_input =
        $signed(inputs_bus[input_count * 8 +: 8]);

    assign selected_weight =
        $signed(weights_bus[
            (neuron_count * 4 + input_count) * 8 +: 8
        ]);

    // Connect the MAC unit
    mac_unit MAC (
        .clk(clk),
        .rst(rst),
        .clear(mac_clear),
        .enable(mac_enable),
        .A(selected_input),
        .B(selected_weight),
        .accumulator(accumulator)
    );

    // FSM and counter operation
    always @(posedge clk) begin

        if (rst) begin
            state        <= IDLE;
            input_count  <= 0;
            neuron_count <= 0;
            outputs_bus  <= 0;
        end

        else begin

            case (state)

                IDLE: begin
                    if (start) begin
                        input_count  <= 0;
                        neuron_count <= 0;
                        state <= CLEAR_ACC;
                    end
                end

                CLEAR_ACC: begin
                    input_count <= 0;
                    state <= COMPUTE;
                end

                COMPUTE: begin
                    if (input_count == 3) begin
                        input_count <= 0;
                        state <= STORE;
                    end
                    else begin
                        input_count <= input_count + 1;
                    end
                end

                STORE: begin

                    // Save the current neuron's result
                    outputs_bus[neuron_count * 32 +: 32]
                        <= accumulator;

                    if (neuron_count == 3) begin
                        state <= DONE;
                    end
                    else begin
                        neuron_count <= neuron_count + 1;
                        state <= CLEAR_ACC;
                    end

                end

                DONE: begin
                    if (!start)
                        state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end

            endcase

        end

    end

endmodule
