-----------------------------------------------------------------------------------------
-- blink
--
-- minimalistic blink example
--
-- hardware: MACHXO2 7000HE breakout board
--
-- 29.Sept 2017 by ChrisMicro
--
-- This example is public domain as long as you keep the list of authors
-- 
-----------------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; -- needed for the '+' operator for SIGNED and UNSIGNED data type

--obsolete:
--USE ieee.std_logic_unsigned.all; -- needed for the '+' operator on STD_LOGIC_VECTOR 
--see https://www.mikrocontroller.net/articles/Rechnen_in_VHDL

ENTITY blinker IS
	PORT( 
			clk : in  STD_LOGIC;
			led : out STD_LOGIC
		);
END blinker;

ARCHITECTURE logic OF blinker IS
	
	--obsolete: 
	--SIGNAL clkCounter : STD_LOGIC_VECTOR ( 24 downto 0 ); 
	--use unsigned instead
	SIGNAL clkCounter : UNSIGNED( 24 downto 0 );
			
BEGIN

	PROCESS(clk)
	BEGIN	
		IF rising_edge( clk ) THEN
			clkCounter <= clkCounter +1;
			led        <= clkCounter( 24 ); -- output the highest bit to the led
		END IF;
	END PROCESS;
	
END logic;


-----------------------------------------------------------------------------------------------------------------------
--
-- hardware specific part 
-- 
-- Board used:	 Lattice Semiconductor LCMXO2-7000HE-B-EVN MachXO2 Breakout Board 
--
-- on board leds:
-- LOCATE COMP "leds[0]" SITE "97" ;
-- LOCATE COMP "leds[1]" SITE "98" ;
-- LOCATE COMP "leds[2]" SITE "99" ;
-- LOCATE COMP "leds[3]" SITE "100" ;
-- LOCATE COMP "leds[4]" SITE "104" ;
-- LOCATE COMP "leds[5]" SITE "105" ;
-- LOCATE COMP "leds[6]" SITE "106" ;
-- LOCATE COMP "leds[7]" SITE "107" ;
--
-----------------------------------------------------------------------------------------------------------------------
library ieee;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL; 

entity top_MACHX02 is
	Port	(  
				leds	: out STD_LOGIC_VECTOR ( 7 downto 0 )
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
	
	-- use sub vhdl blinker
	component blinker
		port( 
				clk : in std_logic;
				led : out STD_LOGIC
			 );
	end component;
	
   signal   system_clk		: STD_LOGIC;
   
begin
	--  connect lattice internal oscillator OSCH primitive
	OSC0: OSCH
		generic map ( NOM_FREQ  => "53.20")  -- 53.2 MHz syssysclk
		port map	( STDBY => '0', OSC => system_clk, SEDSTDBY => OPEN);
				
	-- connect blinker			
	blinker0: blinker	
		port map	( clk => system_clk, led => leds(0) ); -- connect led0 to blinker
	
	leds( 7 downto 1 ) <=  not "0000000"; -- leds off, leds are active low

end architecture;

