module uart_delay(
    input clk,
    input rst,
    input [10:0] dv,
    input txsdi,
    output reg txsdo
);
    
    //delaying txsdi
    reg [1:0] txsdi_d;
    wire txsdi_rf;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            txsdi_d <= 2'b11;
        end
        else begin
            txsdi_d <= {txsdi_d[0], txsdi};
        end
    end
    assign txsdi_rf = txsdi_d[0] ^ txsdi_d[1];
    
    //count dv
    reg [10:0] dvcnt;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            dvcnt <= 11'h7ff;
        end
        else begin
            if(txsdi_rf == 1) begin
                dvcnt <= 0;
            end
            else begin
                if(dvcnt < dv) begin
                    dvcnt <= dvcnt + 1;
                end
                else begin
                    dvcnt <= 11'h7ff;
                end
            end
        end
    end
    
    //txsdo
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            txsdo <= 1;
        end
        else begin
            if(dvcnt == dv) begin
                txsdo <= txsdi;
            end
            else begin
                txsdo <= txsdo;
            end
        end
    end
endmodule