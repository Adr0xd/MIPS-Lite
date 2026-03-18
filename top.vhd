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
    
    signal ssd_digits: std_logic_vector(31 downto 0):= (others => '0');
    
    type t_rom is array (0 to 255) of std_logic_vector(15 downto 0);
    signal s_rom_in : t_rom := (
      x"0000",  -- 0
      x"1234",  -- 1
      x"abcd",  -- 2
      x"1337",  -- 3
      others => (others => '1') -- always have others
    );
    
    signal rom_data_out: std_logic_vector(15 downto 0);
   
    

    begin
    
        monopulse: MPG port map(clk => clk, btn => btn(4 downto 0), enable=>mpg_out);
        
        ssd_digits <= x"0000" & rom_data_out;
        seven_seg: SSD port map(clk => clk,digits => ssd_digits ,cat => cat, an => an);
    
        
        count_up <= mpg_out(1);  
        count_down <= mpg_out(4);
        reset <= mpg_out(0);
        
        led <= x"00" & count(7 downto 0);-- zero extension on the counter
        
        rom_data_out <= s_rom_in(conv_integer(count(7 downto 0)));  

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
       
--        led <= count; -- no longer need this

        led(1 downto 0) <= count(1 downto 0);
        
end Behavioral;