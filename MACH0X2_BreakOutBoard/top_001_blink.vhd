-----------------------------------------------------------------------------------------
-- blink
--
-- minimalistic blink example
--
-- hardware: MACHXO2 7000HE breakout board
--
-- 2.Sept 2017 by ChrisMicro
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
			led : BUFFER STD_LOGIC
		);
END blinker;

ARCHITECTURE logic OF blinker IS
	
	SIGNAL clk        : STD_LOGIC ; -- clk signal driven from the lattice build in oscillator
	--obsolete: 
	--SIGNAL clkCounter : STD_LOGIC_VECTOR ( 24 downto 0 ); 
	--use unsigned instead
	SIGNAL clkCounter : UNSIGNED( 24 downto 0 );
	
	-- oscillator from lattice library
	 COMPONENT OSCH
		GENERIC
		(
			NOM_FREQ: string :="53.20"
		);
		PORT
		(
			STDBY    : IN  STD_LOGIC;
			OSC      : OUT STD_LOGIC;
			SEDSTDBY : OUT STD_LOGIC   -- no semckolon in last line
		);
	END COMPONENT;
		
BEGIN
    -- make a instance of the oscillator and map it to the design
	SysClkOscillatorInstance0: OSCH
		GENERIC MAP ( NOM_FREQ => "53.20")
		PORT MAP ( STDBY => '0', OSC => clk, SEDSTDBY=> OPEN );
	
	PROCESS(clk)
	BEGIN	
		IF rising_edge( clk ) THEN
			clkCounter <= clkCounter +1;
			led        <= clkCounter( 24 ); -- output the highest bit to the led
		END IF;
	END PROCESS;
	
END logic;

