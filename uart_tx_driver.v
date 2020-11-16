/******************UART驱动模块*********************
***功 能：UART发送协议的具体实现
***例 化：uart_tx_driver I0(.nrst(),.sysClk(),.txEnable(),.indata(),.uartTxd,.txResult());
**************************************************/

module uart_tx_driver
(
	input nrst,								//复位
	input	sysClk,							//系统时钟,50MHz
	input txEnable,						//发送数据使能，高电平有效
	input [7:0] indata,					//待发送数据
	
	output uartTxd,						//UART输出端口
	output txResult						//发送结果，高电位表示发送结束
//	output [3:0] bitCtr					//调试用
);


//--------------波特率设置-----------
parameter baudCntEnd = 6'd17;			//波特率选择为115200bps
parameter pulsePoint = 6'd16;			//脉冲生成点
	
//------------数据发送时钟计数--------
reg [5:0] baudCnt;
always @(posedge sysClk or negedge nrst)
begin
	if(!nrst)
		baudCnt <= 6'd0;
	else if(baudCnt == baudCntEnd || txEnable == 1'b0)
		baudCnt <= 6'd0;
	else
		baudCnt <= baudCnt + 1'b1;
end


//------------数据发送时钟生成----------
reg uartClk;
always @(posedge sysClk or negedge nrst)
begin
	if(!nrst)
		uartClk <= 1'b0;
	else if(baudCnt == pulsePoint)		//发送时钟脉冲不在baudCnt终点生成
		uartClk <= 1'b1;
	else
		uartClk <= 1'b0;
end


//------------数据发送位计数-------------
wire [3:0] bitCtr;
reg [3:0] bitCtr_tmp;
always @(posedge sysClk or negedge nrst)
begin
	if(!nrst)
		bitCtr_tmp <= 1'b0;
	else if(bitCtr_tmp == 4'd11)
		bitCtr_tmp <= 1'b0;
	else if(uartClk)
		bitCtr_tmp <= bitCtr_tmp + 1'b1;
end
assign bitCtr = bitCtr_tmp;

//------------数据发送结束标志-----------
reg txResult_tmp;
always @(posedge sysClk or negedge nrst)
begin
	if(!nrst)
		txResult_tmp <= 1'b0;
	else if(bitCtr == 4'd11)
		txResult_tmp <= 1'b1;
	else
		txResult_tmp <= 1'b0;
end
assign txResult= txResult_tmp;


//-------------数据发送----------------
reg uartTxd_tmp;
always @(posedge sysClk or negedge nrst)
begin
	if(!nrst)
		uartTxd_tmp <= 1'b1;
	else
		case(bitCtr)
			4'd0:		uartTxd_tmp <= 1'b1;		//无效位
			4'd1:		uartTxd_tmp <= 1'b0;		//起始位
			4'd2:		uartTxd_tmp <= indata[0];
			4'd3:		uartTxd_tmp <= indata[1];
			4'd4:		uartTxd_tmp <= indata[2];
			4'd5:		uartTxd_tmp <= indata[3];
			4'd6:		uartTxd_tmp <= indata[4];
			4'd7:		uartTxd_tmp <= indata[5];
			4'd8:		uartTxd_tmp <= indata[6];
			4'd9:		uartTxd_tmp <= indata[7];
			4'd10:	uartTxd_tmp <= 1'b1;		//停止位
			default:	uartTxd_tmp <= 1'b1;
		endcase
end
assign uartTxd = uartTxd_tmp;


endmodule
