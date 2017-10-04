-----------------------------------------------------------------------------------------
-- tx uart demonstration
--
-- transmit the ascii number from 0 .. 9 with 9600 baud
--
-- hardware: MACHXO2 7000HE breakout board
--
-- 4.October 2017 by ChrisMicro
--
-- This example is public domain as long as you keep the list of authors
-- 
-----------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity sender IS
	port( 
			clk				: in  STD_LOGIC;
			testOut	: out STD_LOGIC;
			txPin: out std_logic
		);
end entity sender;

architecture logic OF sender IS
		
	component clkDivider is
		generic ( FREQUENCY_HZ:integer);
		port( 
				fastClk	: in  STD_LOGIC;
				slowPulse	: out STD_LOGIC
			);
	end component clkDivider ;
	
	component txUart is
		port(
			sysClk: in std_logic;
			txPulseClk: in std_logic;
			start: in std_logic;
			data: in std_logic_vector ( 7 downto 0 );
			ready : out std_logic;
			txOut: out std_logic
		);
	end component txUart;

	signal testSignal: std_logic := '0';
	signal txStart: std_logic:='0';
	signal txPinSignal: std_logic;
	signal baudRatePulse:std_logic;
	signal counter:integer range 48 to 57 := 48; -- ascii char from 0..9
	signal dataVector:std_logic_vector ( 7 downto 0 );

begin
	
	baudRateDivider0: clkDivider
		generic map ( FREQUENCY_HZ=>9600)
		port map ( fastClk => clk, slowPulse => baudRatePulse);
		
	txSendByteDivider0: clkDivider
		generic map ( FREQUENCY_HZ=>10)
		port map ( fastClk => clk, slowPulse => txStart);
		
	txUart0: txUart
		port map ( sysClk=> clk, txPulseClk=>baudratePulse, start=>txStart, data => dataVector, ready=>testSignal, txOut=>txPinSignal );
		
		dataVector <= std_logic_vector( to_unsigned( counter,8 ) );
	
	-- send characters
	process 
	begin
		wait until rising_edge(clk);
		if(txStart='1') then
			-- the counter counts chars from 0 .. 9 ( ascii 48..57 )
			if(counter<57) then  
				counter <= counter +1;
			else
				counter <=48;
			end if;
		end if;
	end process;
	
	testOut <= testSignal; -- just a test signal to show the sender timing
	txPin <= txPinSignal;

end logic;
-----------------------------------------------------------------------------------------
-- tx_uart
-----------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

entity txUart is
	port(
		sysClk: in std_logic;
		txPulseClk: in std_logic;
		start: in std_logic;
		data: in std_logic_vector ( 7 downto 0 );
		ready : out std_logic;
		txOut: out std_logic
	);
end entity txUart;

architecture rtl of txUart is
	signal txsr      : unsigned(8 downto 0) := "111111111";
	signal bitCounter: integer  range 0 to 10:=10;
begin
	process begin
		wait until rising_edge(sysClk);
		if(start='1') then
			ready<='0';
			bitCounter <= 0;
			txsr <= unsigned(data) & '0';
		elsif(txPulseClk='1')then
			if (bitCounter<10)then
				txOut<=txsr(0);
				txsr <= '1' & txsr(8 downto 1 ); -- shift right
				bitCounter<=bitCounter+1;
			else
				ready<='1';
			end if;
		end if;
	end process;

end architecture;
	
-----------------------------------------------------------------------------------------
-- clock divider
-----------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; 

entity clkDivider is
	generic ( FREQUENCY_HZ:integer:=1000);
	port( 
			fastClk		: in  STD_LOGIC;
			slowPulse	: out STD_LOGIC
		);
end entity clkDivider ;

architecture logic OF clkDivider  IS
	
	constant	SYSCLK_HZ		: integer := 53200000;
	signal		prescaler		: integer range 0 to SYSCLK_HZ/(FREQUENCY_HZ)-1 := 0; 
	constant	PRESCALERMAX 	: integer range 0 to SYSCLK_HZ/(FREQUENCY_HZ)-1 := SYSCLK_HZ/(FREQUENCY_HZ)-1 ; 
	
	signal		slowPulseSignal	: std_logic := '0';

begin
	
	process begin  
  
		wait until rising_edge( fastClk );  
			if ( prescaler < PRESCALERMAX ) then  
				prescaler <= prescaler+1;
				slowPulseSignal <= '0';				
			else                          	
				prescaler <= 0;                  
				slowPulseSignal <= '1'; 
			end if; 

	end process; 
	
	slowPulse <= slowPulseSignal;

end logic;


-----------------------------------------------------------------------------------------------------------------------
--
-- hardware specific part 
-- 
-- Board used:	 Lattice Semiconductor LCMXO2-7000HE-B-EVN MachXO2 Breakout Board 
--
-- on board leds:
--LOCATE COMP "led_pins[0]" SITE "97" ;
--LOCATE COMP "led_pins[1]" SITE "98" ;
--LOCATE COMP "led_pins[2]" SITE "99" ;
--LOCATE COMP "led_pins[3]" SITE "100" ;
--LOCATE COMP "led_pins[4]" SITE "104" ;
--LOCATE COMP "led_pins[5]" SITE "105" ;
--LOCATE COMP "led_pins[6]" SITE "106" ;
--LOCATE COMP "led_pins[7]" SITE "107" ;
--LOCATE COMP "speaker_pin" SITE "84" ;
--
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL; 

entity top_MACHX02 is
	port	(  
				led_pins	: out STD_LOGIC_VECTOR ( 7 downto 0 );
				speaker_pin : out std_logic;
				systemTxPin: out std_logic
			); 
end entity;

architecture Behaviour of top_MACHX02 is

   -- lattice oscillator OSCH primitive
	component OSCH  
		generic	(
					NOM_FREQ: string
				);
 
		port	( 
					STDBY    : IN  STD_LOGIC;
					OSC      : OUT STD_LOGIC;
					SEDSTDBY : OUT STD_LOGIC
				);
	end component;
	
	-- use sub vhdl sender
	component sender
		port( 
				clk : in std_logic;
				testOut : out STD_LOGIC;
				txPin: out std_logic
			 );
	end component;
	
   signal   clk_signal		: std_logic;
   signal	speaker_signal	: std_logic;
   signal	txUartSignal	: std_logic;
   
begin
	--  connect lattice internal oscillator OSCH primitive
	OSC0: OSCH
		generic map ( NOM_FREQ  => "53.20")  -- 53.2 MHz syssysclk
		port map	( STDBY => '0', OSC => clk_signal, SEDSTDBY => OPEN);
				
	-- connect sender			
	sender0: sender	
		port map	( clk => clk_signal, testOut => speaker_signal, txPin => txUartSignal ); 
	
	led_pins( 7 downto 2 )	<= not "000000"; -- leds off, leds are active low
	led_pins( 0 )			<= speaker_signal; -- just to show some reaction
	speaker_pin				<= speaker_signal;
	led_pins( 1)			<= txUartSignal;
	systemTxPin				<= txUartSignal;

end architecture;
