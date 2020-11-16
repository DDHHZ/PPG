
/********************************UART通讯模块******************************************
****时钟信号：sysClk，频率为50MHz
****波 特 率：115200bps
****操作接口：当待发送20位数据indata准备完毕时，dataReady信号置位，channel标志该数据来自哪个通道
				 读取rdover状态，若该位为0，表示新数据还未被读取，此时应保持ready为高电平
				 读取rdover状态为1，则表示数据已被读取，此时应将ready位清零
****例    化：uart I0(.nrst(),.sysClk(),.dataReady(),.indata(),.rdover(),.uartTxd());
**************************************************************************************/

module uart
(
	input nrst,
	input sysClk,							//50MHz时钟
	input dataReady,						//数据可读取标志
	input [95:0] indata,					//数据接口
	
	output rdover,							//uart已读取数据标志
	output uartTxd,
	input	 data_rec						//发送数据前8位标志位 显示或者显示并记录
);

wire driverFree;
wire txEnable;
wire [7:0] txData;

uart_tx_control I0(.nrst(nrst),.sysClk(sysClk),.ready(dataReady),.indata(indata),
						 .driverFree(driverFree),.rdover(rdover),
						 .driverFlag(txEnable),.outdata(txData),
						 .data_rec(data_rec));

uart_tx_driver  I1(.nrst(nrst),.sysClk(sysClk),.txEnable(txEnable),.indata(txData),
						 .uartTxd(uartTxd),.txResult(driverFree));
endmodule
