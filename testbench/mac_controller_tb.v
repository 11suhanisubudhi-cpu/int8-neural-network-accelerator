
module mac_controller_tb;

    reg clk;
    reg rst;
    reg start;

    reg [31:0] inputs_bus;
    reg [127:0] weights_bus;

    wire [127:0] outputs_bus;
    wire done;

    // Instantiate the controller
    mac_controller DUT (
        .clk(clk),
        .rst(rst),
        .start(start),
        .inputs_bus(inputs_bus),
        .weights_bus(weights_bus),
        .outputs_bus(outputs_bus),
        .done(done)
    );

    // Generate a 10 ns clock period
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin

        $display("--------------------------------");
        $display("MAC CONTROLLER VERIFICATION");
        $display("--------------------------------");

        // Initial signals
        rst = 1;
        start = 0;

        // Inputs: X = [2, -3, 4, 1]
        // X0 occupies the lowest 8 bits
        inputs_bus = {
            8'sd1,
            8'sd4,
            -8'sd3,
            8'sd2
        };

        // Weights are packed in reverse order
        // so W[0][0] occupies the lowest 8 bits.
        weights_bus = {
            8'sd2,  8'sd0,  -8'sd1, 8'sd3,
            8'sd1,  8'sd2,   8'sd1, -8'sd1,
            -8'sd2, 8'sd1,   8'sd0, 8'sd2,
            8'sd3, -8'sd1,   8'sd2, 8'sd1
        };

        // Apply reset
        repeat (2) @(posedge clk);
        @(negedge clk);
        rst = 0;

        // Start computation
        start = 1;

        @(negedge clk);
        start = 0;

        // Wait for the controller to finish
        wait(done == 1'b1);

        // Allow outputs to settle
        #1;

        $display("");
        $display("Controller finished!");
        $display("Neuron 0 output: %0d", $signed(outputs_bus[31:0]));
        $display("Neuron 1 output: %0d", $signed(outputs_bus[63:32]));
        $display("Neuron 2 output: %0d", $signed(outputs_bus[95:64]));
        $display("Neuron 3 output: %0d", $signed(outputs_bus[127:96]));

        // Verify results
        if ($signed(outputs_bus[31:0]) == -32'sd5 &&
            $signed(outputs_bus[63:32]) == 32'sd6 &&
            $signed(outputs_bus[95:64]) == 32'sd4 &&
            $signed(outputs_bus[127:96]) == 32'sd11) begin

            $display("");
            $display("PASS: All neuron outputs are correct!");
        end
        else begin
            $display("");
            $display("FAIL: Incorrect neuron outputs!");
        end

        $display("--------------------------------");
        $finish;

    end

endmodule
