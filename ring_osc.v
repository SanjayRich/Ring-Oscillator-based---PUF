module ring_osc (
    input  enable,
    output out
);
    (* keep *) wire n0, n1, n2, n3, n4;

    assign n0 = enable ? ~n4 : 1'b0;
    assign n1 = ~n0;
    assign n2 = ~n1;
    assign n3 = ~n2;
    assign n4 = ~n3;

    assign out = n4;
endmodule