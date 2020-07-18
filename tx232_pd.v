module tx232_pd(
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
    wire txck_r, txck_f;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            txck_d <= 0;
        end
        else begin
            txck_d <= {txck_d[0], txck};
        end
    end
    assign txck_r = txck_d[0] & ~txck_d[1];
    assign txck_f = ~txck_d[0] & txck_d[1];
    
    //rising edge of start signal
    reg [1:0] start_d;
    wire start_r;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            start_d <= 0;
        end
        else begin
            if(txck_f == 1) begin
                start_d <= {start_d[0], start};
            end
            else begin
                start_d <= start_d;
            end
        end
    end
    assign start_r = start_d[0] & ~start_d[1];
    
    //bit count
    reg [3:0] bcnt;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            bcnt <= 4'hf;
        end
        else begin
            if(txck_r == 1) begin
                if(start_r == 1) begin
                    bcnt <= 0;
                end
                else begin
                    if(bcnt < 9) begin
                        bcnt <= bcnt + 1;
                    end
                    else begin
                        if(bycnt == 0) begin
                            bcnt <= 0;
                        end
                        else begin
                            bcnt <= 4'hf;
                        end
                    end
                end
            end
            else begin
                bcnt <= bcnt;
            end
        end
    end
    
    //byte count
    reg [1:0] bycnt;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            bycnt <= 2'h3;
        end
        else begin
            if(txck_r == 1) begin
                if(start_r == 1) begin
                    bycnt <= 0;
                end
                else begin
                    if(bcnt == 9) begin
                        if(bycnt == 0) begin
                            bycnt <= bycnt + 1;
                        end
                        else begin
                            bycnt <= 2'h3;
                        end
                    end
                    else begin
                        bycnt <= bycnt;
                    end
                end
            end
            else begin
                bycnt <= bycnt;
            end
        end
    end
    
    //capture bcd into ibcd
    reg [15:0] ibcd;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            ibcd <= 16'hffff;
        end
        else begin
            if(txck_r == 1) begin
                if(start_r == 1) begin
                    ibcd <= bcd;
                end
                else begin
                    ibcd <= ibcd;
                end
            end
            else begin
                ibcd <= ibcd;
            end
        end
    end
    
    //tnpd
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            tnpd <= 0;
        end
        else begin
            if(txck_r == 1) begin
                if((bcnt > 2) && (bcnt < 8)) begin
                    tnpd <= 1;
                end
                else begin
                    tnpd <= 0;
                end
            end
            else begin
                tnpd <= tnpd;
            end
        end
    end
    
    //txpd
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            txpd <= 8'hff;
        end
        else begin
            if(txck_r == 1) begin
                if(bycnt == 0) begin
                    txpd <= ibcd[15:8];
                end
                else begin
                    if(bycnt == 1) begin
                        txpd <= ibcd[7:0];
                    end
                    else begin
                        txpd <= 8'hff;
                    end
                end
            end
            else begin
                txpd <= txpd;
            end
        end
    end
endmodule
