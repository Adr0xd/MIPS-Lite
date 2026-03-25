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
    
    component reg_file is
        port (
            clk : in std_logic;
            ra1 : in std_logic_vector (3 downto 0);
            ra2 : in std_logic_vector (3 downto 0);
            wa : in std_logic_vector (3 downto 0);
            wd : in std_logic_vector (31 downto 0);
            wen : in std_logic;
            rd1 : out std_logic_vector (31 downto 0);
            rd2 : out std_logic_vector (31 downto 0)
        );
    end component reg_file;
    
    component rams_no_change is
        port ( clk : in std_logic;
            we : in std_logic;
            en : in std_logic;
            addr : in std_logic_vector(3 downto 0);
            di : in std_logic_vector(31 downto 0);
            do : out std_logic_vector(31 downto 0));
    end component rams_no_change;
    
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
    
    signal write_enable: std_logic:='0';
    
    signal reset: std_logic:='0';
    
    signal ssd_digits: std_logic_vector(31 downto 0):= (others => '0');
    
    
--    -- ROM
--    type t_rom is array (0 to 255) of std_logic_vector(15 downto 0);
--    signal s_rom_in : t_rom := (
--      x"0000",  -- 0
--      x"1234",  -- 1
--      x"abcd",  -- 2
--      x"1337",  -- 3
--      others => (others => '1') -- always have others
--    );
--    signal rom_data_out: std_logic_vector(15 downto 0); 
--    --- ROM DATA
   
--   signal s_rd1: std_logic_vector(31 downto 0);
--   signal s_rd2: std_logic_vector(31 downto 0);
   
   signal ram_data_out: std_logic_vector(31 downto 0);
    

    begin
    
        monopulse: MPG port map(clk => clk, btn => btn(4 downto 0), enable=>mpg_out);
        
        seven_seg: SSD port map(clk => clk,digits => ssd_digits ,cat => cat, an => an);
        
        ssd_digits <= ram_data_out(29 downto 0) & "00";
        
        ram_module: rams_no_change port map (clk => clk,
                                            we => write_enable,
                                            en => '1', -- always one (not needed)
                                            addr => count (3 downto 0),
                                            di => ssd_digits,
                                            do => ram_data_out);
    
    
        write_enable <= mpg_out(2);
--        register_file: reg_file port map(clk=>clk,
--                                        ra1 => count(3 downto 0),
--                                        ra2 => count(3 downto 0),
--                                        wa => count(3 downto 0),
--                                        wd => ssd_digits,
--                                        wen => write_enable,
--                                        rd1 => s_rd1,
--                                        rd2 => s_rd2);
                                       
                
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
       
        led <= x"000" & count(3 downto 0); -- zero ext
        
end Behavioral;