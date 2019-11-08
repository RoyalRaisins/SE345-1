// ==============================================================
//
// This stopwatch is just to test the work of LED and KEY on DE1-SOC board.
// The counter is designed by a series mode. / asynchronous mode. 即异步进位
// use "=" to give value to hour_counter_high and so on. 异步操作/阻塞赋值方式
//
// 3 key: key_reset/系统复位, key_start_pause/暂停计时, key_display_stop/暂停显示
//
// ==============================================================
module stopwatch_01(clk,key_reset,key_start_pause,key_display_stop,
	// 时钟输入+ 3个按键；按键按下为0 。板上利用施密特触发器做了一定消抖，效果待测试。
	hex0,hex1,hex2,hex3,hex4,hex5,
	// 板上的6个7段数码管，每个数码管有7位控制信号。
	led0,led1,led2,led3 );
	// LED发光二极管指示灯，用于指示/测试程序按键状态，若需要，可增加。高电平亮。
	input clk,key_reset,key_start_pause,key_display_stop;
	output [6:0] hex0,hex1,hex2,hex3,hex4,hex5;
	output led0,led1,led2,led3;
	reg led0,led1,led2,led3;
	reg display_work;
// 显示刷新，即显示寄存器的值实时 更新为计数寄存器的值。
reg counter_work;
// 计数（计时）工作状态，由按键“计时/暂停” 控制。
reg reset_work;
parameter DELAY_TIME = 5000000;
// 定义一个常量参数。 10000000 ->200ms；
// 定义6个显示数据（变量）寄存器：
reg [3:0] minute_display_high;
reg [3:0] minute_display_low;
reg [3:0] second_display_high;
reg [3:0] second_display_low;
reg [3:0] msecond_display_high;
reg [3:0] msecond_display_low;
// 定义6个计时数据（变量）寄存器：
reg [3:0] minute_counter_high;
reg [3:0] minute_counter_low;
reg [3:0] second_counter_high;
reg [3:0] second_counter_low;
reg [3:0] msecond_counter_high;
reg [3:0] msecond_counter_low;
reg [31:0] counter_50M; // 计时用计数器， 每个50MHz的clock 为20ns。
// DE1-SOC板上有4个时钟， 都为 50MHz，所以需要500000次20ns之后，才是10ms。
reg reset_1_time; // 消抖动用状态寄存器-- for reset KEY
reg [31:0] counter_reset; // 按键状态时间计数器
reg start_1_time; //消抖动用状态寄存器-- for counter/pause KEY
reg [31:0] counter_start; //按键状态时间计数器
reg display_1_time; //消抖动用状态寄存器-- for KEY_display_refresh/pause
reg [31:0] counter_display; //按键状态时间计数器
reg start; // 工作状态寄存器
reg display; // 工作状态寄存器
reg [31:0] timer;
// sevenseg模块为4位的BCD码至7段LED的译码器，
//下面实例化6个LED数码管的各自译码器。
sevenseg LED8_minute_display_high ( minute_display_high, hex5 );
sevenseg LED8_minute_display_low ( minute_display_low, hex4 );
sevenseg LED8_second_display_high( second_display_high, hex3 );
sevenseg LED8_second_display_low ( second_display_low, hex2 );
sevenseg LED8_msecond_display_high( msecond_display_high, hex1 );
sevenseg LED8_msecond_display_low ( msecond_display_low, hex0 );
initial
begin
	led0 = 1;
	display=1;
	start=1;
	counter_50M=0;
	counter_start=0;
	counter_work=0;
	counter_reset=0;
	timer=0;
end
always @ (posedge clk) // 每一个时钟上升沿开始触发下面的逻辑，
// 进行计时后各部分的刷新工作
begin
	led0 = key_start_pause;
	counter_50M=counter_50M+(1&&start);
	counter_work=key_start_pause;
	display_work=key_display_stop;
	reset_work=key_reset;
	counter_start=(start_1_time==counter_work)?counter_start+1:0;//counter_start*(start_1_time&&counter_work)+(start_1_time&&counter_work);
	counter_display=(display_1_time==display_work)?counter_display+1:0;//counter_display*(display_1_time&&display_work)+(display_1_time&&display_work);
	counter_reset=(reset_work==reset_1_time)?counter_reset+1:0;//counter_reset*(key_reset&&reset_1_time)+(key_reset&&reset_1_time);
	if(counter_50M==500000)
	begin
		timer=timer+1;
		counter_50M=0;
	end
	if((counter_display==DELAY_TIME)&&(display_1_time==0)) 
	begin
		display=!display;
	end
	if((counter_start==DELAY_TIME)&&(start_1_time==0)) 
	begin
		start=!start;
	end
	if(start)
	begin
		msecond_counter_low<=timer%10;
		msecond_counter_high<=timer/10%10;
		second_counter_low<=timer/100%10;
		second_counter_high<=timer/1000%6;
		minute_counter_low<=timer/6000%10;
		minute_counter_high<=timer/60000%6;
	end
	if(display)
	begin
		msecond_display_low<=msecond_counter_low;
		msecond_display_high<=msecond_counter_high;
		second_display_low<=second_counter_low;
		second_display_high<=second_counter_high;
		minute_display_low<=minute_counter_low;
		minute_display_high<=minute_counter_high;
	end
	start_1_time<=counter_work;
	display_1_time<=display_work;
	reset_1_time<=reset_work;
	if((counter_reset>DELAY_TIME)&&(reset_1_time==0))
	begin
		counter_50M=0;
		timer=0;
		start=0;
		msecond_counter_low<=0;
		msecond_counter_high<=0;
		second_counter_low<=0;
		second_counter_high<=0;
		minute_counter_low<=0;
		minute_counter_high<=0;
		display=1;
	end
//此处功能代码省略，由同学自行设计。
end
endmodule