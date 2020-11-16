/***************UART数据控制模块******************
****功 能：为外部提供数据接口
****例 化：uart_tx_control I0(.nrst(),.sysClk(),.ready(),.indata(),.driverFree(),.rdover(),.driverFlag(),.outdata());
************************************************/

module uart_tx_control
(
	input nrst,											//异步复位
	input sysClk,										//系统时钟，50MHz
	input ready,										//数据就绪标志，高电平时可以读取
	input [95:0] indata,								//48位待发送数据
	input driverFree,									//UART驱动端空闲标志
	
	output rdover,										//已读取过数据的标志，高电平表示已读取									
	output driverFlag,								//允许驱动端发送标志，高电位允许
	output [7:0] outdata,							//8位驱动端数据
	input	 data_rec									//记录数据	
);


//-----------------读取数据----------------------------
//---当数据准备好（ready置位）且允许更新数据（busy置零）时，
//---更新缓冲器中的数据
//----------------------------------------------------
wire busy;												//置位标志正在发送数据，不允许indata变化
wire [95:0] buffer;
reg [7:0]	tx_flag;									//发送数据前8位标志位 显示或者显示并记录
reg rdover_tmp;
reg [95:0] buffer_tmp;
always @(posedge sysClk or negedge nrst)
begin
	if(!nrst)
	begin
		buffer_tmp <= 96'd0;
		rdover_tmp <= 1'b0;
		tx_flag <= 8'b0;
	end
	else if(~busy && ready)												//ready=1，rdover=0时，表示有新数据未被读取；当busy=0后，
	begin																		//读取完数据rdover=1，外部检测到rdover的变化，使ready=0，
		rdover_tmp <= 1'b1;												//故而使rdover=0，进入ready=0,rdover=0的状态
		buffer_tmp <= indata;
		if (data_rec)
			tx_flag <= 8'b1100_1100;
		else
			tx_flag <= 8'b1100_0011;
	end
	else
		rdover_tmp <= 1'b0;
end
assign rdover = rdover_tmp;
assign buffer = buffer_tmp;


//-------------------数据帧控制-------------------------------
//--96位数据需分12帧发送，再加上一帧校验帧，一次有效数据需13帧发送
//-----------------------------------------------------------
wire [3:0] frameCnt;
reg [3:0] frameCnt_tmp;
always @(posedge sysClk or negedge nrst)
begin
	if(!nrst)
		frameCnt_tmp <= 4'd0;
	else if(~busy && ready)
		frameCnt_tmp <= 4'd0;
	else if(driverFree)
		frameCnt_tmp <= frameCnt_tmp + 1'b1;
end
assign frameCnt = frameCnt_tmp;


//------------------状态控制-----------------------
//--在frameCnt为1~12时，发送数据帧
//------------------------------------------------
reg busy_tmp;
reg driverFlag_tmp;
always @(posedge sysClk or negedge nrst)
begin
	if(!nrst)
	begin
		busy_tmp <= 1'b0;		driverFlag_tmp <= 1'b0;
	end
	else
		case(frameCnt)
			4'd0,4'd1,4'd2,4'd3,4'd4,4'd5,4'd6,
			4'd7,4'd8,4'd9,4'd10,4'd11,4'd12:
					begin
						busy_tmp <= 1'b1;		driverFlag_tmp <= 1'b1;
					end
			default:
					begin
						busy_tmp <= 1'b0;		driverFlag_tmp <= 1'b0;				//当frameCnt=7时，driverFlag=0，使得driverFree一直为0，frameCnt无法继续增加
					end																		//故frameCnt最大值为7,；当ready来临时，会使frameCnt清零。
		endcase	
end
assign busy = busy_tmp;
assign driverFlag = driverFlag_tmp;


//-------------------数据分割------------------
reg [7:0] outdata_tmp;
always @(*)
begin
	if(!nrst)
		outdata_tmp = 8'd0;
	else
		case(frameCnt)
			4'd0:		outdata_tmp = tx_flag;			//检验帧
			4'd3:		outdata_tmp = buffer[7:0];
			4'd2:		outdata_tmp = buffer[15:8];
			4'd1:		outdata_tmp = buffer[23:16];
			4'd6:		outdata_tmp = buffer[31:24];
			4'd5:		outdata_tmp = buffer[39:32];
			4'd4:		outdata_tmp = buffer[47:40];			//48位数据中的前8位为标志位
			4'd9:		outdata_tmp = buffer[55:48];
			4'd8:		outdata_tmp = buffer[63:56];
			4'd7:		outdata_tmp = buffer[71:64];
			4'd12:	outdata_tmp = buffer[79:72];
			4'd11:	outdata_tmp = buffer[87:80];
			4'd10:	outdata_tmp = buffer[95:88];
			default:	outdata_tmp = 8'd0;
		endcase
end
assign outdata = outdata_tmp;

endmodule
