module top (
    input wire clk,
    input wire rst,
    input wire ir_sensor,
    output wire tx
);
    wire obstacle;
    reg [7:0] tx_data;
    reg tx_start = 0;
    wire tx_busy;

    reg [23:0] timer = 0;  // Slow-down timer for transmission

    reg send_newline = 0;  // Flag to indicate when to send a newline

    ir_sensor_input ir_module (
        .ir_sensor(ir_sensor),
        .obstacle_detected(obstacle)
    );

    uart_tx_8n1 uart (
        .clk(clk),
        .rst(rst),
        .tx_start(tx_start),
        .tx_data(tx_data),
        .tx(tx),
        .tx_busy(tx_busy)
    );

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer <= 0;
            tx_start <= 0;
            send_newline <= 0;
        end else begin
            // Timer to control transmission frequency (once per second)
            if (timer < 12000000) begin
                timer <= timer + 1;
                tx_start <= 0;
            end else if (!tx_busy) begin
                if (!send_newline) begin
                    // Send '1' or '0' based on obstacle detection
                    tx_data <= obstacle ? "1" : "0";
                    tx_start <= 1;
                    send_newline <= 1;  // Set flag to send newline next
                    timer <= 0;
                    $display("Sending UART: %c", obstacle ? "1" : "0");
                end else begin
                    // Send newline character '\n'
                    tx_data <= 8'b00001010;  // ASCII for newline ('\n')
                    tx_start <= 1;
                    send_newline <= 0;  // Reset flag after newline sent
                end
            end else begin
                tx_start <= 0;
            end
        end
    end
endmodule
