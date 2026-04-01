module ro_puf_bit (
    input      clk,
    input      rst,
    input      enable,
    output reg puf_bit,
    output reg valid
);
    (* keep *) wire n0a, n1a, n2a, n3a, n4a;
    (* keep *) wire n0b, n1b, n2b, n3b, n4b;

    assign n0a = enable ? ~n4a : 1'b0;
    assign n1a = ~n0a;
    assign n2a = ~n1a;
    assign n3a = ~n2a;
    assign n4a = ~n3a;

    assign n0b = enable ? ~n4b : 1'b0;
    assign n1b = ~n0b;
    assign n2b = ~n1b;
    assign n3b = ~n2b;
    assign n4b = ~n3b;

    wire ro_a_out = n4a;
    wire ro_b_out = n4b;

    reg [15:0] count_a, count_b, timer;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            count_a <= 0; count_b <= 0;
            timer   <= 0; valid   <= 0;
            puf_bit <= 0;
        end else if (enable && !valid) begin
            if (timer < 16'hFFFF) begin
                count_a <= count_a + ro_a_out;
                count_b <= count_b + ro_b_out;
                timer   <= timer + 1;
            end else begin
                puf_bit <= (count_a > count_b) ? 1'b1 : 1'b0;
                valid   <= 1;
            end
        end
    end
endmodule