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
    
    signal mpg_out: std_logic_vector(4 downto 0);
    
    signal count: std_logic_vector(15 downto 0);
    
    signal count_en: std_logic:='0';

    begin
    
        monopulse: MPG port map(clk => clk, btn => btn(4 downto 0), enable=>mpg_out);
        
        count_en <= mpg_out(0);  

        process(clk, count_en)
        begin
            if rising_edge(clk) then
                if count_en = '1' then
                    count <= count + 1;
                end if;
            end if;
        end process;
          
        led <= count;
        
end Behavioral;