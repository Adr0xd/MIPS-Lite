LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY top IS
    PORT (
        clk : IN STD_LOGIC;
        btn : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
        sw : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        led : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        an : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        cat : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END top;

ARCHITECTURE Behavioral OF top IS

    COMPONENT MPG
        PORT (
            clk : IN STD_LOGIC;
            btn : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
            enable : OUT STD_LOGIC_VECTOR(4 DOWNTO 0)
        );
    END COMPONENT MPG;

    COMPONENT ssd IS
        PORT (
            clk : IN STD_LOGIC;
            digits : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
            an : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            cat : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT ssd;

    COMPONENT inst_fetch
        PORT (
            clk : IN STD_LOGIC;
            branch_target_address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            jump_address : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            jump : IN STD_LOGIC;
            pc_src : IN STD_LOGIC;
            pc_en : IN STD_LOGIC;
            pc_reset : IN STD_LOGIC;
            instruction : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            pc_plus_one : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT control_unit
        PORT (
            op_code : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
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
    END COMPONENT;

    COMPONENT instr_decode
        PORT (
            clk : IN STD_LOGIC;
            instr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            wd : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            ext_op : IN STD_LOGIC;
            reg_dst : IN STD_LOGIC;
            reg_write : IN STD_LOGIC;
            ext_imm : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            func : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            rd1 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            rd2 : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            sa : OUT STD_LOGIC
        );
    END COMPONENT;

    -- IF signals
    SIGNAL s_if_out_instruction : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL s_if_out_pc_plus_one : STD_LOGIC_VECTOR(15 DOWNTO 0);
    -- ID signals  

    -- ID related signals
    SIGNAL s_id_in_reg_write : STD_LOGIC;
    SIGNAL s_id_out_ext_imm : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL s_id_out_func : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL s_id_out_rd1 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL s_id_out_rd2 : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL s_id_out_sa : STD_LOGIC;
    -- end ID

    -- Control Signals
    SIGNAL s_ctrl_reg_dst : STD_LOGIC;
    SIGNAL s_ctrl_ext_op : STD_LOGIC;
    SIGNAL s_ctrl_alu_src : STD_LOGIC;
    SIGNAL s_ctrl_branch : STD_LOGIC;
    SIGNAL s_ctrl_jump : STD_LOGIC;
    SIGNAL s_ctrl_alu_op : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL s_ctrl_mem_write : STD_LOGIC;
    SIGNAL s_ctrl_mem_to_reg : STD_LOGIC;
    SIGNAL s_ctrl_reg_write : STD_LOGIC;
    -- end control

    -- exec unit
    SIGNAL s_eu_out_alu_res : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL s_eu_out_bta : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL s_eu_out_zero : STD_LOGIC := '0';
    -- 

    COMPONENT exec_unit
        PORT (
            ext_imm : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            func : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            rd1 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            rd2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            pc_plus_one : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            sa : IN STD_LOGIC;
            alu_op : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
            alu_src : IN STD_LOGIC;
            alu_res : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            bta : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            zero : OUT STD_LOGIC
        );
    END COMPONENT;

    --adder output
    SIGNAL s_add_out : STD_LOGIC_VECTOR(15 DOWNTO 0);

    -- io board
    SIGNAL s_mpg_out : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_digits : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');

    SIGNAL s_digits_upper : STD_LOGIC_VECTOR(15 DOWNTO 0);

    SIGNAL s_digits_lower : STD_LOGIC_VECTOR (15 DOWNTO 0);

    -- Memory Unit
    SIGNAL s_mu_in_mem_write : STD_LOGIC := '0';
    SIGNAL s_mu_out_mem_data : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";
    SIGNAL s_mu_out_alu_res : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";

    COMPONENT mem_unit
        PORT (
            clk : IN STD_LOGIC;
            alu_res_in : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            rd2 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            mem_write : IN STD_LOGIC;
            mem_data : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            alu_res_out : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
        );
    END COMPONENT;
    -- Write Back unit
    SIGNAL s_wb_out_wd : STD_LOGIC_VECTOR(15 DOWNTO 0) := x"0000";

    signal s_pc_src: std_logic;   
    
    signal s_ja_aux: std_logic_vector(15 downto 0);

BEGIN

    exec_unit_inst : exec_unit
    PORT MAP(
        ext_imm => s_id_out_ext_imm,
        func => s_id_out_func,
        rd1 => s_id_out_rd1,
        rd2 => s_id_out_rd2,
        pc_plus_one => s_if_out_pc_plus_one,
        sa => s_id_out_sa,
        alu_op => s_ctrl_alu_op,
        alu_src => s_ctrl_alu_src,
        alu_res => s_eu_out_alu_res,
        bta => s_eu_out_bta,
        zero => s_eu_out_zero
    );

    monopulse : MPG PORT MAP
        (clk => clk, btn => btn(4 DOWNTO 0), enable => s_mpg_out);
    seven_seg : SSD PORT MAP(clk => clk, digits => s_digits, cat => cat, an => an);
    
    inst_infe : inst_fetch
    PORT MAP(
        clk => clk,
        branch_target_address => s_eu_out_bta,
        jump_address => s_ja_aux,
        jump => s_ctrl_jump,
        pc_src => s_pc_src,
        pc_en => s_mpg_out(0),
        pc_reset => s_mpg_out(1),
        instruction => s_if_out_instruction,
        pc_plus_one => s_if_out_pc_plus_one
    );
    
    s_ja_aux <= "000" & s_if_out_instruction(12 downto 0);
    
    s_pc_src <= s_ctrl_branch AND s_eu_out_zero;

    inst_cu : control_unit
    PORT MAP(
        op_code => s_if_out_instruction(15 DOWNTO 13),
        reg_dst => s_ctrl_reg_dst,
        ext_op => s_ctrl_ext_op,
        alu_src => s_ctrl_alu_src,
        branch => s_ctrl_branch,
        jump => s_ctrl_jump,
        alu_op => s_ctrl_alu_op,
        mem_write => s_ctrl_mem_write,
        mem_to_reg => s_ctrl_mem_to_reg,
        reg_write => s_ctrl_reg_write
    );

    inst_indcd : instr_decode
    PORT MAP(
        clk => clk,
        instr => s_if_out_instruction,
        wd => s_wb_out_wd,
        ext_op => s_ctrl_ext_op,
        reg_dst => s_ctrl_reg_dst,
        reg_write => s_id_in_reg_write,
        ext_imm => s_id_out_ext_imm,
        func => s_id_out_func,
        rd1 => s_id_out_rd1,
        rd2 => s_id_out_rd2,
        sa => s_id_out_sa
    );

    mem_unit_inst : mem_unit
    PORT MAP(
        clk => clk,
        alu_res_in => s_eu_out_alu_res,
        rd2 => s_id_out_rd2,
        mem_write => s_mu_in_mem_write,
        mem_data => s_mu_out_mem_data,
        alu_res_out => s_mu_out_alu_res
    );

    -- MU related
    s_mu_in_mem_write <= s_ctrl_mem_write AND s_mpg_out(0);

    -- reg write
    s_id_in_reg_write <= s_ctrl_reg_write AND s_mpg_out(0);

    -- WB related behavioral code
    s_wb_out_wd <= s_mu_out_mem_data WHEN s_ctrl_mem_to_reg = '1' ELSE
        s_mu_out_alu_res;
        
        
        
    -- MUX for 7-segment display left side (31 downto 16)
    PROCESS (sw(11 DOWNTO 9), s_if_out_pc_plus_one, s_if_out_instruction, s_id_out_rd1, s_id_out_rd2, s_wb_out_wd)
    BEGIN
        CASE sw(11 DOWNTO 9) IS
            WHEN "000" => s_digits_upper <= s_if_out_instruction;
            WHEN "001" => s_digits_upper <= s_if_out_pc_plus_one;
            WHEN "010" => s_digits_upper <= s_id_out_rd1;
            WHEN "011" => s_digits_upper <= s_id_out_rd2;
            WHEN "100" => s_digits_upper <= s_id_out_ext_imm;
            WHEN "101" => s_digits_upper <= s_eu_out_alu_res;
            WHEN "110" => s_digits_upper <= s_mu_out_mem_data;
            WHEN "111" => s_digits_upper <= s_wb_out_wd;
            WHEN OTHERS => s_digits_upper <= x"0000";
        END CASE;
    END PROCESS;

    -- MUX for 7-segment display right side (15 downto 0)
    PROCESS (sw(6 DOWNTO 4), s_if_out_pc_plus_one, s_if_out_instruction, s_id_out_rd1, s_id_out_rd2, s_wb_out_wd)
    BEGIN
        CASE sw(6 DOWNTO 4) IS
            WHEN "000" => s_digits_lower <= s_if_out_instruction;
            WHEN "001" => s_digits_lower <= s_if_out_pc_plus_one;
            WHEN "010" => s_digits_lower <= s_id_out_rd1;
            WHEN "011" => s_digits_lower <= s_id_out_rd2;
            WHEN "100" => s_digits_lower <= s_id_out_ext_imm;
            WHEN "101" => s_digits_lower <= s_eu_out_alu_res;
            WHEN "110" => s_digits_lower <= s_mu_out_mem_data;
            WHEN "111" => s_digits_lower <= s_wb_out_wd;
            WHEN OTHERS => s_digits_lower <= x"0000";
        END CASE;
    END PROCESS;

    s_digits <= s_digits_upper & s_digits_lower;

    -- LED with signals from Main Control Unit
    led <= s_ctrl_alu_op & -- ALU operation        15:13
        b"0000_0" & -- Unused               12:8
        s_ctrl_reg_dst & -- Register destination 7
        s_ctrl_ext_op & -- Extend operation     6
        s_ctrl_alu_src & -- ALU source           5
        s_ctrl_branch & -- Branch               4
        s_ctrl_jump & -- Jump                 3
        s_ctrl_mem_write & -- Memory write         2
        s_ctrl_mem_to_reg & -- Memory to register   1
        s_ctrl_reg_write; -- Register write       0
END Behavioral;