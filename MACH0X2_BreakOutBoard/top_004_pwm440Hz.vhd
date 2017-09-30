-----------------------------------------------------------------------------------------
-- pwm
--
-- repeating increasing volume of a 440Hz square wave
--
-- hardware: MACHXO2 7000HE breakout board
--
-- 30.Okt 2017 by ChrisMicro
--
-- This example is public domain as long as you keep the list of authors
-- 
-----------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; -- needed for the '+' operator for SIGNED and UNSIGNED data type

entity squareWave IS
	port( 
			clk				: in  STD_LOGIC;
			speaker_signal	: out STD_LOGIC
		);
end entity squareWave;

architecture logic OF squareWave IS
	
	constant	SYSCLK_HZ		: integer := 53200000;
	constant	FREQUENCY_HZ	: integer := 440; 
	signal		prescaler		: integer range 0 to SYSCLK_HZ/(2*FREQUENCY_HZ)-1 := 0; 
	constant	PRESCALERMAX 	: integer range 0 to SYSCLK_HZ/(2*FREQUENCY_HZ)-1 := SYSCLK_HZ/(2*FREQUENCY_HZ)-1 ; 
	
	signal		volume			: integer range 0 to 1023 := 0;
	signal		dacSignal		: integer range 0 to 1023 := 512;
	
	
	component pwmDac
		port( 
				clk		: in STD_LOGIC;
				pwmValue: in integer range 0 to 1023;
				pwmOut	: out STD_LOGIC
			);
	end component;

begin
	
	dac0: pwmDac
		port map(clk=>clk, pwmValue => dacSignal, pwmOut => speaker_signal);
		
	process begin  
  
		wait until rising_edge( clk );  
		if ( prescaler < PRESCALERMAX) then  
			prescaler <= prescaler+1;                 
		else                          	
			prescaler <= 0;                  

			if(volume<1023)then
				volume <= volume+1;
			else
				volume <= 0;
			end if;
			
			--square wave
			if(dacSignal=0) then
				dacSignal <= volume;
			else
				dacSignal<=0;
			end if;
					
		end if; 

	end process; 
	


end logic;

------------------------------------------------------------------------------------------------
-- DAC
------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwmDac is
	port	( 
				clk		: in STD_LOGIC;
				pwmValue: in integer range 0 to 1023;
				pwmOut	: out STD_LOGIC
			);
end pwmDac;

architecture logic of pwmDac is
	signal counter : integer range 0 to 1023 := 0;

begin
	process begin
		
		wait until rising_edge(clk);
		
		if( counter < 1023 ) then
			counter <= counter +1;
		else
			counter<=0;
		end if;
		
	end process;

	pwmOut <= '1' when ( counter < pwmValue  ) else '0';

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
				speaker_pin : out std_logic
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
	
	-- use sub vhdl squareWave
	component squareWave
		port( 
				clk : in std_logic;
				speaker_signal : out STD_LOGIC
			 );
	end component;
	
   signal   clk_signal		: std_logic;
   signal	speaker_signal	: std_logic;
   
begin
	--  connect lattice internal oscillator OSCH primitive
	OSC0: OSCH
		generic map ( NOM_FREQ  => "53.20")  -- 53.2 MHz syssysclk
		port map	( STDBY => '0', OSC => clk_signal, SEDSTDBY => OPEN);
				
	-- connect squareWave			
	blinker0: squareWave	
		port map	( clk => clk_signal, speaker_signal => speaker_signal ); 
	
	led_pins( 7 downto 1 )	<= not "0000000"; -- leds off, leds are active low
	led_pins( 0 )			<= speaker_signal; -- just to show some reaction
	speaker_pin				<= speaker_signal;

end architecture;

