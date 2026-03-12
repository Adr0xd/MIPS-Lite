library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_ARITH.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MPG is
    Port(
        clk : in std_logic;
        btn : in std_logic_vector(4 downto 0);
        enable: out std_logic_vector(4 downto 0)
    );
end entity MPG;

architecture Behavioral of MPG is

    signal counter_out: std_logic_vector (15 downto 0);
    
    signal dff1_enable: std_logic;
    
    signal dff1_out: std_logic_vector (4 downto 0);
    signal dff2_out: std_logic_vector (4 downto 0);
    signal dff3_out: std_logic_vector (4 downto 0);
    
begin

    -- 16 bit up counter
    process(clk)
    begin
        if rising_edge (clk) then
            counter_out <= counter_out + 1;
        end if;
    end process;    
    
    dff1_enable <= '1' when counter_out = x"000f" else '0';
    
    process(clk) -- 1st D flip flop
    begin
        if rising_edge (clk) then
            if dff1_enable = '1' then
                dff1_out <= btn;
            end if;
        end if;
    end process;
    
    process(clk) -- 2nd D flip flop
    begin
        if rising_edge (clk) then
            dff2_out <= dff1_out;
        end if;
    end process;
    
    process(clk) -- 3rd D flip flop
    begin
        if rising_edge (clk) then
            dff3_out <= dff2_out;
        end if;
    end process;
    
    enable <= dff2_out and not dff3_out;
        
end architecture Behavioral;