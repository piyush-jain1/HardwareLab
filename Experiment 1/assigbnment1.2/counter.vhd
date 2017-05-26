--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------

-- 4 bit counter using D-flip flop

-- Made by:
--	GROUP 9
-- Mukul Verma
--  Piyush Jain
-- Saswata De
--  Shubhanshu Verma


--------------------------------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------------------



--Here we import the necessary libraries

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;

--------------------------------------------------------------------------------------------------------------------------------------------
--D FLIP FLOP
--------------------------------------------------------------------------------------------------------------------------------------------


-- D Flip Flop structure is declared here

entity D_Flip_Flop is
    port(
        D : in STD_LOGIC;        -- The input to D flip flop
        clk : in STD_LOGIC;         -- Clock
        reset : in STD_LOGIC;   -- reset port
        Q : out STD_LOGIC           -- Output of D flip flop
    );
end D_Flip_Flop;


-- Architecture of D flip flop is declared here
-- The output is baically the input given to D flip flop
-- If D = 0, then Q = 0   AND  If D = 1, then Q = 1

architecture Behaviour of D_Flip_Flop is 
begin 
    process (D,clk,reset) is
    variable output : std_logic := '0';              -- variable output is declared and initially assigned to 0
    begin
        if (reset = '1') then   output := '0';        -- If reset is 1 then output is made 0
        elsif ( clk'event and clk='1') then               -- Else when clock makes a transition from 0 to 1 (positive edge) 
            if (D = '0') then output := '0';              -- If D is 0 at that time , output is made 0
            elsif (D = '1') then output := '1';       -- If D is 1 at that time , output is made 1
            end if;
        end if;
        Q <= output;                                          -- Q(output of d flip flop) is assigned output
   end process; 
end Behaviour;


--------------------------------------------------------------------------------------------------------------------------------------------
-- 4 Bit Up Counter using D Flip Flop
--------------------------------------------------------------------------------------------------------------------------------------------


library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;

-- Structure of counter is declared here

entity COUNTER is
    port(CLK : in STD_LOGIC;          --Clock
        RESET: in STD_LOGIC;                -- Reset
        OUT1 : out STD_LOGIC;               -- Digit 1 (Least significant digit)
        OUT2 : out STD_LOGIC;               -- Digit 2
        OUT3 : out STD_LOGIC;               --  Digit 3
        OUT4 : out STD_LOGIC                -- Digit 4 (Most significant digit)
   );
end COUNTER;


-- The functioning of counter is declared here

architecture Behaviour of COUNTER is
    component D_Flip_Flop is
    port (
        D : in STD_LOGIC;
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        Q : out STD_LOGIC
    );
    end component;
    
    -- Defining the signals used in the counter
    signal bit1, bit2, bit3, bit4 : STD_LOGIC := '0'; -- counting bits
    -- bit1 is the LSB
    -- bit4 is the MSB
    
    signal temp1, temp2, temp3, temp4, temp5 : STD_LOGIC; -- temp signals are used for storing temporary arguments
   -- temp1 = bit1 xor bit2
   -- temp2 = bit1 and bit2
    -- temp3 = bit3 xor (bit1 and bit2)
    --  temp4 = bit1 and bit2 and bit3
    --  temp5 = bit4 xor (bit1 and bit2 and bit3)
   
begin

		
    -- First D Flip Flop
     -- Output corresponds to the least significant bit
    -- D = Qnot 
	    U1 : D_Flip_Flop port map(
        D => (not bit1),
        clk => CLK,
        reset => RESET,
        Q => bit1
    );
    
     
     
     
     -- assigning temp1 its value
    temp1 <= (bit1 xor bit2);




    -- Second D Flip Flop
     -- Output corresponds to bit2
    -- D = Q1 xor Q2 
    U2 : D_Flip_Flop port map(
        D => temp1,
        clk => CLK,
        reset => RESET,
        Q => bit2
    );
    
     
     
     --assigning temp2 and temp3 their values
    temp2 <= (bit1 and bit2);
    temp3 <= (bit3 xor temp2);
     
     
     
    
    -- Third JK Flip Flop
     -- Output corresponds to bit3
    -- D = (Q1 AND Q2) xor Q3
    U3 : D_Flip_Flop port map(
        D => temp3,
        clk => CLK,
        reset => RESET,
        Q => bit3
    );
    
     
     
     --assigning temp4 and temp5 their values
    temp4 <= (temp2 and bit3);
    temp5 <= (bit4 xor temp4);
     
     
     
    
    -- Fourth JK Flip Flop
     -- Output corresponds to most significant bit
    -- D = (Q1 AND Q2 AND Q3) xor Q4
    U4 : D_Flip_Flop port map(
        D => temp5,
        clk => CLK,
        reset => RESET,
        Q => bit4
    );
    
     
     
     
    -- Displaying the Counter bits as output
    OUT1 <= bit1;
    OUT2 <= bit2;
    OUT3 <= bit3;
    OUT4 <= bit4;
      
        
        
end Behaviour;