library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.defs.all;
use work.click_element_library_constants.all;
  
  entity top is
    port(
		clk : in std_logic;
        res_n : in std_logic;
        
        hex0 : out std_logic_vector(6 downto 0); 
        hex1 : out std_logic_vector(6 downto 0); 
        hex2 : out std_logic_vector(6 downto 0);
        hex3 : out std_logic_vector(6 downto 0); 
        hex4 : out std_logic_vector(6 downto 0);  
        hex5 : out std_logic_vector(6 downto 0); 

	    LEDR : out std_logic_vector(9 downto 0); 

		SWITCH : in std_logic_vector(9 downto 0)
    );
end top;


architecture arch of top is 
function to_segs(value : in std_logic_vector(3 downto 0)) return std_logic_vector is
	begin
		case value is
			when x"0" => return "1000000";
			when x"1" => return "1111001";
			when x"2" => return "0100100";
			when x"3" => return "0110000";
			when x"4" => return "0011001";
			when x"5" => return "0010010";
			when x"6" => return "0000010";
			when x"7" => return "1111000";
			when x"8" => return "0000000";
			when x"9" => return "0010000";
			when x"A" => return "0001000";
			when x"B" => return "0000011";
			when x"C" => return "1000110";
			when x"D" => return "0100001";
			when x"E" => return "0000110";
			when x"F" => return "0001110";
			when others => return "1111111";
		end case;
	end function;
	
	signal data_out, in_data : std_logic_vector(GCD_OUT_DATA_WIDTH -1 downto 0);
	
	signal SWITCH_deb : std_logic_vector(9 downto 0);
	
	signal in_req, out_ack : std_logic;
	
	signal A,B : std_logic_vector(4 - 1 downto 0);

begin

	hex0 <= to_segs(data_out);
    hex5 <= to_segs(A);
    hex4 <= to_segs(B);

	A_d: for I in 0 to 9 generate
		x: entity work.debounce
		generic map(
			COUNTER_SIZE => 19,
			SYNC_STAGES => 2
		)
		port map(
			clk => clk,
			res_n => res_n,
			data_in => SWITCH(I),
			data_out => SWITCH_deb(I)
		);
		end generate;
		
		
	in_req <= SWITCH_deb(0);
	out_ack <= SWITCH_deb(1);
	
	A <= SWITCH_deb(9 downto 6);
    B <= SWITCH_deb(5 downto 2);

  
    GCD: entity work.Scope(GCD)
    generic map(
        DATA_WIDTH => GCD_DATA_WIDTH,
        OUT_DATA_WIDTH => GCD_OUT_DATA_WIDTH,
        IN_DATA_WIDTH => GCD_IN_DATA_WIDTH
    )
    port map (
        rst => not res_n,
        -- input channel
        in_ack => LEDR(0),
        in_req => in_req,
        in_data => A & B,
        -- Output channel
        out_req => LEDR(1),
        out_data => data_out,
        out_ack => out_ack
    );


------------------------------
end architecture;

  