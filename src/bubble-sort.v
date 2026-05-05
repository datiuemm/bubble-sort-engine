module bubble_sort #(
    parameter DATA_WIDTH = 8,
    parameter MAX_SIZE   = 8
)(
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  start,
    input  wire                  in_valid,
    input  wire [DATA_WIDTH-1:0] in_data,
    input  wire                  in_last,
    output reg                   in_ready,
    output reg                   out_valid,
    output reg  [DATA_WIDTH-1:0] out_data,
    output reg                   out_last,
    input  wire                  out_ready
);

    localparam IDLE   = 2'd0,
               INPUT  = 2'd1,
               SORT   = 2'd2,
               OUTPUT = 2'd3;

    reg [1:0] state;
    reg [DATA_WIDTH-1:0] mem [0:MAX_SIZE-1];
    reg [$clog2(MAX_SIZE):0] count;
    reg [$clog2(MAX_SIZE):0] i_reg, j_reg;
    reg [$clog2(MAX_SIZE):0] out_ptr;

    wire [DATA_WIDTH-1:0] val_j     = mem[j_reg];
    wire [DATA_WIDTH-1:0] val_j_next = mem[j_reg+1];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state     <= IDLE;
            in_ready  <= 0;
            out_valid <= 0;
            out_last  <= 0;
            out_data  <= 0;
            count     <= 0;
            i_reg     <= 0;
            j_reg     <= 0;
            out_ptr   <= 0;
        end else begin
            case (state)
                IDLE: begin
                    out_valid <= 0;
                    out_last  <= 0;
                    if (start) begin
                        in_ready <= 1;
                        count    <= 0;
                        state    <= INPUT;
                    end
                end

                INPUT: begin
                    if (in_valid && in_ready) begin
                        mem[count] <= in_data;
                        count      <= count + 1;
                        if (in_last) begin
                            in_ready <= 0;
                            i_reg    <= 0;
                            j_reg    <= 0;
                            state    <= SORT;
                        end
                    end
                end

                SORT: begin
                    if (count < 2) begin
                        state   <= OUTPUT;
                        out_ptr <= 0;
                    end else if (i_reg < count - 1) begin
                        if (j_reg < count - 1 - i_reg) begin
                            if (val_j > val_j_next) begin
                                mem[j_reg]   <= val_j_next;
                                mem[j_reg+1] <= val_j;
                            end
                            j_reg <= j_reg + 1;
                        end else begin
                            j_reg <= 0;
                            i_reg <= i_reg + 1;
                        end
                    end else begin
                        state   <= OUTPUT;
                        out_ptr <= 0;
                    end
                end

                OUTPUT: begin
                    if (!out_valid) begin
                        if (count == 0) begin
                            state <= IDLE;
                        end else begin
                            out_valid <= 1;
                            out_data  <= mem[out_ptr];
                            out_last  <= (out_ptr == count - 1);
                        end
                    end else if (out_ready) begin
                        if (out_ptr == count - 1) begin
                            out_valid <= 0;
                            out_last  <= 0;
                            state     <= IDLE;
                        end else begin
                            out_ptr   <= out_ptr + 1;
                            out_data  <= mem[out_ptr + 1];
                            out_last  <= (out_ptr + 1 == count - 1);
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
