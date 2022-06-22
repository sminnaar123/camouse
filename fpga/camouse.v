module camouse
(
	// CLOCK
	input 		          		CLOCK2_50,
	input 		          		CLOCK3_50,
	input 		          		CLOCK_50,

	// LED
	output		     [8:0]		LEDG,
	output		    [17:0]		LEDR,

	// KEY
	input 		     [3:0]		KEY,

	// SW
	input 		    [17:0]		SW,

	// SEG7
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output		     [6:0]		HEX4,
	output		     [6:0]		HEX5,
	output		     [6:0]		HEX6,
	output		     [6:0]		HEX7,

	// LCD
	output		          		LCD_BLON,
	inout 		     [7:0]		LCD_DATA,
	output		          		LCD_EN,
	output		          		LCD_ON,
	output		          		LCD_RS,
	output		          		LCD_RW,

	// VGA
	output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS,

	// SDRAM
	output		    [12:0]		DRAM_ADDR,
	output		     [1:0]		DRAM_BA,
	output		          		DRAM_CAS_N,
	output		          		DRAM_CKE,
	output		          		DRAM_CLK,
	output		          		DRAM_CS_N,
	inout 		    [31:0]		DRAM_DQ,
	output		     [3:0]		DRAM_DQM,
	output		          		DRAM_RAS_N,
	output		          		DRAM_WE_N,

	// GPIO, GPIO connect to D8M-GPIO
	inout 		          		CAMERA_I2C_SCL,
	inout 		          		CAMERA_I2C_SDA,
	output		          		CAMERA_PWDN_n,
	output		          		MIPI_CS_n,
	inout 		          		MIPI_I2C_SCL,
	inout 		          		MIPI_I2C_SDA,
	output		          		MIPI_MCLK,
	input 		          		MIPI_PIXEL_CLK,
	input 		     [9:0]		MIPI_PIXEL_D,
	input 		          		MIPI_PIXEL_HS,
	input 		          		MIPI_PIXEL_VS,
	output		          		MIPI_REFCLK,
	output		          		MIPI_RESET_n
);


//=============================================================================
// REG/WIRE declarations
//=============================================================================


wire	[15:0]	SDRAM_RD_DATA;
wire				DLY_RST_0;
wire				DLY_RST_1;
wire				DLY_RST_2;

wire				SDRAM_CTRL_CLK;
wire        	D8M_CK_HZ ; 
wire        	D8M_CK_HZ2 ; 
wire        	D8M_CK_HZ3 ; 

wire 	[7:0] 	RED; 
wire 	[7:0] 	GREEN; 
wire 	[7:0] 	BLUE; 
wire 	[12:0] 	VGA_H_CNT;			
wire 	[12:0] 	VGA_V_CNT;	

wire        	READ_Request;
wire 	[7:0] 	B_AUTO;
wire 	[7:0] 	G_AUTO;
wire 	[7:0] 	R_AUTO;
wire        	RESET_N; 

wire        	I2C_RELEASE;  
wire        	AUTO_FOC; 
wire        	CAMERA_I2C_SCL_MIPI; 
wire        	CAMERA_I2C_SCL_AF;
wire        	CAMERA_MIPI_RELEASE;
wire        	MIPI_BRIDGE_RELEASE;  
 
wire        	LUT_MIPI_PIXEL_HS;
wire        	LUT_MIPI_PIXEL_VS;
wire [9:0]  	LUT_MIPI_PIXEL_D ;
wire        	MIPI_PIXEL_CLK_; 
wire [9:0]  	PCK;


//=======================================================
// Structural coding
//=======================================================


// INPUT MIPI-PIXEL-CLOCK DELAY
CLOCK_DELAY  del1(.iCLK(MIPI_PIXEL_CLK), .oCLK(MIPI_PIXEL_CLK_));


//	D8M INPUT Gamma Correction
D8M_LUT  g_lut(
	.enable           		(1),
	.PIXEL_CLK        		(MIPI_PIXEL_CLK_),
	.MIPI_PIXEL_HS    		(MIPI_PIXEL_HS),
	.MIPI_PIXEL_VS    		(MIPI_PIXEL_VS),
	.MIPI_PIXEL_D     		(MIPI_PIXEL_D),
	.NEW_MIPI_PIXEL_HS		(LUT_MIPI_PIXEL_HS),
	.NEW_MIPI_PIXEL_VS		(LUT_MIPI_PIXEL_VS),
	.NEW_MIPI_PIXEL_D 		(LUT_MIPI_PIXEL_D)
);


//	UART OFF
assign UART_RTS = 0;
assign UART_TXD = 0;


// HEX OFF
assign HEX0           = 7'h7F;
assign HEX1           = 7'h7F;
assign HEX2           = 7'h7F;
assign HEX3           = 7'h7F;
assign HEX4           = 7'h7F;
assign HEX5           = 7'h7F;
assign HEX6           = 7'h7F;
assign HEX7           = 7'h7F;


// MIPI BRIGE & CAMERA RESET
assign CAMERA_PWDN_n  = 1; 
assign MIPI_CS_n      = 0; 
assign MIPI_RESET_n   = RESET_N;


// CAMERA MODULE I2C SWITCH
assign I2C_RELEASE    = CAMERA_MIPI_RELEASE & MIPI_BRIDGE_RELEASE;
assign CAMERA_I2C_SCL = I2C_RELEASE ? CAMERA_I2C_SCL_AF : CAMERA_I2C_SCL_MIPI;


// RESET RELAY
RESET_DELAY u2
(	
	.iRST  		(KEY[0]),
	.iCLK  		(CLOCK2_50),
	.oRST_0		(DLY_RST_0),
	.oRST_1		(DLY_RST_1),
	.oRST_2		(DLY_RST_2),					
	.oREADY		(RESET_N)
);


// MIPI BRIGE & CAMERA SETTING 
MIPI_BRIDGE_CAMERA_Config cfin
(
	.RESET_N           	(RESET_N), 
	.CLK_50            	(CLOCK2_50), 
	.MIPI_I2C_SCL      	(MIPI_I2C_SCL), 
	.MIPI_I2C_SDA      	(MIPI_I2C_SDA), 
	.MIPI_I2C_RELEASE  	(MIPI_BRIDGE_RELEASE),  
	.CAMERA_I2C_SCL    	(CAMERA_I2C_SCL_MIPI),
	.CAMERA_I2C_SDA    	(CAMERA_I2C_SDA),
	.CAMERA_I2C_RELAESE	(CAMERA_MIPI_RELEASE)
);


// MIPI REF CLOCK
pll_test pll_ref
(
	.inclk0 				(CLOCK3_50),
	.areset 				(~KEY[0]),
	.c0					(MIPI_REFCLK) //20Mhz
);


// VGA REF CLOCK
VIDEO_PLL pll_ref1
(
	.inclk0 				(CLOCK2_50),
	.areset 				(~KEY[0]),
	.c0					(VGA_CLK) //25 mhz
);


// SDRAM CLOCK GENNERATER
sdram_pll u6
(
	.areset				(0),     
	.inclk0				(CLOCK_50),              
	.c1    				(DRAM_CLK),       //100MHZ   -90 degree
	.c0    				(SDRAM_CTRL_CLK)  //100MHZ     0 degree
);


// SDRAM CONTROLLER
Sdram_Control u7
(
	//	HOST Side						
	.RESET_N     		(KEY[0]),
	.CLK         		(SDRAM_CTRL_CLK),
	
	.WR1_DATA    		(LUT_MIPI_PIXEL_D[9:0]),
	.WR1         		(LUT_MIPI_PIXEL_HS & LUT_MIPI_PIXEL_VS),

	.WR1_ADDR    		(0),
	//	FIFO Write Side 1
	.WR1_MAX_ADDR		(640*480),
	.WR1_LENGTH  		(256),
	.WR1_LOAD    		(!DLY_RST_0),
	.WR1_CLK     		(MIPI_PIXEL_CLK_),

	//	FIFO Read Side 1
	.RD1_DATA    		(SDRAM_RD_DATA[9:0]),
	.RD1         		(READ_Request),
	.RD1_ADDR    		(0),
	.RD1_MAX_ADDR		(640*480),
	.RD1_LENGTH  		(256),
	.RD1_LOAD    		(!DLY_RST_1),
	.RD1_CLK     		(VGA_CLK),
					
	//	SDRAM Side
	.SA          		(DRAM_ADDR),
	.BA          		(DRAM_BA),
	.CS_N        		(DRAM_CS_N),
	.CKE         		(DRAM_CKE),
	.RAS_N       		(DRAM_RAS_N),
	.CAS_N       		(DRAM_CAS_N),
	.WE_N        		(DRAM_WE_N),
	.DQ          		(DRAM_DQ),
	.DQM         		(DRAM_DQM)
);	 	 


// CMOS CCD_DATA TO RGB_DATA
RAW2RGB_J u4
(
	.RST          		(VGA_VS),
	.iDATA        		(SDRAM_RD_DATA[9:0]),
	
	.VGA_CLK      		(VGA_CLK),
	.READ_Request 		(READ_Request),
	.VGA_VS       		(VGA_VS),	
	.VGA_HS       		(VGA_HS), 
				
	.oRed         		(RED),
	.oGreen       		(GREEN),
	.oBlue        		(BLUE)
);

// Neural network for detecting a green color
green_nn gnn
(
	.clk_in				(VGA_CLK),
	.red_in         	(RED),
	.green_in       	(GREEN),
	.blue_in        	(BLUE),
	.result				(LEDG)
);

// Neural network for detecting a red color
red_nn rnn
(
	.clk_in				(VGA_CLK),
	.red_in         	(RED),
	.green_in       	(GREEN),
	.blue_in        	(BLUE),
	.result				(LEDR)
);


// AUTO FOCUS ENABLE
AUTO_FOCUS_ON vd
( 
	.CLK_50      		(CLOCK2_50), 
	.I2C_RELEASE 		(I2C_RELEASE), 
	.AUTO_FOC    		(AUTO_FOC)
);


// AUTO FOCUS ADJ
FOCUS_ADJ adl
(
	.CLK_50				(CLOCK2_50) , 
	.RESET_N				(I2C_RELEASE), 
	.RESET_SUB_N		(I2C_RELEASE), 
	.AUTO_FOC			(KEY[3] & AUTO_FOC), 
	.SW_Y					(0),
	.SW_H_FREQ			(0),   
	.SW_FUC_LINE		(SW[3]),   
	.SW_FUC_ALL_CEN	(SW[3]),
	.VIDEO_HS			(VGA_HS),
	.VIDEO_VS      	(VGA_VS),
	.VIDEO_CLK     	(VGA_CLK),
	.VIDEO_DE      	(READ_Request),
	.iR            	(R_AUTO), 
	.iG            	(G_AUTO), 
	.iB            	(B_AUTO), 
	.oR            	(VGA_R), 
	.oG            	(VGA_G), 
	.oB            	(VGA_B),
	.READY         	(READY),
	.SCL           	(CAMERA_I2C_SCL_AF), 
	.SDA           	(CAMERA_I2C_SDA)
);


// VGA Controller
VGA_Controller u1
(
	//	Host Side
	.oRequest			(READ_Request),
	.iRed					(RED),
	.iGreen				(GREEN),
	.iBlue				(BLUE),
	
	//	VGA Side
	.oVGA_R				(R_AUTO[7:0]),
	.oVGA_G				(G_AUTO[7:0]),
	.oVGA_B				(B_AUTO[7:0]),
	.oVGA_H_SYNC		(VGA_HS),
	.oVGA_V_SYNC		(VGA_VS),
	.oVGA_SYNC			(VGA_SYNC_N),
	.oVGA_BLANK			(VGA_BLANK_N),
	
	//	Control Signal
	.iCLK					(VGA_CLK),
	.iRST_N				(DLY_RST_2),
	.H_Cont				(VGA_H_CNT),
	.V_Cont				(VGA_V_CNT)
);

endmodule