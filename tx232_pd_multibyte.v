module tx232_pd_multibyte(
    input clk,
    input rst,
    input [15:0] bcd,
    input start,
    input txck,
    output reg [7:0] txpd,
    output reg tnpd
    );
    
    //delaying txck
    reg [1:0] txck_d;
    wire txck_r;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            txck_d <= 0;
        end
        else begin
            txck_d <= {txck_d};
        end
    end
endmodule
