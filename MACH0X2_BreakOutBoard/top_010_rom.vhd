-----------------------------------------------------------------------------------------
-- ROM 
--
-- example how to use it
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
			clk		: in  STD_LOGIC;
			leds	: out std_logic_vector ( 7 downto 0 )
		);
END blinker;

ARCHITECTURE logic OF blinker IS

	type rom_t is array (natural range <>) of unsigned(7 downto 0); 
	
	constant rom: rom_t := (
							"10000001",
							"01000010",
							"00100100",
							"00011000",
							"00011000",
							"00100100",
							"01000010",	
							"10000001"
							);

	constant ROMLENGTH		: integer 	:= rom'length;
	signal	address			: integer range 0 to ROMLENGTH := 0 ;
	
	constant FREQUENCY_HZ	: integer := 4; -- Hz
	signal	prescaler		: integer range 0 to 53200000/(2*FREQUENCY_HZ)-1 := 0; 
	signal	PRESCALERMAX 	: integer range 0 to 53200000/(2*FREQUENCY_HZ)-1 := 53200000/(2*FREQUENCY_HZ)-1 ; --  bei 53.2MHz fosc
	
			
BEGIN

	process(clk)
	begin	
		if rising_edge( clk ) then
			if ( prescaler < PRESCALERMAX) then
				prescaler <= prescaler +1;
			else
				prescaler <= 0;
				if( address < ROMLENGTH ) then
					address <= address +1;
					leds <= std_logic_vector(unsigned(rom(address)));
				else
					address <= 0;
					end if;
			end if;
		end if;
	end process;
	
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
				leds	: out std_logic_vector ( 7 downto 0 )
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
				leds : out std_logic_vector ( 7 downto 0 )
			 );
	end component;
	
   signal   system_clk : STD_LOGIC;
   signal system_leds  : std_logic_vector ( 7 downto 0 );
   
begin
	--  connect lattice internal oscillator OSCH primitive
	OSC0: OSCH
		generic map ( NOM_FREQ  => "53.20")  -- 53.2 MHz syssysclk
		port map	( STDBY => '0', OSC => system_clk, SEDSTDBY => OPEN);
				
	-- connect blinker			
	blinker0: blinker	
		port map	( clk => system_clk, leds => system_leds ); -- connect led0 to blinker
	
	leds <= not system_leds;

end architecture;

