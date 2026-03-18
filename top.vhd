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
    
    signal alu_output: std_logic_vector(31 downto 0):= (others => '0');
    
    signal switch_7to0_ext_B: std_logic_vector(31 downto 0);
    signal switch_15to8_ext_A: std_logic_vector(31 downto 0);
    signal switch_15to0_ext_shift: std_logic_vector(31 downto 0);
    

    begin
    
        monopulse: MPG port map(clk => clk, btn => btn(4 downto 0), enable=>mpg_out);
        
        seven_seg: SSD port map(clk => clk,digits => alu_output ,cat => cat, an => an);
        
        led(7) <= '1' when alu_output = 0 else '0'; -- the zero detector;
        
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
        
        switch_7to0_ext_B <= x"000000" & sw(7 downto 0);
        switch_15to8_ext_A <= x"000000" & sw(15 downto 8);
        switch_15to0_ext_shift <= x"0000" & sw(15 downto 0);
        
        process(count) -- ALU output mux
        begin
            case count(1 downto 0) is
                when "00" => alu_output <= switch_15to8_ext_A + switch_7to0_ext_B; -- add a and b
                when "01" => alu_output <= switch_15to8_ext_A - switch_7to0_ext_B; -- sub b from a
                when "10" => alu_output <= switch_15to0_ext_shift(29 downto 0) & b"00"; -- shift left
                when others => alu_output <=  b"00" & switch_15to0_ext_shift(31 downto 2); -- shift right
            end case;
        end process; 
          
--        led <= count; -- no longer need this

        led(1 downto 0) <= count(1 downto 0);
        
end Behavioral;