module rx232_pd(
    input clk,
    input rst,
    input rxsdi,
    input rxck,
    output reg [7:0] rxpd,
    output reg rxen,
    output reg rx_start
    );
    
    //delaying rxck
    reg [1:0] rxck_d;
    wire rxck_r;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rxck_d <= 0;
        end
        else begin
            rxck_d <= {rxck_d[0], rxck};
        end
    end
    assign rxck_r = rxck_d[0] & ~rxck_d[1];
    
    //delaying rxsdi
    reg rxsdi_d;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rxsdi_d <= 1;
        end
        else begin
            if(rxck_r == 1) begin
                rxsdi_d <= rxsdi;
            end
            else begin
                rxsdi_d <= rxsdi_d;
            end
        end
    end
    
    //rx count
    reg [3:0] rx_cnt;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rx_cnt <= 4'hf;
        end
        else begin
            if(rxck_r == 1) begin
                if(rxsdi == 1) begin
                    if(rx_cnt < 15) begin
                        rx_cnt <= rx_cnt + 1;
                    end
                    else begin
                        rx_cnt <= 4'hf;
                    end
                end
                else begin
                    if(rx_cnt < 15) begin
                        rx_cnt <= rx_cnt + 1;
                    end
                    else begin
                        rx_cnt <= 0;
                    end
                end
            end
            else begin
                rx_cnt <= rx_cnt;
            end
        end
    end
    
    //8-bit temp
    reg [7:0] temp;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            temp <= 8'hff;
        end
        else begin
            if(rxck_r == 1) begin
                case(rx_cnt)
                    1 : temp[0] <= rxsdi_d;
                    2 : temp[1] <= rxsdi_d;
                    3 : temp[2] <= rxsdi_d;
                    4 : temp[3] <= rxsdi_d;
                    5 : temp[4] <= rxsdi_d;
                    6 : temp[5] <= rxsdi_d;
                    7 : temp[6] <= rxsdi_d;
                    8 : temp[7] <= rxsdi_d;
                    default : temp <= temp;
                endcase
            end
            else begin
                temp <= temp;
            end
        end
    end
    
    //pro- count
    reg [3:0] rx_pro_cnt;
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rx_pro_cnt <= 4'hf;
        end
        else begin
            if(rxck_r == 1) begin
                if(rx_cnt == 9) begin
                    rx_pro_cnt <= 0;
                end
                else begin
                    if(rx_pro_cnt < 15) begin
                        rx_pro_cnt <= rx_pro_cnt + 1;
                    end
                    else begin
                        rx_pro_cnt <= rx_pro_cnt;
                    end
                end
            end
            else begin
                rx_pro_cnt <= rx_pro_cnt;
            end
        end
    end    
    
    //upload temp into rxpd
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rxpd <= 8'hff;
        end
        else begin
            if(rxck_r == 1) begin
                if(rx_cnt == 9) begin
                    rxpd <= temp;
                end
                else begin
                    rxpd <= rxpd;
                end
            end
            else begin
                rxpd <= rxpd;
            end
        end
    end
    
    //rxen
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rxen <= 0;
        end
        else begin
            if(rxck_r == 1) begin
                if(rx_pro_cnt < 10) begin
                    rxen <= 1;
                end
                else begin
                    rxen <= 0;
                end
            end
            else begin
                rxen <= rxen;
            end
        end
    end
    
    //rx_start
    
    always@(posedge clk or negedge rst) begin
        if(!rst) begin
            rx_start <= 0;
        end
        else begin
            if(rxck_r == 1) begin
                if(rx_pro_cnt < 3) begin
                    rx_start <= 1;
                end
                else begin
                    rx_start <= 0;
                end
            end
            else begin
                rx_start <= rx_start;
            end
        end
    end
endmodule
