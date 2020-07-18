module tx232(
    input clk,
    input rst,
    input [7:0] txpd,
    input tstart,
    input txck,
    output reg txsd
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

 //delaying tstart
 reg [1:0] tstart_d;
 wire tstart_r;
 
 always@(posedge clk or negedge rst) begin
    if(!rst) begin
        tstart_d <= 0;
    end
    else begin
        if(txck_f == 1) begin
            tstart_d <= {tstart_d[0], tstart};
        end
        else begin
            tstart_d <= tstart_d;
        end
    end
 end
 assign tstart_r = tstart_d[0] & ~tstart_d[1];
 
 //tpd
 reg [7:0] tpd;
 
 always@(posedge clk or negedge rst) begin
    if(!rst) begin
        tpd <= 8'hff;
    end
    else begin
        if(txck_r == 1) begin
            if(tstart_r == 1) begin
                tpd <= txpd;
            end
            else begin
                tpd <= tpd;
            end
        end
        else begin
            tpd <= tpd;
        end
    end
 end
 
 //data count
 reg [3:0] dcnt;
 
 always@(posedge clk or negedge rst) begin
    if(!rst) begin
        dcnt <= 4'hf;
    end
    else begin
        if(txck_r == 1) begin
            if(tstart_r == 1) begin
                dcnt <= 0;
            end
            else begin
                if(dcnt < 15) begin
                    dcnt <= dcnt + 1;
                end
                else begin
                    dcnt <= dcnt;
                end
            end
        end
        else begin
            dcnt <= dcnt;
        end
    end
 end
 
 //txsd
 
 always@(posedge clk or negedge rst) begin
    if(!rst) begin
        txsd <= 1;
    end
    else begin
        if(txck_r == 1) begin
            case(dcnt)
                0 : txsd <= 0;
                1 : txsd <= tpd[0];
                2 : txsd <= tpd[1];
                3 : txsd <= tpd[2];
                4 : txsd <= tpd[3];
                5 : txsd <= tpd[4];
                6 : txsd <= tpd[5];
                7 : txsd <= tpd[6];
                8 : txsd <= tpd[7];
                9 : txsd <= 1;
                default : txsd <=txsd;
            endcase
        end
        else begin
            txsd <= txsd;
        end
    end
 end
endmodule