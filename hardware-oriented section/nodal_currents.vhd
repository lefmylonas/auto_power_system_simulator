LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE WORK.PS_SIM_PACKAGE.ALL;
USE WORK.PS_SIM_SUPPORT_PACKAGE.ALL;

ENTITY NODAL_CURRENTS IS
    port(I_hs: in matrix(1 to No_Brn, 1 to 1);
	 I_s: in matrix(1 to No_Src-No_Vk, 1 to 1);
	 I_b: out matrix(1 to No_Nodes, 1 to 1));
END NODAL_CURRENTS;

ARCHITECTURE arch OF NODAL_CURRENTS IS

begin

Ib_Loop: for i in 1 to No_Nodes generate
	I_b(i,1) <= add_currents(i, I_hs, I_s);
end generate;

END arch;