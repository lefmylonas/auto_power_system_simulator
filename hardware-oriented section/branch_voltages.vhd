LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.PS_SIM_PACKAGE.ALL;
USE WORK.PS_SIM_SUPPORT_PACKAGE.ALL;

ENTITY BRANCH_VOLTAGES IS
	port(V_n: in matrix(1 to No_Nodes, 1 to 1);
	     V_branch: out matrix(1 to No_Brn, 1 to 1));
END BRANCH_VOLTAGES;

ARCHITECTURE arch of BRANCH_VOLTAGES IS

begin

Vbrn_gen: for i in 1 to No_Brn generate
	Non_Zero_Nodes: if (BrnInfo(i,1) /= 0) and (BrnInfo(i,2) /= 0) generate
		V_branch(i,1) <= std_logic_vector(signed(V_n(BrnInfo(i,1),1)) - signed(V_n(BrnInfo(i,2),1)));
	end generate;
	Zero_Positive_Node: if BrnInfo(i,1) = 0 generate
		V_branch(i,1) <= std_logic_vector(- signed(V_n(BrnInfo(i,2),1)) );
	end generate;
	Zero_Negative_Node: if BrnInfo(i,2) = 0 generate
		V_branch(i,1) <= V_n(BrnInfo(i,1),1);
	end generate;
end generate;

END arch;