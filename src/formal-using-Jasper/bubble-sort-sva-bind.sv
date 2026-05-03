bind bubble_sort bubble_sort_sva #(
    .DATA_WIDTH(DATA_WIDTH),
    .MAX_SIZE(MAX_SIZE)
) i_bubble_sort_sva (
    .clk(clk),
    .rst_n(rst_n),
    .start(start),
    .in_valid(in_valid),
    .in_data(in_data),
    .in_last(in_last),
    .in_ready(in_ready),
    .out_valid(out_valid),
    .out_data(out_data),
    .out_last(out_last),
    .out_ready(out_ready),
    .state(state),       
    .count(count)        
);
