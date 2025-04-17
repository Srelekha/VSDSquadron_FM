module ir_sensor_input (
    input wire ir_sensor,     // 0 = Obstacle, 1 = No Obstacle
    output reg obstacle_detected
);
    always @(*) begin
        obstacle_detected = ~ir_sensor; // Active high when obstacle
    end
endmodule
