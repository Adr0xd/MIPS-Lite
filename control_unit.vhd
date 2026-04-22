LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY control_unit IS
  PORT (
    -- inputs
    op_code : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    -- outputs
    reg_dst : OUT STD_LOGIC;
    ext_op : OUT STD_LOGIC;
    alu_src : OUT STD_LOGIC;
    branch : OUT STD_LOGIC;
    jump : OUT STD_LOGIC;
    alu_op : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    mem_write : OUT STD_LOGIC;
    mem_to_reg : OUT STD_LOGIC;
    reg_write : OUT STD_LOGIC
  );
END control_unit;

ARCHITECTURE behavioral OF control_unit IS

  -- R type
  --  15    13 12     10 9      7 6      4  3  2         0
  -- -----------------------------------------------------	
  -- | opcode |   rs   |   rt   |   rd   | sa | function |
  -- -----------------------------------------------------

  -- I type

  -- 15     13 12    10 9      7 6                       0
  -- ------------------------------------------------------
  -- | opcode |   rs   |   rt   |    addr/immediate       |
  -- ------------------------------------------------------

  -- J Type

  --  15    13 12                                         0
  -- ------------------------------------------------------
  -- | opcode |              target address               |
  -- ------------------------------------------------------

BEGIN

  PROCESS (op_code)
  BEGIN
    CASE op_code IS
      WHEN "000" => -- R type instruction
        reg_dst <= '1'; -- for R type instruction reg dest is 1 otw 0
        ext_op <= '0'; -- zero extension on R type instructions
        alu_src <= '0';
        branch <= '0';
        jump <= '0';
        alu_op <= "000";
        mem_write <= '0';
        mem_to_reg <= '0';
        reg_write <= '1';
      WHEN "001" => --> ADD immediate - ADDI
        reg_dst <= '0';
        ext_op <= '1'; -- sign extend on arithmethic ops
        alu_src <= '1';
        branch <= '0';
        jump <= '0';
        alu_op <= "001"; -- good
        mem_write <= '0';
        mem_to_reg <= '0';
        reg_write <= '1';
      WHEN "010" => --> LW
        reg_dst <= '0';
        ext_op <= '1'; -- sign extend on arithmethic ops
        alu_src <= '1';
        branch <= '0';
        jump <= '0';
        alu_op <= "010"; -- LW alu op will go to add in eu
        mem_write <= '0';
        mem_to_reg <= '1';
        reg_write <= '1';
      WHEN "011" => --> SW
        reg_dst <= '0';
        ext_op <= '1'; -- sign extend on arithmethic ops
        alu_src <= '1';
        branch <= '0';
        jump <= '0';
        alu_op <= "011"; -- sw alu op will go to add in eu
        mem_write <= '1';
        mem_to_reg <= '0'; -- dont care
        reg_write <= '0';
      WHEN "100" => -- BEQ
        reg_dst <= '0';
        ext_op <= '0'; -- zero extend address to branch -- I THINK IT IS 
        alu_src <= '0'; -- perf s-t and check zf
        branch <= '1';
        jump <= '0';
        alu_op <= "100"; -- beq alu op will go to sub in eu
        mem_write <= '0';
        mem_to_reg <= '0'; -- dont care
        reg_write <= '0';
      WHEN "101" => -- SLTI
        reg_dst <= '0';
        ext_op <= '1'; -- sign extend on arith op
        alu_src <= '1';
        branch <= '0';
        jump <= '0';
        alu_op <= "101"; -- SLTI
        mem_write <= '0';
        mem_to_reg <= '0'; -- dont care
        reg_write <= '1';
      WHEN "110" => -- ORI
        reg_dst <= '0';
        ext_op <= '0'; -- zero extend on logical op
        alu_src <= '1'; -- perf $s-$t and check zf
        branch <= '0';
        jump <= '0';
        alu_op <= "110"; -- OR
        mem_write <= '0';
        mem_to_reg <= '0';
        reg_write <= '1';
      WHEN "111" => -- JUMP
        reg_dst <= '0';
        ext_op <= '0';
        alu_src <= '0';
        branch <= '0';
        jump <= '1';
        alu_op <= "111";
        mem_write <= '0';
        mem_to_reg <= '0';
        reg_write <= '0';
      WHEN OTHERS =>
        reg_dst <= '0';
        ext_op <= '0';
        alu_src <= '0';
        branch <= '0';
        jump <= '0';
        alu_op <= "000";
        mem_write <= '0';
        mem_to_reg <= '0';
        reg_write <= '0';
    END CASE;
  END PROCESS;

END behavioral;