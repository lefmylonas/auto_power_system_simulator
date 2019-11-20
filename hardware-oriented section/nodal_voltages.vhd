LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.PS_SIM_PACKAGE.ALL;
USE WORK.PS_SIM_SUPPORT_PACKAGE.ALL;

ENTITY NODAL_VOLTAGES IS
    port(I_b: in matrix(1 to No_Nodes, 1 to 1);
	 V_n: out matrix(1 to No_Nodes, 1 to 1));
END NODAL_VOLTAGES;

ARCHITECTURE arch OF NODAL_VOLTAGES IS

begin

Vn_Loop: for i in 1 to No_Nodes generate
	V_n(i,1) <= calc_nodal_voltages(i, I_b);
end generate;

END arch;
