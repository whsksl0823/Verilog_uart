module rx232_clk_debug2(
    input clk,
    input rst,
    input rxsdi,
    output reg rxck,
    output reg rxsdo
    );
    
    //delaying rxsdi
    reg [1:0] rxsdi_d;
    wire rxsdi_rf;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rxsdi_d <= 2'b11;
        end
        else begin
            rxsdi_d <= {rxsdi_d[0], rxsdi};
        end
    end
    assign rxsdi_rf = rxsdi_d[0] ^ rxsdi_d[1];
    
    //data count
    reg [10:0] dcnt;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            dcnt <= 11'h7ff;
        end
        else begin
            if(rxsdi_rf == 1) begin
                dcnt <= 0;
            end
            else begin
                if(dcnt < 1040) begin
                    dcnt <= dcnt + 1;
                end
                else begin
                    dcnt <= 0; 
                end
            end
        end
    end
    
    //rxck_before
    reg rxck_b;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rxck_b <= 0;
        end
        else begin
            if(rxsdi_rf == 1) begin
                rxck_b <= 0;
            end
            else begin
                if(dcnt < 520) begin
                    rxck_b <= 0;
                end
                else begin
                    if(dcnt < 1040) begin
                        rxck_b <= 1;
                    end
                    else begin
                        rxck_b <= 0;
                    end
                end
            end
        end
    end
    
    //rxck
    reg rxck_d;
    wire rxck_r;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rxck <= 0;
            rxck_d <= 0;
        end
        else begin
            rxck <= ~rxck_b;
            rxck_d <= rxck_b;
        end
    end
    assign rxck_r = rxck_b & ~rxck_d;
    
    //rxsdo
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rxsdo <= 1;
        end
        else begin
            if(rxck_r == 1) begin
                rxsdo <= rxsdi_d[1];
            end
            else begin
                rxsdo <= rxsdo;
            end
        end
    end
endmodule