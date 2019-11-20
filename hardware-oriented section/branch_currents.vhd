LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.PS_SIM_PACKAGE.ALL;
USE WORK.PS_SIM_SUPPORT_PACKAGE.ALL;

ENTITY BRANCH_CURRENTS IS
	port(V_branch, I_hs: in matrix(1 to No_Brn, 1 to 1);
	     I_br: out matrix(1 to No_Brn, 1 to 1));
END BRANCH_CURRENTS;

ARCHITECTURE arch of BRANCH_CURRENTS IS

begin

Ibr_loop: for i in 1 to No_Brn generate
	Normal_brn: if signed(Transf(i,1)) = 0 generate -- Normal Branch
	   I_br(i,1) <= calc_branch_currents(i,signed(V_branch(i,1)),signed(I_hs(i,1)));
	end generate;
	
	Transf_brn: if signed(Transf(i,1)) /= 0 generate -- Transformer Secondary Branch
	   I_br(i,1) <= calc_branch_currents(i,signed(V_branch(i,1)),signed(I_hs(i,1)),signed(V_branch(i+1,1)));
	end generate;
end generate;

END arch;
