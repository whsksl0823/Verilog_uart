module uart_top(
    input clk,
    input rst,
    input [15:0] bcd,
    input start,
    input txck,
    input [10:0] dv,
    output [7:0] rxpd,
    output rxen,
    output rx_start
);

//tx232_pd_multibyte
wire [7:0] txpd;
wire tnpd;

tx232_pd_multibyte u_tx232_pd_multibyte(
.clk(clk),
.rst(rst),
.bcd(bcd),
.start(start),
.txck(txck),
.txpd(txpd),
.tnpd(tnpd)
);

/*
//tx232_pd
wire [7:0] txpd;
wire tnpd;

tx232_pd u_tx232_pd(
.clk(clk),
.rst(rst),
.bcd(bcd),
.start(start),
.txck(txck),
.txpd(txpd),
.tnpd(tnpd)
);
*/

//tx232
wire txsd;

tx232 u_tx232(
.clk(clk),
.rst(rst),
.txpd(txpd),
.tstart(tnpd),
.txck(txck),
.txsd(txsd)
);

//uart_delay
wire txsdo;

uart_delay u_uart_delay(
.clk(clk),
.rst(rst),
.dv(dv),
.txsdi(txsd),
.txsdo(txsdo)
);



//DEBUG ���� ���� - RXCK���� ���� �߻� (dv == 1035�� �� �۸�ġ�� ����)
/*
//rx232_clk
wire rxck;
wire rxsdo;

rx232_clk u_rx232_clk(
.clk(clk),
.rst(rst),
.rxsdi(txsdo),
.rxck(rxck),
.rxsdo(rxsdo)
);


//rx232_pd
//wire [7:0] rxpd

rx232_pd u_rx232_pd(
.clk(clk),
.rst(rst),
.rxck(rxck),
.rxsdi(rxsdo),
.rxpd(rxpd),
.rxen(rxen),
.rx_start(rx_start)
);
*/


//DEBUG1 - ���ϴ� ���������� RXCK ����

/*
//rx232_clk_debug
wire rxck;
wire rxsdo;
wire rcen;

rx232_clk_debug u_rx232_clk_debug(
.clk(clk),
.rst(rst),
.rxsdi(txsdo),
.rxck_en(rxck_en),
.rxck(rxck),
.rxsdo(rxsdo)
);

//rx232_pd_debug
//wire [7:0] rxpd

rx232_pd_debug u_rx232_pd_debug(
.clk(clk),
.rst(rst),
.rxck(rxck),
.rxsdi(rxsdo),
.rxpd(rxpd),
.rxen(rxen),
.rx_start(rx_start),
.rxck_en(rxck_en)
);
*/

//DEBUG2 - RXCK BUG�� �߻��� ��ȣ �ذ�

//rx232_clk_debug2
wire rxck;
wire rxsdo;

rx232_clk_debug2 u_rx232_clk_debug2(
.clk(clk),
.rst(rst),
.rxsdi(txsdo),
.rxck(rxck),
.rxsdo(rxsdo)
);


//rx232_pd_debug2
//wire [7:0] rxpd

rx232_pd_debug2 u_rx232_pd_debug2(
.clk(clk),
.rst(rst),
.rxck(rxck),
.rxsdi(rxsdo),
.rxpd(rxpd),
.rxen(rxen),
.rx_start(rx_start)
);

endmodule