library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity top is
      port (
        clk : in std_logic;
        btn : in  std_logic_vector(4  downto 0);
        sw  : in  std_logic_vector(15 downto 0);
        led : out std_logic_vector(15 downto 0);
        an  : out std_logic_vector(7  downto 0);
        cat : out std_logic_vector(6  downto 0)
     );
end top;

architecture Behavioral of top is

    component MPG
        Port(
        clk : in std_logic;
        btn : in std_logic_vector(4 downto 0);
        enable  : out std_logic_vector(4 downto 0)
        );
    end component MPG;
    
    component ssd is
      port (
        clk    : in  std_logic;
        digits : in  std_logic_vector(31 downto 0);   
        an     : out std_logic_vector(7  downto 0);
        cat    : out std_logic_vector(6  downto 0)
      );
    end component ssd;
    
    signal mpg_out: std_logic_vector(4 downto 0);
    
    signal count: std_logic_vector(15 downto 0);
    
    signal count_up: std_logic:='0';
    signal count_down: std_logic:='0';
    signal reset: std_logic:='0';
    
    signal digits_from_counter: std_logic_vector(31 downto 0):= (others => '0');

    begin
    
        monopulse: MPG port map(clk => clk, btn => btn(4 downto 0), enable=>mpg_out);
        
        digits_from_counter <= x"0000" & count;
        
        seven_seg: SSD port map(clk => clk,digits => digits_from_counter ,cat => cat, an => an);
        
        count_up <= mpg_out(1);  
        count_down <= mpg_out(4);
        reset <= mpg_out(0);

        process(clk) -- up down reset counter
        begin
            if rising_edge(clk) then
                if count_up = '1' then
                    count <= count + 1;
                end if;
                if count_down = '1' then
                    count <= count - 1;
                end if;
                if reset = '1' then
                    count <= (others => '0');
                end if;
            end if;
        end process;        
          
        led <= count;
        
end Behavioral;