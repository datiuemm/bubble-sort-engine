module bubble_sort_sva #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE   = 8
)(
    input wire clk,
    input wire rst_n,
    input wire start,
    input wire in_valid,
    input wire [DATA_WIDTH-1:0] in_data,
    input wire in_last,
    input wire in_ready,
    input wire out_valid,
    input wire [DATA_WIDTH-1:0] out_data,
    input wire out_last,
    input wire out_ready,
    

    input wire [1:0] state,
    input wire [$clog2(MAX_SIZE):0] count
);


    localparam IDLE   = 2'b00;
    localparam INPUT  = 2'b01;
    localparam SORT   = 2'b10;
    localparam OUTPUT = 2'b11;


    property p_reset_state;
        @(posedge clk) !rst_n |-> (state == IDLE);
    endproperty
    a_reset_state: assert property (p_reset_state);


    property p_start_to_input;
        @(posedge clk) disable iff (!rst_n)
        (state == IDLE && start) |=> (state == INPUT && in_ready);
    endproperty
    a_start_to_input: assert property (p_start_to_input);


    property p_in_last_stops_input;
        @(posedge clk) disable iff (!rst_n)
        (state == INPUT && in_valid && in_ready && in_last) |=> (!in_ready);
    endproperty
    a_in_last_stops_input: assert property (p_in_last_stops_input);



    property p_out_last_only_at_end;
        @(posedge clk) disable iff (!rst_n)
        (out_valid && out_last) |-> (state == OUTPUT);
    endproperty
    a_out_last_only_at_end: assert property (p_out_last_only_at_end);


    reg [DATA_WIDTH-1:0] prev_out_data;
    always @(posedge clk) begin
        if (out_valid && out_ready)
            prev_out_data <= out_data;
    end

    property p_ascending_order;
        @(posedge clk) disable iff (!rst_n)
        (state == OUTPUT && out_valid && out_ready && !out_last && $past(out_valid && out_ready)) 
        |-> (out_data >= prev_out_data);
    endproperty

    property p_eventually_output;
    	@(posedge clk) disable iff (!rst_n)
    	(state == SORT) |-> (!(state == OUTPUT))[*0:$] ##1 (state == OUTPUT);
    endproperty
    a_eventually_output: assert property (p_eventually_output);	

endmodule
