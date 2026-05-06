LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY exec_unit IS
  PORT (
    -- inputs
    ext_imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    rd1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    rd2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    pc_plus_one : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    sa : IN STD_LOGIC;
    -- control signals
    alu_op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
    alu_src : IN STD_LOGIC;
    -- outputs
    alu_res : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    bta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
    zero : OUT STD_LOGIC
  );
END ENTITY;

ARCHITECTURE rtl OF exec_unit IS

  SIGNAL s_alu_control : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL s_alu_res : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL s_second_operand : STD_LOGIC_VECTOR(15 DOWNTO 0);

  SIGNAL s_s_less_than_t : STD_LOGIC;

BEGIN

  -- Lecture 5, slide 25
  -- ALU Control
  PROCESS (alu_op, func)
  BEGIN
    CASE alu_op IS
      WHEN "000" =>
        CASE func IS
          WHEN "000" => s_alu_control <= "000"; -- ADD
          WHEN "001" => s_alu_control <= "001"; -- SUB
          WHEN "010" => s_alu_control <= "010"; -- SLL
          WHEN "011" => s_alu_control <= "011"; -- SRL
          WHEN "100" => s_alu_control <= "100"; -- AND
          WHEN "101" => s_alu_control <= "101"; -- OR
          WHEN "110" => s_alu_control <= "110"; -- SLT
          WHEN "111" => s_alu_control <= "111"; -- XOR
          WHEN OTHERS => s_alu_control <= "000";
        END CASE;
      WHEN "001" => s_alu_control <= "000"; -- ADDI -- add control
      WHEN "010" => s_alu_control <= "000"; -- LW -- its an add between $s and offset
      WHEN "011" => s_alu_control <= "000"; -- SW -- same
      WHEN "100" => s_alu_control <= "001"; -- BEQ -- subtract $s-$t
      WHEN "101" => s_alu_control <= "101"; -- SLTI 
      WHEN "110" => s_alu_control <= "101"; -- ORI
      WHEN OTHERS => s_alu_control <= "000";
    END CASE;
  END PROCESS;

  -- MUX for Second Operand
  s_second_operand <= rd2 WHEN alu_src = '0' ELSE
    ext_imm;

  -- ALU
  PROCESS (s_alu_control, sa, rd1, s_second_operand)
  BEGIN
    CASE s_alu_control IS
      WHEN "000" => s_alu_res <= rd1 + s_second_operand; -- add
      WHEN "001" => s_alu_res <= rd1 - s_second_operand; -- sub
      WHEN "010" => s_alu_res <= rd1(14 DOWNTO 0) & '0'; -- sll
      WHEN "011" => s_alu_res <= '0' & rd1(15 DOWNTO 1); -- srl
      WHEN "100" => s_alu_res <= rd1 AND s_second_operand; -- AND
      WHEN "101" => s_alu_res <= rd1 OR s_second_operand; -- OR
      WHEN "110" => s_alu_res <= b"0000_0000_0000_000" & s_s_less_than_t; -- SLT
      WHEN "111" => s_alu_res <= rd1 XOR s_second_operand; -- XOR
      WHEN OTHERS => s_alu_res <= (OTHERS => '0');
    END CASE;
  END PROCESS;

  s_s_less_than_t <= '1' WHEN rd1 < s_second_operand ELSE
    '0';

  alu_res <= s_alu_res; -- DUE TO ZERO FLAG, output cannot be a variable for condition in 'when' statement

  -- Branch Target Address
  bta <= ext_imm + pc_plus_one;

  -- Zero Flag
  zero <= '1' WHEN s_alu_res = x"0000" ELSE
    '0';

END ARCHITECTURE;