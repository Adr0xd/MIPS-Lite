library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity inst_fetch is
  port (
    -- inputs
    clk                   : in  std_logic;
    branch_target_address : in  std_logic_vector(15 downto 0);
    jump_address          : in  std_logic_vector(15 downto 0);
    pc_en                 : in  std_logic;
    pc_reset              : in  std_logic;
    -- control signal based inputs
    jump                  : in  std_logic;
    pc_src                : in  std_logic;
    -- outputs
    instruction           : out std_logic_vector(15 downto 0);
    pc_plus_one           : out std_logic_vector(15 downto 0)
  );
end inst_fetch;

architecture behavioral of inst_fetch is

  type t_rom is array (0 to 255) of std_logic_vector(15 downto 0);
  signal s_rom : t_rom := (
  --  opc rs  rt  rd sa func
    b"000_001_010_011_0_000", -- #0 x"0530" add $3 <= $1 + $2
    b"000_110_100_010_0_001", -- #1 x"1a21" sub $2 <= $6 - $4
    x"1234",                  -- #2 x"1234" just a random number
    x"abcd",                  -- #3 x"abcd" another random number
    x"1337",                  -- #4 x"1337" leet from leetspeak
    x"d00d",                  -- #5 x"d00d" dude
    others => (others => '1')
  );
  
  -- *  
  -- NO OTHER EXTERNAL COMPONENT DECLARATION NECESSARY
  -- ADDITIONAL SIGNALS HERE
  
  signal s_pc_out: std_logic_vector(15 downto 0);
  signal s_adder_out: std_logic_vector(15 downto 0);
  signal s_mux_branch_out: std_logic_vector(15 downto 0);
  signal s_mux_jump_out: std_logic_vector(15 downto 0);

begin

  -- **  
  -- NO OTHER EXTERNAL COMPONENT INSTANTIATION NECESSARY
  -- ADDITIONAL COMPONENT IMPLEMENTATION HERE
  
    process(clk, pc_en)
    begin
        if rising_edge(clk) then
            if(pc_reset = '1') then
                s_pc_out <= x"0000";
            end if;
            if(pc_en = '1') then
                s_pc_out <= s_mux_jump_out;
            end if;
        end if;
    end process;
    
    s_adder_out <= s_pc_out + 1;
    
    s_mux_branch_out <= branch_target_address when pc_src = '1' else s_adder_out;
    
    s_mux_jump_out <= jump_address when jump = '1' else s_mux_branch_out;
    
    instruction <= s_rom(conv_integer(s_pc_out(7 downto 0)));
    
    pc_plus_one <= s_adder_out;
    
    --forgot about this
    
    

end behavioral;