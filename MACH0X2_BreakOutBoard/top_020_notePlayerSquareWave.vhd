-----------------------------------------------------------------------------------------
-- square wave note player
--
-- play a list of notes
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

ENTITY noteSequencer IS
	PORT( 
			clk		: in  STD_LOGIC;
			noteOut	: out integer range 0 to 7
		);
END noteSequencer;

ARCHITECTURE logic OF noteSequencer IS

	constant SOUNDOFF : integer := 0;
	constant PLAY_C: integer := 1 ;
	constant PLAY_D : integer := 1 ;
	constant PLAY_E : integer := 3 ;
	constant PLAY_F : integer := 4 ;
	constant PLAY_G : integer := 5 ;
	constant PLAY_A : integer := 6 ;
	constant PLAY_H : integer := 7 ;

	type rom_t is array (natural range <>) of integer range 0 to 7; 

	constant rom: rom_t := (
	PLAY_C,
	PLAY_D,
	PLAY_E,
	PLAY_F,
	PLAY_G,
	SOUNDOFF,
	PLAY_G,
	SOUNDOFF,
	PLAY_F,
	PLAY_F,
	PLAY_G,
	PLAY_G,
	PLAY_H,
	PLAY_H,
	PLAY_H,
	PLAY_H,
	SOUNDOFF,
	PLAY_G,
	PLAY_F,
	PLAY_E,
	PLAY_D,
	PLAY_C,

	SOUNDOFF,
	SOUNDOFF,
	SOUNDOFF,
	SOUNDOFF,
	SOUNDOFF,
	SOUNDOFF,
	SOUNDOFF,
	SOUNDOFF,
	SOUNDOFF
	);

	constant ROMLENGTH		: integer 	:= rom'length;
	signal	address			: integer range 0 to ROMLENGTH := 0 ;
	
	constant SYSCLK_HZ		: integer := 53200000;
	constant FREQUENCY_HZ	: integer := 2; -- player speed
	signal	prescaler		: integer range 0 to SYSCLK_HZ/(2*FREQUENCY_HZ)-1 := 0; 
	signal	PRESCALERMAX 	: integer range 0 to SYSCLK_HZ/(2*FREQUENCY_HZ)-1 := SYSCLK_HZ/(2*FREQUENCY_HZ)-1 ; 
	
			
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
					noteOut <= rom(address);
				else
					address <= 0;
					end if;
			end if;
		end if;
	end process;
	
END logic;

-----------------------------------------------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all; -- needed for the '+' operator for SIGNED and UNSIGNED data type

entity noteToneGenerator is 
	port (  
			clk			: in	STD_LOGIC;
			noteIn		: in	integer range 0 to 7;
			squareOut	: out	STD_LOGIC
         ); 
end noteToneGenerator; 
 
architecture Behavioral of noteToneGenerator is 

constant	SYSCLK_HZ		: integer := 53200000;

constant NOTE_C4 : integer := SYSCLK_HZ/(2*262)-1 ;
constant NOTE_D4 : integer := SYSCLK_HZ/(2*294)-1 ;
constant NOTE_E4 : integer := SYSCLK_HZ/(2*330)-1 ;
constant NOTE_F4 : integer := SYSCLK_HZ/(2*349)-1 ;
constant NOTE_G4 : integer := SYSCLK_HZ/(2*392)-1 ;
constant NOTE_A4 : integer := SYSCLK_HZ/(2*440)-1 ;
constant NOTE_H4 : integer := SYSCLK_HZ/(2*494)-1 ;
constant NOTE_C5 : integer := SYSCLK_HZ/(2*523)-1 ;

constant	MINFREQUENCY	: integer := 10; -- Hz
signal		prescaler		: integer range 0 to SYSCLK_HZ/(2*MINFREQUENCY)-1 := SYSCLK_HZ/(2*MINFREQUENCY)-1 ; 

signal		freqCounter	: integer range 0 to SYSCLK_HZ/(2*MINFREQUENCY)-1 := 0; 

constant	MAXNOTE		: integer := 7 ;
signal		note		: integer range 0 to MAXNOTE := 1 ;

signal		bitSignal	: std_logic := '0';

begin 

   soundGenerator:	process begin   
						wait until rising_edge( clk ); 
							if ( freqCounter < prescaler) then  
								freqCounter <= freqCounter+1;                
							else                         
								freqCounter <= 0;                  
								bitSignal <= not bitSignal;  -- toggle bitSignal
							end if; 
					end process soundGenerator ; 
   
   	squareOut <= bitSignal;
   
	-- note to frequency translation
	with noteIn select 
		prescaler <=	NOTE_C4 when 1 ,
						NOTE_D4 when 2 ,
						NOTE_E4 when 3 ,
						NOTE_F4 when 4 ,
						NOTE_G4 when 5 ,
						NOTE_A4 when 6 ,
						NOTE_H4 when 7 ,
						0 when others ;     	
				  
end Behavioral;



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
	
	component noteToneGenerator  
	port (  
			clk			: in	STD_LOGIC;
			noteIn		: in	integer range 0 to 7;
			squareOut	: out	STD_LOGIC
         ); 
	end component; 
	
	component noteSequencer
	PORT( 
			clk		: in  STD_LOGIC;
			noteOut	: out integer range 0 to 7
		);
	end component;
	
   signal   clk_signal		: std_logic;
   signal	speaker_signal	: std_logic;
   signal	noteSignal: integer range 0 to 7;
   
begin
	--  connect lattice internal oscillator OSCH primitive
	OSC0: OSCH
		generic map ( NOM_FREQ  => "53.20")  -- 53.2 MHz syssysclk
		port map	( STDBY => '0', OSC => clk_signal, SEDSTDBY => OPEN);
					
	generator0: noteToneGenerator
		port map ( clk => clk_signal, noteIn => noteSignal, squareOut => speaker_signal );
	
	sequencer0: noteSequencer
		port map ( clk => clk_signal, noteOut=> noteSignal );

	
	led_pins( 7 downto 1 )	<= not "0000000"; -- leds off, leds are active low
	led_pins( 0 )			<= speaker_signal; -- just to show some reaction
	speaker_pin				<= speaker_signal;

end architecture;

