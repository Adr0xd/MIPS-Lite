			R-type instruction

   	    3         3        3       3       1      3
	-----------------------------------------------------	
	| opcode |   rs   |   rt   |   rd   | sa | function |
	-----------------------------------------------------

ADD       000_______sss______ttt______ddd______0_____000
$d <= $s + $t;
add $d, $s, $t

SUB       000_______sss______ttt______ddd______0_____001
$d <= $s - $t;
sub $d, $s, $t

SLL       000_______sss______ttt______ddd______1_____010
$d <= $t << 1;
sll $d, $t

SRL       000_______sss______ttt______ddd______1_____011
$d <= $t >> 1;
sll $d, $t

AND       000_______sss______ttt______ddd______0_____100
$d <= $s & $t;
and $d, $s, $t

OR        000_______sss______ttt______ddd______0_____101
$d <= $s | $t;
or $d, $s, $t

SLT       000_______sss______ttt______ddd______0_____110
if $s < $t $d <= 1 else $d <= 0;
slt $d, $s, $t

XOR       000_______sss______ttt______ddd______0_____111
$d <= $s ^ $t;
xor $d, $s, $t


			I-type instruction

	     3	     3        3              7
	------------------------------------------------------
	| opcode |   rs   |   rt   |    addr/immediate       |
	------------------------------------------------------

ADDI       001______sss______ttt___________iiiiiii
$t <= $s, imm; 
addi $t, $s, imm

LW         010______sss______ttt___________iiiiiii
$t <= MEM[$s + offset];
lw $t, offset($s)

SW         011______sss______ttt___________iiiiiii
MEM[$s + offset] <= $tl
sw $t, offset($s)

BEQ        100______sss______ttt___________iiiiiii
if $s == $t advance_pc(offset) else advance_pc(1)
beq $s, $t, offset

BNE        101______sss______ttt___________iiiiiii
if $s != $t advance_pc(offset) else advance_pc(1)
bne $s, $t, offset

ORI        110______sss______ttt___________iiiiiii
$t <= $s | imm
ori $t, $s, imm

			J-type instruction

	     3	                     13
	------------------------------------------------------
	| opcode |              target address               |
	------------------------------------------------------


J         111___________________aaaaaaaaaaaaa
PC <= newPC; newPC = (PC & 0xC000) | target;
j target












