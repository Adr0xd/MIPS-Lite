library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity ssd is
  port (
    clk    : in  std_logic;
    digits : in  std_logic_vector(31 downto 0);   
    an     : out std_logic_vector(7  downto 0);
    cat    : out std_logic_vector(6  downto 0)
  );
end entity ssd;

architecture behavioral of ssd is

  signal counter_out  : std_logic_vector(15 downto 0) := (others => '0');
  signal top_mux_out  : std_logic_vector(3 downto 0) := (others => '0');
  
begin

  process(clk)
  begin
    if rising_edge(clk) then
      counter_out <= counter_out + 1;
    end if;
  end process;
  
  process (counter_out(15 downto 13)) -- anode selector
    begin
      case counter_out(15 downto 13) is
        when "000"  => an <= b"1111_1110";
        when "001"  => an <= b"1111_1101";
        when "010"  => an <= b"1111_1011";
        when "011"  => an <= b"1111_0111";
        when "100"  => an <= b"1110_1111";
        when "101"  => an <= b"1101_1111";
        when "110"  => an <= b"1011_1111";
        when others => an <= b"0111_1111";
      end case;
    end process;
    
    with top_mux_out select -- hex to dcd decoder
        cat <= "1111001" when "0001",   --1
               "0100100" when "0010",   --2
               "0110000" when "0011",   --3
               "0011001" when "0100",   --4
               "0010010" when "0101",   --5
               "0000010" when "0110",   --6
               "1111000" when "0111",   --7
               "0000000" when "1000",   --8
               "0010000" when "1001",   --9
               "0001000" when "1010",   --A
               "0000011" when "1011",   --b
               "1000110" when "1100",   --C
               "0100001" when "1101",   --d
               "0000110" when "1110",   --E
               "0001110" when "1111",   --F
               "1000000" when others;   --0
               
        process (counter_out(15 downto 13), digits) -- top mux
        begin
          case counter_out(15 downto 13) is
            when "000"  => top_mux_out <= digits(3 downto 0);
            when "001"  => top_mux_out <= digits(7 downto 4);
            when "010"  => top_mux_out <= digits(11 downto 8);
            when "011"  => top_mux_out <= digits(15 downto 12);
            when "100"  => top_mux_out <= digits(19 downto 16);
            when "101"  => top_mux_out <= digits(23 downto 20);
            when "110"  => top_mux_out <= digits(27 downto 24);
            when others => top_mux_out <= digits(31 downto 28);
          end case;
        end process;

  

end behavioral; 